#!/bin/bash

# Launch Frontend Container - Handles Docker permissions automatically
# 
# This script properly handles Docker network access from within devcontainer
# and ensures the frontend connects to the backend API.

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Frontend Container Launch Script ===${NC}\n"

# Step 1: Check Docker access and set commands
if command -v docker >/dev/null 2>&1; then
    # Test if we can run docker without sudo
    if docker ps >/dev/null 2>&1; then
        echo -e "${GREEN}Docker accessible without sudo${NC}"
        DOCKER_CMD="docker"
        COMPOSE_CMD="docker compose"
    elif command -v sudo >/dev/null 2>&1 && sudo docker ps >/dev/null 2>&1; then
        echo -e "${YELLOW}Using sudo for Docker commands${NC}"
        DOCKER_CMD="sudo docker"
        COMPOSE_CMD="sudo docker compose"
    else
        echo -e "${RED}❌ ERROR: Cannot access Docker${NC}"
        echo -e "${YELLOW}Please ensure Docker is running and accessible${NC}"
        exit 1
    fi
else
    echo -e "${RED}❌ ERROR: Docker not found${NC}"
    exit 1
fi

# Step 2: Check if frontend directory exists
echo -e "\n${BLUE}Step 1: Checking frontend directory...${NC}"
if [ ! -d "frontend" ]; then
    echo -e "${RED}❌ ERROR: Frontend directory not found${NC}"
    echo -e "${YELLOW}Please ensure you're in the project root directory${NC}"
    exit 1
fi

if [ ! -f "frontend/package.json" ]; then
    echo -e "${RED}❌ ERROR: Frontend package.json not found${NC}"
    echo -e "${YELLOW}Please ensure the frontend directory contains a valid Next.js project${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Frontend directory found${NC}"

# Step 3: Check if network exists
echo -e "\n${BLUE}Step 2: Checking Docker network...${NC}"
# Dynamically find the devcontainer network
NETWORK_NAME=$($DOCKER_CMD network ls --format "{{.Name}}" | grep -E "(devcontainer.*kitchensink|kitchensink.*devcontainer)" | head -1)

if [ -z "$NETWORK_NAME" ]; then
    # Fallback: try to find any network with 'kitchensink' in the name
    NETWORK_NAME=$($DOCKER_CMD network ls --format "{{.Name}}" | grep kitchensink | head -1)
fi

if [ -n "$NETWORK_NAME" ] && $DOCKER_CMD network inspect "$NETWORK_NAME" >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Network found: '$NETWORK_NAME'${NC}"
else
    echo -e "${RED}❌ ERROR: No suitable Docker network found${NC}"
    echo -e "${YELLOW}Available networks:${NC}"
    $DOCKER_CMD network ls
    echo -e "${YELLOW}Please ensure the devcontainer is running first${NC}"
    exit 1
fi

# Step 4: Check if backend is running
echo -e "\n${BLUE}Step 3: Checking backend availability...${NC}"
BACKEND_CONTAINER=$($DOCKER_CMD ps --filter "name=kitchensink-backend" --format "{{.Names}}" | head -1)
if [ -n "$BACKEND_CONTAINER" ]; then
    echo -e "${GREEN}✅ Backend container running: $BACKEND_CONTAINER${NC}"
    # Test backend health
    if $DOCKER_CMD exec "$BACKEND_CONTAINER" wget -qO- http://localhost:8080/actuator/health >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Backend API is healthy${NC}"
    else
        echo -e "${YELLOW}⚠️  Warning: Backend API not responding${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Warning: No backend container found running${NC}"
    echo -e "${YELLOW}Frontend will start but may not function without backend API${NC}"
fi

# Step 5: Stop existing frontend container if running
echo -e "\n${BLUE}Step 4: Checking for existing frontend container...${NC}"
if $DOCKER_CMD ps -a --filter "name=kitchensink-frontend" --format "{{.Names}}" | grep -q kitchensink-frontend; then
    echo -e "${YELLOW}Stopping and removing existing frontend container...${NC}"
    # Try with both original and temp compose files
    $COMPOSE_CMD -f docker-compose-frontend.yml down 2>/dev/null || true
    if [ -f "docker-compose-frontend-temp.yml" ]; then
        $COMPOSE_CMD -f docker-compose-frontend-temp.yml down 2>/dev/null || true
    fi
    # Force remove if still exists
    if $DOCKER_CMD ps -a --filter "name=kitchensink-frontend" --format "{{.Names}}" | grep -q kitchensink-frontend; then
        $DOCKER_CMD rm -f kitchensink-frontend
    fi
    echo -e "${GREEN}✅ Old container removed${NC}"
