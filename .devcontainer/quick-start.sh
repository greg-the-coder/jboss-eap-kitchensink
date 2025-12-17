#!/bin/bash

# Quick Start Script for JBoss EAP Kitchensink Spring Boot Development
# This script helps you get started quickly with common development tasks

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Project directory
PROJECT_DIR="/workspace/kitchensink"

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}   JBoss EAP Kitchensink Spring Boot - Quick Start${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Function to print status
print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${YELLOW}ℹ${NC} $1"
}

# Check if we're in the right directory
if [ ! -d "$PROJECT_DIR" ]; then
    print_error "Project directory not found at $PROJECT_DIR"
    exit 1
fi

cd "$PROJECT_DIR"

# Main menu
show_menu() {
    echo ""
    echo -e "${YELLOW}What would you like to do?${NC}"
    echo ""
    echo "  1) 🏗️  Build the application (Gradle)"
    echo "  2) 🧪 Run tests"
    echo "  3) 🚀 Run application (Dev profile with H2)"
    echo "  4) 🗄️  Run application (Prod profile with MySQL)"
    echo "  5) 🐳 Start MySQL database"
    echo "  6) 🛑 Stop MySQL database"
    echo "  7) 📊 Check database status"
    echo "  8) 🧹 Clean build artifacts"
    echo "  9) 📦 Build Docker image"
    echo " 10) 🔍 View application logs"
    echo " 11) 🩺 Check application health"
    echo " 12) 📚 Show environment info"
    echo "  0) 👋 Exit"
    echo ""
    echo -n "Enter your choice [0-12]: "
}

# Function implementations
build_app() {
    print_info "Building application with Gradle..."
    ./gradlew clean build -x test
    print_status "Build completed successfully!"
}

run_tests() {
    print_info "Running tests..."
    ./gradlew test
    print_status "Tests completed!"
}

run_dev() {
    print_info "Starting application with Dev profile (H2 database)..."
    print_info "Application will be available at http://localhost:8080"
    print_info "Press Ctrl+C to stop"
    ./gradlew bootRun --args='--spring.profiles.active=dev'
}

run_prod() {
    print_info "Starting application with Prod profile (MySQL database)..."
    
    # Check if MySQL is running
    if ! docker-compose -f /workspace/.devcontainer/docker-compose.yml ps | grep -q "mysql.*Up"; then
        print_error "MySQL is not running. Starting MySQL..."
        docker-compose -f /workspace/.devcontainer/docker-compose.yml up -d mysql
        print_info "Waiting for MySQL to be ready..."
        sleep 10
    fi
    
    print_info "Application will be available at http://localhost:8080"
    print_info "Press Ctrl+C to stop"
    ./gradlew bootRun --args='--spring.profiles.active=prod'
}

start_mysql() {
    print_info "Starting MySQL database..."
    docker-compose -f /workspace/.devcontainer/docker-compose.yml up -d mysql
    print_info "Waiting for MySQL to be ready..."
    sleep 5
    print_status "MySQL is running on port 3306"
    print_info "Connection: mysql -h localhost -u kitchensink -pkitchensink kitchensink"
}

stop_mysql() {
    print_info "Stopping MySQL database..."
    docker-compose -f /workspace/.devcontainer/docker-compose.yml stop mysql
    print_status "MySQL stopped"
}

check_db_status() {
    print_info "Checking database status..."
    echo ""
    docker-compose -f /workspace/.devcontainer/docker-compose.yml ps
    echo ""
}

clean_build() {
    print_info "Cleaning build artifacts..."
    ./gradlew clean
    rm -rf build/
    print_status "Build artifacts cleaned"
}

build_docker() {
    print_info "Building Docker image..."
    docker build -t kitchensink:latest .
    print_status "Docker image built successfully!"
    print_info "Run with: docker run -p 8080:8080 kitchensink:latest"
}

view_logs() {
    print_info "Viewing application logs (if running in background)..."
    print_info "Press Ctrl+C to exit log view"
    sleep 2
    tail -f build/logs/*.log 2>/dev/null || echo "No log files found. Run the application first."
}

check_health() {
    print_info "Checking application health..."
    if curl -s http://localhost:8080/actuator/health > /dev/null; then
        print_status "Application is healthy!"
        curl -s http://localhost:8080/actuator/health | jq . || curl -s http://localhost:8080/actuator/health
    else
        print_error "Application is not responding. Is it running?"
    fi
}

show_env_info() {
    print_info "Environment Information:"
    echo ""
    echo -e "${BLUE}Java:${NC}"
    java -version 2>&1 | head -n 3
    echo ""
    echo -e "${BLUE}Gradle:${NC}"
    ./gradlew --version | grep "Gradle" | head -n 1
    echo ""
    echo -e "${BLUE}Docker:${NC}"
    docker --version
    echo ""
    echo -e "${BLUE}Environment Variables:${NC}"
    echo "  JAVA_HOME: $JAVA_HOME"
    echo "  GRADLE_HOME: $GRADLE_HOME"
    echo "  SPRING_PROFILES_ACTIVE: ${SPRING_PROFILES_ACTIVE:-not set}"
    echo ""
}

# Main loop
while true; do
    show_menu
    read -r choice
    
    case $choice in
        1) build_app ;;
        2) run_tests ;;
        3) run_dev ;;
        4) run_prod ;;
        5) start_mysql ;;
        6) stop_mysql ;;
        7) check_db_status ;;
        8) clean_build ;;
        9) build_docker ;;
        10) view_logs ;;
        11) check_health ;;
        12) show_env_info ;;
        0) 
            print_status "Goodbye!"
            exit 0
            ;;
        *)
            print_error "Invalid option. Please try again."
            ;;
    esac
    
    echo ""
    echo -e "${YELLOW}Press Enter to continue...${NC}"
    read -r
done
