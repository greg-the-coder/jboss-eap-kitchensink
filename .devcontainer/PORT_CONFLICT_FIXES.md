# Port Conflict Resolution

## Problem
The devcontainer was failing to start with port conflicts because multiple containers were trying to bind to the same host ports:

- `workspace` container: ports 3000, 8080, 5005
- `backend` container: ports 8080, 5005  
- `frontend` container: port 3000
- `mysql` container: port 3306

This caused Docker Compose to fail with "port already in use" errors.

## Root Cause
The `workspace` container was incorrectly configured to expose the same ports as the service containers, creating conflicts. The workspace container should only access services via the Docker network, not expose ports directly.

## Fixes Applied

### 1. Removed Duplicate Port Bindings
- Removed `ports` section from `workspace` container in `docker-compose.yml`
- Only service containers (`backend`, `frontend`, `mysql`) now expose ports to host

### 2. Removed Unnecessary Port Forwarding Script
- Removed `setup-port-forwarding.sh` from `postStartCommand` and `postCreateCommand`
- The script was creating socat proxies on already-bound ports, causing additional conflicts

### 3. Fixed Workspace Container Command
- Changed from `command: -c "sleep infinity"` to proper syntax
- Added `entrypoint: ["/bin/sh"]` and `command: ["-c", "sleep infinity"]`

### 4. Removed Obsolete Docker Compose Version
- Removed `version: '3.8'` to eliminate deprecation warnings

### 5. Removed Conflicting Docker Features
- Removed `docker-outside-of-docker` feature from `devcontainer.json`
- Removed conflicting mounts that were causing entrypoint conflicts
- Simplified devcontainer configuration to work with docker-compose setup

## Result
- All containers now start successfully without port conflicts
- Services are accessible at:
  - Frontend: http://localhost:3000
  - Backend: http://localhost:8080  
  - Debug: localhost:5005
  - MySQL: localhost:3306
- Workspace container can access services via Docker network (e.g., `http://backend:8080`)

## Architecture
```
Host Machine
├── Port 3000 → frontend container:3000
├── Port 8080 → backend container:8080
├── Port 5005 → backend container:5005
└── Port 3306 → mysql container:3306

Docker Network (kitchensink-network)
├── workspace ← accesses services via network
├── frontend:3000
├── backend:8080
└── mysql:3306
```

The workspace container now properly functions as a development environment that connects to services via the internal Docker network, while only the actual service containers expose ports to the host.