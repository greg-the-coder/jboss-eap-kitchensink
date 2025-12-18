# Kitchensink Application - Launch Instructions

This document provides step-by-step instructions for launching the Backend and Frontend applications separately using Docker Compose.

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Prerequisites](#prerequisites)
3. [Quick Start](#quick-start)
4. [Launching Backend](#launching-backend)
5. [Launching Frontend](#launching-frontend)
6. [Stopping Services](#stopping-services)
7. [Troubleshooting](#troubleshooting)
8. [Advanced Configuration](#advanced-configuration)

---

## Architecture Overview

The application is structured in three tiers:

```
┌─────────────────────────────────────────────────────────┐
│                    Development Setup                     │
├─────────────────────────────────────────────────────────┤
│                                                           │
│  .devcontainer (Auto-starts)                             │
│  ├── Workspace Container (Development environment)       │
│  └── MySQL Database (Port 3306)                          │
│                                                           │
│  Backend (Manual start via docker-compose-backend.yml)   │
│  └── Spring Boot API (Port 8080)                         │
│                                                           │
│  Frontend (Manual start via docker-compose-frontend.yml) │
│  └── Next.js UI (Port 3000)                              │
│                                                           │
└─────────────────────────────────────────────────────────┘
```

### Network Architecture

All services connect to a shared Docker network: `devcontainer_kitchensink-network`

- **MySQL**: `mysql:3306` (internal) / `localhost:3306` (external)
- **Backend**: `backend:8080` (internal) / `localhost:8080` (external)
- **Frontend**: `frontend:3000` (internal) / `localhost:3000` (external)

---

## Prerequisites

### Required Software

- **Docker Desktop** 20.10+ or **Docker Engine** with Docker Compose
- **VS Code** with Dev Containers extension (for development)
- **Git** (for cloning the repository)

### System Requirements

- **OS**: Linux, macOS, or Windows with WSL2
- **RAM**: 4GB minimum, 8GB recommended
- **Disk**: 10GB free space
- **CPU**: 2 cores minimum, 4 cores recommended

### Verify Installation

```bash
# Check Docker version
docker --version
# Expected: Docker version 20.10.0 or higher

# Check Docker Compose version
docker compose version
# Expected: Docker Compose version v2.0.0 or higher

# Verify Docker is running
docker ps
# Should show running containers or empty list
```

---

## Quick Start

### 1. Open in VS Code Dev Container

The Dev Container automatically starts the MySQL database:

```bash
# Open VS Code in the project directory
code ~/projects/jboss-eap-kitchensink

# VS Code will prompt to "Reopen in Container"
# Click "Reopen in Container"
```

Wait for the dev container to build and start. This includes:
- ✅ Workspace container
- ✅ MySQL database

### 2. Launch Backend

From within the VS Code terminal (inside the dev container):

```bash
# Launch backend
docker compose -f docker-compose-backend.yml up -d

# Check backend status
docker compose -f docker-compose-backend.yml ps

# View backend logs
docker compose -f docker-compose-backend.yml logs -f backend
```

### 3. Launch Frontend

From within the VS Code terminal (inside the dev container):

```bash
# Launch frontend
docker compose -f docker-compose-frontend.yml up -d

# Check frontend status
docker compose -f docker-compose-frontend.yml ps

# View frontend logs
docker compose -f docker-compose-frontend.yml logs -f frontend
```

### 4. Access Applications

- **Frontend UI**: http://localhost:3000
- **Backend API**: http://localhost:8080/rest/members
- **API Health**: http://localhost:8080/actuator/health
- **MySQL**: `localhost:3306` (user: `kitchensink`, password: `kitchensink`)

---

## Launching Backend

### Option 1: Using Docker Compose (Recommended)

#### Step 1: Ensure MySQL is Running

The MySQL database starts automatically with the Dev Container. Verify it's running:

```bash
docker ps | grep mysql
```

Expected output:
```
devcontainer-mysql-1   mysql:8.0   Up X minutes (healthy)
```

#### Step 2: Build and Start Backend

```bash
# From project root
cd ~/projects/jboss-eap-kitchensink

# Build and start in detached mode
docker compose -f docker-compose-backend.yml up -d --build

# Or start without rebuilding
docker compose -f docker-compose-backend.yml up -d
```

#### Step 3: Verify Backend is Running

```bash
# Check container status
docker compose -f docker-compose-backend.yml ps

# Expected output:
# NAME                   IMAGE              STATUS
# kitchensink-backend    ...                Up X seconds (healthy)

# View logs
docker compose -f docker-compose-backend.yml logs -f backend

# Test health endpoint
curl http://localhost:8080/actuator/health

# Expected response:
# {"status":"UP","groups":["liveness","readiness"]}

# Test API endpoint
curl http://localhost:8080/rest/members

# Expected response:
# [] (empty array on first start)
```

### Option 2: Building JAR and Running Locally

If you prefer to run the backend outside Docker:

```bash
# Navigate to backend directory
cd ~/projects/jboss-eap-kitchensink/kitchensink

# Build with Gradle
./gradlew clean build

# Or build with Maven
# mvn clean package

# Run the JAR
java -jar build/libs/jboss-kitchensink-*.jar

# Or with Maven
# java -jar target/jboss-kitchensink.jar
```

### Backend Environment Variables

The backend uses these environment variables (configured in `docker-compose-backend.yml`):

| Variable | Default Value | Description |
|----------|---------------|-------------|
| `SPRING_PROFILES_ACTIVE` | `dev` | Spring profile (dev/prod) |
| `SPRING_DATASOURCE_URL` | `jdbc:mysql://mysql:3306/kitchensink` | Database URL |
| `SPRING_DATASOURCE_USERNAME` | `kitchensink` | Database username |
| `SPRING_DATASOURCE_PASSWORD` | `kitchensink` | Database password |
| `SPRING_JPA_HIBERNATE_DDL_AUTO` | `update` | Hibernate DDL mode |
| `JAVA_OPTS` | Debug settings | JVM options |

### Backend Ports

| Port | Service | Description |
|------|---------|-------------|
| `8080` | Spring Boot | REST API |
| `5005` | Java Debug | Remote debugging |

---

## Launching Frontend

### Option 1: Using Docker Compose (Recommended)

#### Step 1: Ensure Backend is Running

The frontend requires the backend API. Verify it's running:

```bash
curl http://localhost:8080/actuator/health
```

Expected response:
```json
{"status":"UP","groups":["liveness","readiness"]}
```

#### Step 2: Build and Start Frontend

```bash
# From project root
cd ~/projects/jboss-eap-kitchensink

# Build and start in detached mode
docker compose -f docker-compose-frontend.yml up -d --build

# Or start without rebuilding
docker compose -f docker-compose-frontend.yml up -d
```

#### Step 3: Verify Frontend is Running

```bash
# Check container status
docker compose -f docker-compose-frontend.yml ps

# Expected output:
# NAME                    IMAGE              STATUS
# kitchensink-frontend    ...                Up X seconds (healthy)

# View logs
docker compose -f docker-compose-frontend.yml logs -f frontend

# Test frontend health endpoint
curl http://localhost:3000/api/health

# Expected response:
# {"status":"UP","timestamp":"...","service":"kitchensink-frontend"}

# Test frontend UI (opens in browser)
open http://localhost:3000
```

### Option 2: Running in Development Mode

For active development with hot reload:

```bash
# Navigate to frontend directory
cd ~/projects/jboss-eap-kitchensink/frontend

# Install dependencies (first time only)
npm install

# Run in development mode
npm run dev

# Frontend will be available at http://localhost:3000
# Changes to code will automatically reload
```

### Frontend Environment Variables

The frontend uses these environment variables (configured in `docker-compose-frontend.yml`):

| Variable | Default Value | Description |
|----------|---------------|-------------|
| `NEXT_PUBLIC_API_URL` | `http://localhost:8080` | Backend API URL |
| `NODE_ENV` | `production` | Node environment |

### Frontend Ports

| Port | Service | Description |
|------|---------|-------------|
| `3000` | Next.js | Web UI |

---

## Stopping Services

### Stop Backend

```bash
# Stop backend container
docker compose -f docker-compose-backend.yml down

# Stop and remove volumes (⚠️ This deletes data)
docker compose -f docker-compose-backend.yml down -v
```

### Stop Frontend

```bash
# Stop frontend container
docker compose -f docker-compose-frontend.yml down

# Stop and remove volumes
docker compose -f docker-compose-frontend.yml down -v
```

### Stop All Services

```bash
# Stop backend and frontend
docker compose -f docker-compose-backend.yml down
docker compose -f docker-compose-frontend.yml down

# MySQL is managed by .devcontainer
# To stop MySQL, close the Dev Container in VS Code
```

### Complete Cleanup

```bash
# Stop all containers
docker compose -f docker-compose-backend.yml down
docker compose -f docker-compose-frontend.yml down

# Remove images
docker compose -f docker-compose-backend.yml down --rmi all
docker compose -f docker-compose-frontend.yml down --rmi all

# Remove volumes (⚠️ This deletes all data)
docker compose -f docker-compose-backend.yml down -v
docker compose -f docker-compose-frontend.yml down -v
```

---

## Troubleshooting

### Backend Issues

#### Backend Container Won't Start

**Symptom**: Backend container exits immediately or shows "unhealthy" status

**Solutions**:

1. Check if MySQL is running:
   ```bash
   docker ps | grep mysql
   ```

2. View backend logs:
   ```bash
   docker compose -f docker-compose-backend.yml logs backend
   ```

3. Common issues:
   - **Database connection refused**: Ensure MySQL is healthy
   - **Port 8080 already in use**: Stop conflicting process or change port
   - **Build failed**: Check build logs for compilation errors

4. Rebuild from scratch:
   ```bash
   docker compose -f docker-compose-backend.yml down
   docker compose -f docker-compose-backend.yml build --no-cache
   docker compose -f docker-compose-backend.yml up -d
   ```

#### Cannot Connect to Database

**Symptom**: Backend logs show database connection errors

**Solutions**:

1. Verify MySQL is healthy:
   ```bash
   docker exec devcontainer-mysql-1 mysqladmin ping -h localhost -u root -proot
   ```

2. Check database credentials:
   ```bash
   docker exec -it devcontainer-mysql-1 mysql -u kitchensink -pkitchensink -e "SHOW DATABASES;"
   ```

3. Verify network connectivity:
   ```bash
   docker exec kitchensink-backend ping -c 3 mysql
   ```

4. Reset database:
   ```bash
   docker compose -f .devcontainer/docker-compose.yml down mysql -v
   docker compose -f .devcontainer/docker-compose.yml up -d mysql
   ```

#### API Returns 500 Errors

**Symptom**: API endpoints return Internal Server Error

**Solutions**:

1. Check backend logs:
   ```bash
   docker compose -f docker-compose-backend.yml logs -f backend
   ```

2. Test health endpoint:
   ```bash
   curl http://localhost:8080/actuator/health
   ```

3. Verify database schema:
   ```bash
   docker exec -it devcontainer-mysql-1 mysql -u kitchensink -pkitchensink -e "USE kitchensink; SHOW TABLES;"
   ```

### Frontend Issues

#### Frontend Container Won't Start

**Symptom**: Frontend container exits immediately or shows "unhealthy" status

**Solutions**:

1. View frontend logs:
   ```bash
   docker compose -f docker-compose-frontend.yml logs frontend
   ```

2. Common issues:
   - **Port 3000 already in use**: Stop conflicting process or change port
   - **Build failed**: Check Node.js build errors in logs
   - **Environment variables**: Verify `NEXT_PUBLIC_API_URL` is set correctly

3. Rebuild from scratch:
   ```bash
   docker compose -f docker-compose-frontend.yml down
   docker compose -f docker-compose-frontend.yml build --no-cache
   docker compose -f docker-compose-frontend.yml up -d
   ```

#### Cannot Connect to Backend API

**Symptom**: Frontend shows "Failed to fetch" or "Network error"

**Solutions**:

1. Verify backend is running:
   ```bash
   curl http://localhost:8080/actuator/health
   ```

2. Check CORS configuration:
   ```bash
   curl -H "Origin: http://localhost:3000" \
        -H "Access-Control-Request-Method: GET" \
        -X OPTIONS \
        http://localhost:8080/rest/members -v
   ```

3. Verify network connectivity:
   ```bash
   docker exec kitchensink-frontend wget -O- http://backend:8080/actuator/health
   ```

4. Check browser console for errors:
   - Open browser DevTools (F12)
   - Check Console tab for JavaScript errors
   - Check Network tab for failed requests

#### Page Shows Loading Forever

**Symptom**: Frontend page loads but shows spinning loader indefinitely

**Solutions**:

1. Open browser DevTools (F12) and check:
   - **Console tab**: Look for JavaScript errors
   - **Network tab**: Check if API calls are failing

2. Verify API endpoint manually:
   ```bash
   curl http://localhost:8080/rest/members
   ```

3. Check frontend logs:
   ```bash
   docker compose -f docker-compose-frontend.yml logs -f frontend
   ```

### Network Issues

#### Containers Can't Communicate

**Symptom**: Backend can't reach MySQL, or frontend can't reach backend

**Solutions**:

1. Verify all containers are on the same network:
   ```bash
   docker network inspect devcontainer_kitchensink-network
   ```

2. Check network connectivity:
   ```bash
   # Backend to MySQL
   docker exec kitchensink-backend ping -c 3 mysql
   
   # Frontend to Backend
   docker exec kitchensink-frontend wget -O- http://backend:8080/actuator/health
   ```

3. Recreate network:
   ```bash
   # Stop all services
   docker compose -f docker-compose-backend.yml down
   docker compose -f docker-compose-frontend.yml down
   
   # Recreate dev container (this recreates network)
   # Close and reopen VS Code Dev Container
   ```

### Port Conflicts

**Symptom**: "Port already in use" error when starting services

**Solutions**:

1. Find process using the port:
   ```bash
   # For port 8080 (backend)
   lsof -i :8080
   
   # For port 3000 (frontend)
   lsof -i :3000
   
   # For port 3306 (MySQL)
   lsof -i :3306
   ```

2. Stop conflicting process:
   ```bash
   # Kill process by PID
   kill -9 <PID>
   ```

3. Or change port in docker-compose file:
   ```yaml
   ports:
     - "8081:8080"  # Use port 8081 instead of 8080
   ```

### Performance Issues

#### Slow Container Startup

**Solutions**:

1. Increase Docker resources:
   - Docker Desktop → Settings → Resources
   - Increase CPU, Memory, Disk

2. Use cached builds:
   ```bash
   # Build without cache only when needed
   docker compose build --no-cache
   
   # Normal builds use cache
   docker compose build
   ```

3. Optimize Dockerfile:
   - Use multi-stage builds (already implemented)
   - Minimize layers
   - Cache dependencies

#### High CPU/Memory Usage

**Solutions**:

1. Monitor resource usage:
   ```bash
   docker stats
   ```

2. Adjust JVM memory (backend):
   ```yaml
   # In docker-compose-backend.yml
   environment:
     JAVA_OPTS: "-Xmx512m -Xms256m"
   ```

3. Adjust Node.js memory (frontend):
   ```yaml
   # In docker-compose-frontend.yml
   environment:
     NODE_OPTIONS: "--max-old-space-size=512"
   ```

---

## Advanced Configuration

### Custom Environment Variables

#### Backend Configuration

Create a `.env.backend` file:

```env
SPRING_PROFILES_ACTIVE=dev
SPRING_DATASOURCE_URL=jdbc:mysql://mysql:3306/kitchensink
SPRING_DATASOURCE_USERNAME=kitchensink
SPRING_DATASOURCE_PASSWORD=kitchensink
SPRING_JPA_HIBERNATE_DDL_AUTO=update
JAVA_OPTS=-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005
```

Use it:

```bash
docker compose -f docker-compose-backend.yml --env-file .env.backend up -d
```

#### Frontend Configuration

Create a `.env.frontend` file:

```env
NEXT_PUBLIC_API_URL=http://localhost:8080
NODE_ENV=production
```

Use it:

```bash
docker compose -f docker-compose-frontend.yml --env-file .env.frontend up -d
```

### Remote Debugging

#### Backend (Java)

1. Start backend with debug port enabled (already configured):
   ```bash
   docker compose -f docker-compose-backend.yml up -d
   ```

2. Connect from IDE:
   - **VS Code**: Use "Attach to Remote Java" configuration
   - **IntelliJ IDEA**: Run → Edit Configurations → Remote JVM Debug
   - **Host**: `localhost`
   - **Port**: `5005`

3. Set breakpoints and debug!

#### Frontend (Node.js)

1. Start frontend in development mode:
   ```bash
   cd frontend
   npm run dev
   ```

2. Debug in VS Code:
   - Press F5
   - Select "Next.js: debug full stack"

### Production Deployment

For production deployment, use environment-specific configuration:

#### Backend Production

```yaml
# docker-compose-backend-prod.yml
version: '3.8'
services:
  backend:
    image: kitchensink-backend:latest
    environment:
      SPRING_PROFILES_ACTIVE: prod
      SPRING_DATASOURCE_URL: ${DATABASE_URL}
      SPRING_DATASOURCE_USERNAME: ${DATABASE_USERNAME}
      SPRING_DATASOURCE_PASSWORD: ${DATABASE_PASSWORD}
      JAVA_OPTS: "-Xmx1g -Xms512m"
    ports:
      - "8080:8080"
    restart: always
```

Deploy:

```bash
docker compose -f docker-compose-backend-prod.yml up -d
```

#### Frontend Production

```yaml
# docker-compose-frontend-prod.yml
version: '3.8'
services:
  frontend:
    image: kitchensink-frontend:latest
    environment:
      NEXT_PUBLIC_API_URL: https://api.yourdomain.com
      NODE_ENV: production
    ports:
      - "3000:3000"
    restart: always
```

Deploy:

```bash
docker compose -f docker-compose-frontend-prod.yml up -d
```

### Health Checks and Monitoring

#### Manual Health Checks

```bash
# Backend health
curl http://localhost:8080/actuator/health

# Backend detailed health
curl http://localhost:8080/actuator/health/readiness
curl http://localhost:8080/actuator/health/liveness

# Frontend health
curl http://localhost:3000/api/health
```

#### Automated Monitoring

Use Docker's built-in health checks (already configured):

```bash
# Check health status
docker inspect kitchensink-backend | jq '.[0].State.Health'
docker inspect kitchensink-frontend | jq '.[0].State.Health'
```

#### Prometheus Metrics (Backend)

Spring Boot Actuator exposes Prometheus metrics:

```bash
# View metrics
curl http://localhost:8080/actuator/prometheus
```

### Database Management

#### Access MySQL CLI

```bash
# Connect to MySQL
docker exec -it devcontainer-mysql-1 mysql -u kitchensink -pkitchensink

# Or as root
docker exec -it devcontainer-mysql-1 mysql -u root -proot
```

#### Backup Database

```bash
# Backup to file
docker exec devcontainer-mysql-1 mysqldump -u root -proot kitchensink > backup.sql

# Restore from file
docker exec -i devcontainer-mysql-1 mysql -u root -proot kitchensink < backup.sql
```

#### Reset Database

```bash
# Drop and recreate database
docker exec devcontainer-mysql-1 mysql -u root -proot -e "DROP DATABASE IF EXISTS kitchensink; CREATE DATABASE kitchensink;"

# Restart backend to recreate schema
docker compose -f docker-compose-backend.yml restart backend
```

---

## Summary

### Startup Sequence

1. **Dev Container** (automatic)
   - Workspace container starts
   - MySQL database starts and becomes healthy

2. **Backend** (manual)
   ```bash
   docker compose -f docker-compose-backend.yml up -d
   ```

3. **Frontend** (manual)
   ```bash
   docker compose -f docker-compose-frontend.yml up -d
   ```

### Access Points

| Service | URL | Description |
|---------|-----|-------------|
| Frontend | http://localhost:3000 | Web UI |
| Backend API | http://localhost:8080/rest/members | REST API |
| Health Check | http://localhost:8080/actuator/health | API Health |
| MySQL | localhost:3306 | Database |

### Key Commands

```bash
# Start backend
docker compose -f docker-compose-backend.yml up -d

# Start frontend
docker compose -f docker-compose-frontend.yml up -d

# View logs
docker compose -f docker-compose-backend.yml logs -f backend
docker compose -f docker-compose-frontend.yml logs -f frontend

# Stop services
docker compose -f docker-compose-backend.yml down
docker compose -f docker-compose-frontend.yml down

# Rebuild
docker compose -f docker-compose-backend.yml up -d --build
docker compose -f docker-compose-frontend.yml up -d --build
```

---

## Additional Resources

- [Spring Boot Documentation](https://spring.io/projects/spring-boot)
- [Next.js Documentation](https://nextjs.org/docs)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [VS Code Dev Containers](https://code.visualstudio.com/docs/devcontainers/containers)

---

**Last Updated**: December 18, 2025  
**Version**: 1.0.0  
**Status**: ✅ Production Ready
