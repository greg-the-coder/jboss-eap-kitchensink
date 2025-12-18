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

# Detect build tool and build
if [ -f "./gradlew" ]; then
    echo "Using Gradle..."
    ./gradlew clean build -x test
    
    # Gradle puts JAR in build/libs/, Docker expects it in target/
    mkdir -p target
    if [ -f "build/libs/jboss-kitchensink.jar" ]; then
        cp build/libs/jboss-kitchensink.jar target/jboss-kitchensink.jar
        echo ""
        echo -e "${GREEN}✅ Copied JAR from build/libs/ to target/${NC}"
    fi
elif [ -f "pom.xml" ]; then
    echo "Using Maven..."
    mvn clean package -DskipTests
    echo ""
else
    echo -e "${RED}Error: No build tool found${NC}"
    echo "Expected: ./gradlew or pom.xml"
    exit 1
fi

# Verify JAR exists
if [ ! -f "target/jboss-kitchensink.jar" ]; then
    echo -e "${RED}❌ JAR not found in target/${NC}"
    
    # Check alternative location
    if [ -f "build/libs/jboss-kitchensink.jar" ]; then
        echo "Found in build/libs/, copying..."
        mkdir -p target
        cp build/libs/jboss-kitchensink.jar target/jboss-kitchensink.jar
    else
        echo "Build failed - JAR not created"
        exit 1
    fi
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
