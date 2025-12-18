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

# Step 1: Check if we're in the devcontainer
if [ -f "/.dockerenv" ]; then
    echo -e "${YELLOW}Running inside devcontainer - will use sudo for Docker commands${NC}"
    DOCKER_CMD="sudo docker"
    COMPOSE_CMD="sudo docker compose"
else
    echo -e "${GREEN}Running on host - using regular Docker commands${NC}"
    DOCKER_CMD="docker"
    COMPOSE_CMD="docker compose"
fi

# Step 2: Check if JAR exists
echo -e "\n${BLUE}Step 1: Checking if JAR exists...${NC}"
JAR_PATH="kitchensink/target/jboss-kitchensink.jar"

if [ ! -f "$JAR_PATH" ]; then
    echo -e "${RED}❌ ERROR: JAR file not found at $JAR_PATH${NC}"
    echo -e "${YELLOW}You need to build the JAR first:${NC}"
    echo -e "  cd kitchensink"
    echo -e "  ./gradlew clean build -x test"
    echo -e "  ${YELLOW}OR${NC}"
    echo -e "  mvn clean package -DskipTests"
    echo -e "\n${YELLOW}Or use the build script:${NC}"
    echo -e "  ./build-backend-jar.sh"
    exit 1
fi

JAR_SIZE=$(du -h "$JAR_PATH" | cut -f1)
echo -e "${GREEN}✅ JAR found: $JAR_PATH ($JAR_SIZE)${NC}"

# Step 3: Check if network exists
echo -e "\n${BLUE}Step 2: Checking Docker network...${NC}"
NETWORK_NAME="devcontainer_fullstack-network"

if $DOCKER_CMD network inspect "$NETWORK_NAME" >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Network '$NETWORK_NAME' exists${NC}"
else
    echo -e "${RED}❌ ERROR: Network '$NETWORK_NAME' not found${NC}"
    echo -e "${YELLOW}Creating network...${NC}"
    $DOCKER_CMD network create "$NETWORK_NAME"
    echo -e "${GREEN}✅ Network created${NC}"
fi

# Step 4: Check if MySQL is running
echo -e "\n${BLUE}Step 3: Checking MySQL container...${NC}"
if $DOCKER_CMD ps --filter "name=mysql" --format "{{.Names}}" | grep -q mysql; then
    MYSQL_CONTAINER=$($DOCKER_CMD ps --filter "name=mysql" --format "{{.Names}}" | grep mysql | head -1)
    echo -e "${GREEN}✅ MySQL container running: $MYSQL_CONTAINER${NC}"
else
    echo -e "${YELLOW}⚠️  Warning: No MySQL container found running${NC}"
    echo -e "${YELLOW}Backend will attempt to connect but may fail without database${NC}"
fi

# Step 5: Stop existing backend container if running
echo -e "\n${BLUE}Step 4: Checking for existing backend container...${NC}"
if $DOCKER_CMD ps -a --filter "name=kitchensink-backend" --format "{{.Names}}" | grep -q kitchensink-backend; then
    echo -e "${YELLOW}Stopping and removing existing backend container...${NC}"
    $COMPOSE_CMD -f docker-compose-backend-prebuilt.yml down
    echo -e "${GREEN}✅ Old container removed${NC}"
else
    echo -e "${GREEN}✅ No existing container to remove${NC}"
fi

# Step 6: Build and launch backend
echo -e "\n${BLUE}Step 5: Building and launching backend container...${NC}"
$COMPOSE_CMD -f docker-compose-backend-prebuilt.yml up -d --build

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
        $COMPOSE_CMD -f docker-compose-backend-prebuilt.yml logs --tail=20 backend
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
if curl -s http://localhost:8081/actuator/health | grep -q "UP"; then
    echo -e "${GREEN}✅ Health check: OK${NC}"
else
    echo -e "${RED}❌ Health check: FAILED${NC}"
fi

echo -e "\n${YELLOW}Testing API endpoint...${NC}"
if curl -s http://localhost:8081/rest/members >/dev/null; then
    echo -e "${GREEN}✅ API endpoint: OK${NC}"
else
    echo -e "${RED}❌ API endpoint: FAILED${NC}"
fi

# Step 10: Display usage information
echo -e "\n${BLUE}=== Backend Successfully Launched! ===${NC}\n"
echo -e "Backend API available at: ${GREEN}http://localhost:8081${NC}"
echo -e "Health check: ${GREEN}http://localhost:8081/actuator/health${NC}"
echo -e "API endpoint: ${GREEN}http://localhost:8081/rest/members${NC}"
echo -e "Debug port: ${GREEN}5006${NC}\n"

echo -e "${YELLOW}Useful commands:${NC}"
echo -e "  View logs:     $COMPOSE_CMD -f docker-compose-backend-prebuilt.yml logs -f backend"
echo -e "  Stop backend:  $COMPOSE_CMD -f docker-compose-backend-prebuilt.yml down"
echo -e "  Restart:       $COMPOSE_CMD -f docker-compose-backend-prebuilt.yml restart backend"
echo -e "  Shell access:  $DOCKER_CMD exec -it kitchensink-backend sh"
echo -e ""

echo -e "${GREEN}✅ Backend launch complete!${NC}"
