#!/bin/bash

# Launch Backend Container - Handles Docker permissions automatically
# 
# This script properly handles Docker network access from within devcontainer
# and ensures the backend connects to the existing MySQL database.

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Backend Container Launch Script ===${NC}\n"

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

# Step 2: Check if JAR exists
echo -e "\n${BLUE}Step 1: Checking if JAR exists...${NC}"
JAR_PATH="kitchensink/target/jboss-kitchensink.jar"

if [ ! -f "$JAR_PATH" ]; then
    echo -e "${RED}❌ ERROR: JAR file not found at $JAR_PATH${NC}"
    echo -e "${YELLOW}You need to build the JAR first:${NC}"
    echo -e "  cd kitchensink"
    echo -e "  mvn clean package -DskipTests"
    echo -e "\n${YELLOW}Or use the build script:${NC}"
    echo -e "  ./build-backend-jar.sh"
    exit 1
fi

JAR_SIZE=$(du -h "$JAR_PATH" | cut -f1)
echo -e "${GREEN}✅ JAR found: $JAR_PATH ($JAR_SIZE)${NC}"

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

# Step 4: Check if MySQL is running
echo -e "\n${BLUE}Step 3: Checking MySQL container...${NC}"
MYSQL_CONTAINER=$($DOCKER_CMD ps --filter "name=mysql" --format "{{.Names}}" | head -1)
if [ -n "$MYSQL_CONTAINER" ]; then
    # Verify MySQL is on the same network
    MYSQL_NETWORK=$($DOCKER_CMD inspect "$MYSQL_CONTAINER" --format '{{range $net, $conf := .NetworkSettings.Networks}}{{$net}} {{end}}' | grep -o "[^ ]*kitchensink[^ ]*" | head -1)
    echo -e "${GREEN}✅ MySQL container running: $MYSQL_CONTAINER${NC}"
    echo -e "${GREEN}✅ MySQL network: $MYSQL_NETWORK${NC}"
    
    # Update network name to match MySQL's network if different
    if [ "$MYSQL_NETWORK" != "$NETWORK_NAME" ] && [ -n "$MYSQL_NETWORK" ]; then
        echo -e "${YELLOW}Updating network to match MySQL: $MYSQL_NETWORK${NC}"
        NETWORK_NAME="$MYSQL_NETWORK"
    fi
else
    echo -e "${YELLOW}⚠️  Warning: No MySQL container found running${NC}"
    echo -e "${YELLOW}Backend will attempt to connect but may fail without database${NC}"
fi

# Step 5: Stop existing backend container if running
echo -e "\n${BLUE}Step 4: Checking for existing backend container...${NC}"
if $DOCKER_CMD ps -a --filter "name=kitchensink-backend" --format "{{.Names}}" | grep -q kitchensink-backend; then
    echo -e "${YELLOW}Stopping and removing existing backend container...${NC}"
    # Try with both original and temp compose files
    $COMPOSE_CMD -f docker-compose-backend-prebuilt.yml down 2>/dev/null || true
    if [ -f "docker-compose-backend-temp.yml" ]; then
        $COMPOSE_CMD -f docker-compose-backend-temp.yml down 2>/dev/null || true
    fi
    # Force remove if still exists
    if $DOCKER_CMD ps -a --filter "name=kitchensink-backend" --format "{{.Names}}" | grep -q kitchensink-backend; then
        $DOCKER_CMD rm -f kitchensink-backend
    fi
    echo -e "${GREEN}✅ Old container removed${NC}"
else
    echo -e "${GREEN}✅ No existing container to remove${NC}"
fi

# Step 6: Update compose file with correct network and build/launch backend
echo -e "\n${BLUE}Step 5: Updating compose file and launching backend container...${NC}"

# Create a temporary compose file with the correct network
TEMP_COMPOSE="docker-compose-backend-temp.yml"
cp docker-compose-backend-prebuilt.yml "$TEMP_COMPOSE"