else
    echo -e "${GREEN}✅ No existing container to remove${NC}"
fi

# Step 6: Update compose file with correct network and build/launch frontend
echo -e "\n${BLUE}Step 5: Updating compose file and launching frontend container...${NC}"

# Create a temporary compose file with the correct network
TEMP_COMPOSE="docker-compose-frontend-temp.yml"
cp docker-compose-frontend.yml "$TEMP_COMPOSE"

# Update the network name and port in the temporary compose file
sed -i "s/devcontainer_kitchensink-network/$NETWORK_NAME/g" "$TEMP_COMPOSE"
sed -i 's/"3000:3000"/"3001:3000"/g' "$TEMP_COMPOSE"

echo -e "${GREEN}✅ Updated network configuration to use: $NETWORK_NAME${NC}"

$COMPOSE_CMD -f "$TEMP_COMPOSE" up -d --build

# Step 7: Wait for startup and check health
echo -e "\n${BLUE}Step 6: Waiting for application to start...${NC}"
echo -e "${YELLOW}This may take 60-120 seconds for initial build...${NC}\n"

for i in {1..120}; do
    if $DOCKER_CMD ps --filter "name=kitchensink-frontend" --format "{{.Status}}" | grep -q "healthy"; then
        echo -e "\n${GREEN}✅ Frontend container is healthy!${NC}"
        break
    elif $DOCKER_CMD ps --filter "name=kitchensink-frontend" --format "{{.Status}}" | grep -q "unhealthy"; then
        echo -e "\n${RED}❌ Frontend container is unhealthy${NC}"
        echo -e "${YELLOW}Showing last 20 lines of logs:${NC}\n"
        $COMPOSE_CMD -f "$TEMP_COMPOSE" logs --tail=20 frontend
        exit 1
    fi
    echo -n "."
    sleep 1
done

# Step 8: Display status
echo -e "\n\n${BLUE}=== Frontend Status ===${NC}"
$DOCKER_CMD ps --filter "name=kitchensink-frontend" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Step 9: Test endpoints
echo -e "\n${BLUE}=== Testing Endpoints ===${NC}\n"

echo -e "${YELLOW}Testing frontend health endpoint...${NC}"
if $DOCKER_CMD exec kitchensink-frontend wget -qO- http://localhost:3000/api/health >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Frontend health check: OK${NC}"
else
    echo -e "${YELLOW}⚠️  Frontend health endpoint not available (may not be implemented)${NC}"
fi

echo -e "\n${YELLOW}Testing frontend homepage...${NC}"
if $DOCKER_CMD exec kitchensink-frontend wget -qO- http://localhost:3000/ >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Frontend homepage: OK${NC}"
else
    echo -e "${RED}❌ Frontend homepage: FAILED${NC}"
fi

# Step 10: Display usage information
echo -e "\n${BLUE}=== Frontend Successfully Launched! ===${NC}\n"
echo -e "Frontend UI available at: ${GREEN}http://localhost:3001${NC}"
echo -e "Backend API URL: ${GREEN}http://localhost:8080${NC}"
echo -e "\n${YELLOW}Note: If accessing from outside devcontainer, use the host's IP instead of localhost${NC}\n"

echo -e "${YELLOW}Useful commands:${NC}"
echo -e "  View logs:      $COMPOSE_CMD -f $TEMP_COMPOSE logs -f frontend"
echo -e "  Stop frontend:  $COMPOSE_CMD -f $TEMP_COMPOSE down"
echo -e "  Restart:        $COMPOSE_CMD -f $TEMP_COMPOSE restart frontend"
echo -e "  Shell access:   $DOCKER_CMD exec -it kitchensink-frontend sh"
echo -e ""
echo -e "${YELLOW}Note: Temporary compose file created: $TEMP_COMPOSE${NC}"
echo -e "${YELLOW}Clean up with: rm $TEMP_COMPOSE${NC}"

# Cleanup temporary compose file
if [ -f "$TEMP_COMPOSE" ]; then
    rm -f "$TEMP_COMPOSE"
    echo -e "${GREEN}✅ Cleaned up temporary compose file${NC}"
fi

echo -e "${GREEN}✅ Frontend launch complete!${NC}"