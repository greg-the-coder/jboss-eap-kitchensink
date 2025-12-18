# Quick Start Guide

This is a simplified guide to get the Kitchensink application running quickly.

---

## Prerequisites

- Docker Desktop installed and running
- VS Code with Dev Containers extension
- 4GB RAM minimum

---

## Step 1: Open in Dev Container

```bash
# Open VS Code
code ~/projects/jboss-eap-kitchensink
```

Click **"Reopen in Container"** when prompted.

✅ This automatically starts:
- Workspace container
- MySQL database (port 3306)

---

## Step 2: Launch Backend

From VS Code terminal:

```bash
# Option 1: Automated script (RECOMMENDED)
./start-backend.sh

# Option 2: Manual launch
docker compose -f docker-compose-backend.yml up -d
```

**⚠️ Getting Maven Central 403 errors?**  
Use Option 1 (`./start-backend.sh`) or see [BACKEND_LAUNCH_TROUBLESHOOTING.md](./BACKEND_LAUNCH_TROUBLESHOOTING.md)

Wait 60-90 seconds for backend to become healthy.

Verify:
```bash
curl http://localhost:8080/actuator/health
```

Expected: `{"status":"UP"}`

---

## Step 3: Launch Frontend

From VS Code terminal:

```bash
docker compose -f docker-compose-frontend.yml up -d
```

Wait 30-60 seconds for frontend to start.

Verify:
```bash
curl http://localhost:3000/api/health
```

Expected: `{"status":"UP",...}`

---

## Step 4: Access Application

Open your browser:

- **Frontend UI**: http://localhost:3000
- **Backend API**: http://localhost:8080/rest/members

---

## Common Commands

### View Logs

```bash
# Backend logs
docker compose -f docker-compose-backend.yml logs -f backend

# Frontend logs
docker compose -f docker-compose-frontend.yml logs -f frontend
```

### Restart Services

```bash
# Restart backend
docker compose -f docker-compose-backend.yml restart backend

# Restart frontend
docker compose -f docker-compose-frontend.yml restart frontend
```

### Stop Services

```bash
# Stop backend
docker compose -f docker-compose-backend.yml down

# Stop frontend
docker compose -f docker-compose-frontend.yml down
```

### Rebuild and Restart

```bash
# Rebuild backend
docker compose -f docker-compose-backend.yml up -d --build

# Rebuild frontend
docker compose -f docker-compose-frontend.yml up -d --build
```

---

## Troubleshooting

### Backend won't start

```bash
# Check if MySQL is running
docker ps | grep mysql

# View backend logs
docker compose -f docker-compose-backend.yml logs backend

# Rebuild backend
docker compose -f docker-compose-backend.yml down
docker compose -f docker-compose-backend.yml up -d --build
```

### Frontend won't start

```bash
# Check if backend is running
curl http://localhost:8080/actuator/health

# View frontend logs
docker compose -f docker-compose-frontend.yml logs frontend

# Rebuild frontend
docker compose -f docker-compose-frontend.yml down
docker compose -f docker-compose-frontend.yml up -d --build
```

### Port conflicts

```bash
# Find what's using port 8080
lsof -i :8080

# Find what's using port 3000
lsof -i :3000

# Kill process (replace <PID> with actual PID)
kill -9 <PID>
```

---

## Architecture

```
┌─────────────────────────────────────────┐
│         Development Environment          │
├─────────────────────────────────────────┤
│                                           │
│  .devcontainer (Auto-starts)             │
│  └── MySQL (Port 3306)                   │
│                                           │
│  Backend (Manual start)                  │
│  └── Spring Boot (Port 8080)             │
│                                           │
│  Frontend (Manual start)                 │
│  └── Next.js (Port 3000)                 │
│                                           │
└─────────────────────────────────────────┘
```

---

## Full Documentation

For detailed instructions, see [LAUNCH_INSTRUCTIONS.md](./LAUNCH_INSTRUCTIONS.md)

---

**That's it! 🎉**

Your application should now be running at http://localhost:3000