# Update the network name in the temporary compose file
sed -i "s/devcontainer_fullstack-network/$NETWORK_NAME/g" "$TEMP_COMPOSE"

echo -e "${GREEN}✅ Updated network configuration to use: $NETWORK_NAME${NC}"

$COMPOSE_CMD -f "$TEMP_COMPOSE" up -d --build

# Step 7: Wait for startup and check health
echo -e "\n${BLUE}Step 6: Waiting for application to start...${NC}"
echo -e "${YELLOW}This may take 30-60 seconds...${NC}\n"

for i in {1..60}; do
    if $DOCKER_CMD ps --filter "name=kitchensink-backend" --format "{{.Status}}" | grep -q "healthy"; then
        echo -e "\n${GREEN}✅ Backend container is healthy!${NC}"
        break
    elif $DOCKER_CMD ps --filter "name=kitchensink-backend" --format "{{.Status}}" | grep -q "unhealthy"; then
        echo -e "\n${RED}❌ Backend container is unhealthy${NC}"
        echo -e "${YELLOW}Showing last 20 lines of logs:${NC}\n"
        $COMPOSE_CMD -f "$TEMP_COMPOSE" logs --tail=20 backend
        exit 1
    fi
    echo -n "."
    sleep 1
done

# Step 8: Display status
echo -e "\n\n${BLUE}=== Backend Status ===${NC}"
$DOCKER_CMD ps --filter "name=kitchensink-backend" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Step 9: Test endpoints
echo -e "\n${BLUE}=== Testing Endpoints ===${NC}\n"

echo -e "${YELLOW}Testing health endpoint...${NC}"
if $DOCKER_CMD exec kitchensink-backend wget -qO- http://localhost:8080/actuator/health | grep -q "UP"; then
    echo -e "${GREEN}✅ Health check: OK${NC}"
else
    echo -e "${RED}❌ Health check: FAILED${NC}"
fi

echo -e "\n${YELLOW}Testing API endpoint...${NC}"
if $DOCKER_CMD exec kitchensink-backend wget -qO- http://localhost:8080/rest/members >/dev/null 2>&1; then
    echo -e "${GREEN}✅ API endpoint: OK${NC}"
else
    echo -e "${RED}❌ API endpoint: FAILED${NC}"
fi

echo -e "\n${YELLOW}Sample API response:${NC}"
$DOCKER_CMD exec kitchensink-backend wget -qO- http://localhost:8080/rest/members 2>/dev/null || echo "[]"

# Step 10: Display usage information
echo -e "\n${BLUE}=== Backend Successfully Launched! ===${NC}\n"
echo -e "Backend API available at: ${GREEN}http://localhost:8081${NC}"
echo -e "Health check: ${GREEN}http://localhost:8081/actuator/health${NC}"
echo -e "API endpoint: ${GREEN}http://localhost:8081/rest/members${NC}"
echo -e "Debug port: ${GREEN}5006${NC}"
echo -e "\n${YELLOW}Note: If accessing from outside devcontainer, use the host's IP instead of localhost${NC}\n"

echo -e "${YELLOW}Useful commands:${NC}"
echo -e "  View logs:     $COMPOSE_CMD -f $TEMP_COMPOSE logs -f backend"
echo -e "  Stop backend:  $COMPOSE_CMD -f $TEMP_COMPOSE down"
echo -e "  Restart:       $COMPOSE_CMD -f $TEMP_COMPOSE restart backend"
echo -e "  Shell access:  $DOCKER_CMD exec -it kitchensink-backend sh"
echo -e ""
echo -e "${YELLOW}Note: Temporary compose file created: $TEMP_COMPOSE${NC}"
echo -e "${YELLOW}Clean up with: rm $TEMP_COMPOSE${NC}"

# Cleanup temporary compose file
if [ -f "$TEMP_COMPOSE" ]; then
    rm -f "$TEMP_COMPOSE"
    echo -e "${GREEN}✅ Cleaned up temporary compose file${NC}"
fi

echo -e "${GREEN}✅ Backend launch complete!${NC}"
