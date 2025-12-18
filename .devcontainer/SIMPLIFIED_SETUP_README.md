# Simplified DevContainer Setup

## Overview

The DevContainer has been simplified to only auto-start the MySQL database. Backend and Frontend applications are launched manually using separate Docker Compose files.

---

## What Auto-Starts

When you open this project in VS Code Dev Container, the following start automatically:

1. **Workspace Container** - Development environment with all tools
2. **MySQL Database** - Running on port 3306

---

## What Needs Manual Launch

The following services are NOT auto-started and must be launched manually:

1. **Backend (Spring Boot)** - Launch via `docker-compose-backend.yml`
2. **Frontend (Next.js)** - Launch via `docker-compose-frontend.yml`

---

## Changes Made

### `.devcontainer/docker-compose.yml`

**Before** (Auto-started):
- ✅ Workspace
- ✅ MySQL
- ✅ PostgreSQL
- ✅ Backend
- ✅ Frontend

**After** (Auto-started):
- ✅ Workspace  
- ✅ MySQL only

**Removed**:
- ❌ PostgreSQL container
- ❌ Backend container
- ❌ Frontend container

### New Files Created

1. **`docker-compose-backend.yml`** - Launches Spring Boot backend
2. **`docker-compose-frontend.yml`** - Launches Next.js frontend
3. **`LAUNCH_INSTRUCTIONS.md`** - Comprehensive launch guide
4. **`QUICKSTART.md`** - Quick reference guide

---

## Benefits of This Approach

### 1. **Faster Startup**
- DevContainer opens quickly (only MySQL needs to be healthy)
- No waiting for backend/frontend to build and start
- Reduced initial resource usage

### 2. **Flexibility**
- Launch only what you need (backend only, frontend only, or both)
- Easier to restart individual services
- Better for debugging specific components

### 3. **Resource Management**
- Reduced memory and CPU usage when not running all services
- More control over container lifecycle
- Easier to rebuild individual services

### 4. **Development Workflow**
- Backend developers can work without starting frontend
- Frontend developers can work with a mock API
- Better separation of concerns

---

## How to Launch

### Quick Start

```bash
# 1. Dev Container opens automatically (MySQL starts)
# 2. Launch backend
docker compose -f docker-compose-backend.yml up -d

# 3. Launch frontend  
docker compose -f docker-compose-frontend.yml up -d

# 4. Access apps
# Frontend: http://localhost:3000
# Backend: http://localhost:8080
```

### Detailed Instructions

See [LAUNCH_INSTRUCTIONS.md](../LAUNCH_INSTRUCTIONS.md) for comprehensive guide.

See [QUICKSTART.md](../QUICKSTART.md) for quick reference.

---

## Network Configuration

All services connect to the same Docker network: `devcontainer_kitchensink-network`

This allows:
- Backend to communicate with MySQL
- Frontend to communicate with Backend
- All services to discover each other by container name

---

## Port Mappings

| Service | Internal Port | External Port | Auto-Start |
|---------|---------------|---------------|------------|
| MySQL | 3306 | 3306 | ✅ Yes |
| Backend | 8080 | 8080 | ❌ Manual |
| Frontend | 3000 | 3000 | ❌ Manual |
| Java Debug | 5005 | 5005 | ❌ Manual |

---

## Troubleshooting

### Backend Won't Start

Ensure MySQL is healthy:
```bash
docker ps | grep mysql
```

Expected: `Up X minutes (healthy)`

### Frontend Won't Start

Ensure backend is running:
```bash
curl http://localhost:8080/actuator/health
```

Expected: `{"status":"UP"}`

### Network Issues

Verify network exists:
```bash
docker network inspect devcontainer_kitchensink-network
```

---

## Reverting to Auto-Start (If Needed)

If you prefer all services to auto-start:

1. Restore the old `.devcontainer/docker-compose.yml` from git history
2. Rebuild Dev Container

---

**Last Updated**: December 18, 2025  
**Purpose**: Simplified development environment startup  
**Status**: ✅ Active Configuration
