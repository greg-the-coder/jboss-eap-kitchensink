#!/bin/bash

# Script to ONLY build the Spring Boot JAR locally
# Use this before running docker-compose-backend-prebuilt.yml manually

set -e

echo "============================================"
echo "Spring Boot Backend - JAR Build Only"
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
    echo ""
    echo "Usage: ./build-backend-jar.sh"
    exit 1
fi

# Build JAR
echo -e "${YELLOW}Building JAR...${NC}"
echo ""
cd kitchensink

# Build with Maven
if [ -f "pom.xml" ]; then
    echo "Using Maven..."
    mvn clean package -DskipTests
    echo ""
else
    echo -e "${RED}Error: pom.xml not found${NC}"
    echo "Expected: pom.xml in kitchensink directory"
    exit 1
fi

# Verify JAR exists
if [ ! -f "target/jboss-kitchensink.jar" ]; then
    echo -e "${RED}❌ JAR not found in target/${NC}"
    echo "Build failed - JAR not created"
    exit 1
fi

# Success
JAR_SIZE=$(du -h target/jboss-kitchensink.jar | cut -f1)
echo ""
echo "============================================"
echo -e "${GREEN}✅ JAR built successfully!${NC}"
echo "============================================"
echo ""
echo "JAR Location: kitchensink/target/jboss-kitchensink.jar"
echo "JAR Size: $JAR_SIZE"
echo ""
echo "Next steps:"
echo "  1. Launch backend:"
echo "     docker compose -f docker-compose-backend-prebuilt.yml up -d"
echo ""
echo "  2. Or use automated script:"
echo "     ./start-backend.sh"
echo ""
