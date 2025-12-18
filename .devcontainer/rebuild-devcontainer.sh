#!/bin/bash

# Script to safely rebuild .devcontainer without conflicts
# Usage: ./rebuild-devcontainer.sh

set -e

echo "🔄 Rebuilding .devcontainer safely..."

# Stop and remove containers if they exist
echo "📦 Stopping existing containers..."
docker-compose -f .devcontainer/docker-compose.yml down --remove-orphans 2>/dev/null || true

# Remove any dangling containers with our naming pattern
echo "🧹 Cleaning up any remaining containers..."
docker rm -f kitchensink-workspace kitchensink-mysql kitchensink-backend kitchensink-frontend 2>/dev/null || true

# Rebuild the workspace container specifically
echo "🏗️  Rebuilding workspace container..."
docker-compose -f .devcontainer/docker-compose.yml build --no-cache workspace

# Start all services
echo "🚀 Starting all services..."
docker-compose -f .devcontainer/docker-compose.yml up -d

echo "✅ Rebuild complete! Your .devcontainer is ready."
echo "💡 You can now reopen the workspace in the container."