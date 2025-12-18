# .devcontainer Rebuild Guide

## Problem
When rebuilding the .devcontainer after it's running, you encounter container name conflicts because Docker Compose tries to create containers with names that already exist.

## Solutions

### Option 1: Use the Rebuild Script (Recommended)
```bash
cd /workspace
./.devcontainer/rebuild-devcontainer.sh
```

This script:
- Stops all existing containers
- Removes orphaned containers
- Cleans up any remaining containers with our naming pattern
- Rebuilds the workspace container
- Starts all services fresh

### Option 2: Manual Docker Compose Commands
```bash
# Stop and remove all containers
docker-compose -f .devcontainer/docker-compose.yml down --remove-orphans

# Rebuild specific service (workspace container)
docker-compose -f .devcontainer/docker-compose.yml build --no-cache workspace

# Start all services
docker-compose -f .devcontainer/docker-compose.yml up -d
```

### Option 3: VS Code Command Palette
1. Open Command Palette (`Ctrl+Shift+P` / `Cmd+Shift+P`)
2. Run "Dev Containers: Rebuild Container"
3. This will handle the cleanup automatically

## What Was Fixed

1. **Added explicit container names** to prevent Docker from generating conflicting default names
2. **Added project name** (`kitchensink-devcontainer`) to namespace all containers
3. **Created cleanup script** to handle the rebuild process safely

## Container Names
- `kitchensink-workspace` - Development workspace
- `kitchensink-mysql` - MySQL database
- `kitchensink-backend` - Spring Boot backend
- `kitchensink-frontend` - Next.js frontend

## Persistent Data
Named volumes will persist across rebuilds:
- `mysql-data` - Database data
- `gradle-cache` - Gradle build cache
- `maven-cache` - Maven dependencies
- `npm-cache` - NPM packages