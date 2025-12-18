#!/bin/bash

# Script to build and launch the Spring Boot backend
# This script builds the JAR locally and then launches it in Docker

set -e

echo "============================================"
echo "Spring Boot Backend - Build and Launch"
echo "============================================"
echo ""

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if we're in the project root
if [ ! -d "kitchensink" ]; then
    echo -e "${RED}Error: Must be run from project root directory${NC}"
    echo "Current directory: $(pwd)"
    exit 1
fi

# Step 1: Build JAR locally
echo -e "${YELLOW}[Step 1/3]${NC} Building JAR locally..."
cd kitchensink

# Check if Gradle wrapper exists, then check for Maven
if [ -f "./gradlew" ]; then
    echo "Using Gradle..."
    ./gradlew clean build -x test
    BUILD_TOOL="Gradle"
    
    # Gradle puts JAR in build/libs/, need to copy to target/
    mkdir -p target
    if [ -f "build/libs/jboss-kitchensink.jar" ]; then
        cp build/libs/jboss-kitchensink.jar target/jboss-kitchensink.jar
        echo "Copied JAR from build/libs/ to target/"
    fi
elif [ -f "pom.xml" ]; then
    echo "Using Maven..."
    mvn clean package -DskipTests
    BUILD_TOOL="Maven"
else
    echo -e "${RED}Error: No build tool found (gradlew or pom.xml)${NC}"
    exit 1
fi

# Check if JAR was created (in target/ directory for Docker compatibility)
if [ -f "target/jboss-kitchensink.jar" ]; then
    JAR_SIZE=$(du -h target/jboss-kitchensink.jar | cut -f1)
    echo -e "${GREEN}✅ JAR built successfully${NC} (Size: $JAR_SIZE)"
    echo "JAR location: kitchensink/target/jboss-kitchensink.jar"
else
    echo -e "${RED}❌ JAR build failed${NC}"
    echo "Expected JAR: target/jboss-kitchensink.jar"
    echo ""
    echo "Checking alternative locations..."
    if [ -f "build/libs/jboss-kitchensink.jar" ]; then
        echo "Found JAR in: build/libs/jboss-kitchensink.jar"
        echo "Copying to target/ for Docker..."
        mkdir -p target
        cp build/libs/jboss-kitchensink.jar target/jboss-kitchensink.jar
        echo -e "${GREEN}✅ JAR copied successfully${NC}"
    else
        echo "JAR not found in either location"
        exit 1
    fi
fi

cd ..

# Step 2: Stop existing backend container
echo ""
echo -e "${YELLOW}[Step 2/3]${NC} Stopping existing backend container (if any)..."
docker compose -f docker-compose-backend-prebuilt.yml down 2>/dev/null || true

# Step 3: Build and launch Docker container
echo ""
echo -e "${YELLOW}[Step 3/3]${NC} Building and launching Docker container..."
docker compose -f docker-compose-backend-prebuilt.yml up -d --build

# Wait for container to start
echo ""
echo "Waiting for backend to become healthy..."
sleep 5

# Check container status
if docker ps | grep -q kitchensink-backend; then
    echo -e "${GREEN}✅ Backend container started${NC}"
    echo ""
    echo "Container name: kitchensink-backend"
    echo "Backend API: http://localhost:8080"
    echo "Health check: http://localhost:8080/actuator/health"
    echo ""
    echo "View logs:"
    echo "  docker compose -f docker-compose-backend-prebuilt.yml logs -f backend"
    echo ""
    echo "Stop backend:"
    echo "  docker compose -f docker-compose-backend-prebuilt.yml down"
else
    echo -e "${RED}❌ Backend container failed to start${NC}"
    echo ""
    echo "View logs:"
    echo "  docker compose -f docker-compose-backend-prebuilt.yml logs backend"
    exit 1
fi

echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}Backend started successfully!${NC}"
echo -e "${GREEN}============================================${NC}"
