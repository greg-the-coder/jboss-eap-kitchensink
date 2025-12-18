#!/bin/bash

# Setup port forwarding for devcontainer services
# This script creates local proxies to forward requests to service containers

echo "Setting up port forwarding for devcontainer services..."

# Install socat if not available (for port forwarding)
if ! command -v socat &> /dev/null; then
    echo "Installing socat for port forwarding..."
    apt-get update && apt-get install -y socat
fi

# Function to start port forwarding
start_proxy() {
    local local_port=$1
    local target_host=$2
    local target_port=$3
    local service_name=$4
    
    echo "Starting proxy: localhost:$local_port -> $target_host:$target_port ($service_name)"
    
    # Kill existing proxy if running
    pkill -f "socat.*:$local_port"
    
    # Start new proxy in background
    socat TCP-LISTEN:$local_port,fork,reuseaddr TCP:$target_host:$target_port &
    
    # Store PID for cleanup
    echo $! > /tmp/proxy_${local_port}.pid
}

# Start proxies for each service
start_proxy 3000 frontend 3000 "Frontend"
start_proxy 8080 backend 8080 "Backend" 
start_proxy 5005 backend 5005 "Java Debug"

echo "Port forwarding setup complete!"
echo "Services available at:"
echo "  Frontend: http://localhost:3000"
echo "  Backend:  http://localhost:8080"
echo "  Debug:    localhost:5005"
echo ""
echo "Direct service access:"
echo "  Frontend: http://frontend:3000"
echo "  Backend:  http://backend:8080"
echo "  MySQL:    mysql:3306"