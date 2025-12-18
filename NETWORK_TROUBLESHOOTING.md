# Docker Network "Not Found" Error - Troubleshooting Guide

## Error Message

```
network devcontainer_fullstack-network declared as external, but could not be found
```

## Root Cause

This error occurs when running `docker compose` from **within the devcontainer** without proper permissions. The Docker daemon requires elevated permissions to see external networks created by the host.

---

## Quick Fix (Recommended)

Use the provided launch script that handles permissions automatically:

```bash
./launch-backend.sh
```

This script:
- ✅ Automatically detects if you're in devcontainer
- ✅ Uses `sudo` when needed
- ✅ Checks if network exists (creates if missing)
- ✅ Verifies JAR file exists
- ✅ Checks MySQL container status
- ✅ Builds and launches backend
- ✅ Tests health endpoints

---

## Manual Solutions

### Solution 1: Use sudo (From Devcontainer)

When running from **inside the devcontainer**, use `sudo`:

```bash
cd ~/projects/jboss-eap-kitchensink

# Build JAR first (if not already built)
cd kitchensink
./gradlew clean build -x test
cd ..

# Launch with sudo
sudo docker compose -f docker-compose-backend-prebuilt.yml up -d
```

### Solution 2: Run from Host (Outside Devcontainer)

If you're on the **host machine** (not inside devcontainer):

```bash
cd /path/to/jboss-eap-kitchensink

# Build JAR first
cd kitchensink
./gradlew clean build -x test
cd ..

# Launch without sudo
docker compose -f docker-compose-backend-prebuilt.yml up -d
```

### Solution 3: Create Network if Missing

If the network truly doesn't exist, create it:

```bash
# From devcontainer (use sudo)
sudo docker network create devcontainer_fullstack-network

# Then launch backend
sudo docker compose -f docker-compose-backend-prebuilt.yml up -d
```

### Solution 4: Use Non-External Network (Not Recommended)

If you don't need to connect to existing MySQL, you can make docker-compose create its own network:

**Edit `docker-compose-backend-prebuilt.yml`:**

```diff
networks:
  devcontainer_fullstack-network:
-    external: true
+    external: false
```

⚠️ **WARNING**: This creates a new isolated network. Backend won't be able to connect to existing MySQL container.

---

## Verification Steps

### 1. Check if Network Exists

```bash
# From devcontainer
sudo docker network ls | grep fullstack

# Expected output:
# 6fa20ec20865   devcontainer_fullstack-network   bridge    local
```

### 2. Check Network Details

```bash
sudo docker network inspect devcontainer_fullstack-network
```

Expected containers on network:
- `devcontainer-mysql-1` (or similar MySQL container)
- `devcontainer-postgres-1` (optional)
- Other devcontainer services

### 3. Check MySQL Container Network

```bash
sudo docker inspect devcontainer-mysql-1 --format='{{range $net, $config := .NetworkSettings.Networks}}{{$net}} {{end}}'

# Expected output:
# devcontainer_fullstack-network
```

---

## Understanding the Issue

### Why This Happens

1. **Docker Socket Permissions**: The Docker daemon socket (`/var/run/docker.sock`) requires elevated permissions
2. **Devcontainer Context**: When inside a devcontainer, you're in a containerized environment
3. **External Network Lookup**: Docker needs root access to query external networks

### Permission Denied vs Network Not Found

Two related but different errors:

**Error 1: Permission Denied**
```
permission denied while trying to connect to the Docker daemon socket
```
**Solution**: Use `sudo` with Docker commands

**Error 2: Network Not Found**
```
network devcontainer_fullstack-network declared as external, but could not be found
```
**Solution**: Use `sudo` to properly query external networks, OR create the network

---

## Environment Detection

### Check Your Environment

```bash
# Are you inside a container (devcontainer)?
if [ -f "/.dockerenv" ]; then
    echo "Inside devcontainer - use sudo"
else
    echo "On host - no sudo needed (usually)"
fi
```

### Check Docker Access

```bash
# Test without sudo
docker ps 2>&1 | grep -q "permission denied" && echo "Need sudo" || echo "No sudo needed"

# If you see "permission denied", use:
sudo docker ps
```

---

## Complete Workflow

### From Devcontainer (Recommended)

```bash
# Option 1: Use automated script
./launch-backend.sh

# Option 2: Manual with sudo
cd kitchensink
./gradlew clean build -x test
cd ..
sudo docker compose -f docker-compose-backend-prebuilt.yml up -d
```

### From Host Machine

```bash
# Option 1: Use automated script
./launch-backend.sh

# Option 2: Manual without sudo
cd kitchensink
./gradlew clean build -x test
cd ..
docker compose -f docker-compose-backend-prebuilt.yml up -d
```

---

## Testing After Launch

```bash
# Check container status
sudo docker ps | grep kitchensink-backend

# Test health endpoint
curl http://localhost:8081/actuator/health

# Test API endpoint
curl http://localhost:8081/rest/members

# View logs
sudo docker compose -f docker-compose-backend-prebuilt.yml logs -f backend
```

---

## Troubleshooting Checklist

- [ ] Are you inside devcontainer? (Use `sudo`)
- [ ] Is network `devcontainer_fullstack-network` listed in `sudo docker network ls`?
- [ ] Is JAR file built? (`ls -lh kitchensink/target/jboss-kitchensink.jar`)
- [ ] Is MySQL container running? (`sudo docker ps | grep mysql`)
- [ ] Are ports 8081 and 5006 available? (`sudo netstat -tulpn | grep -E '8081|5006'`)

---

## Related Issues

### Issue: MySQL Not Found

If backend starts but can't connect to MySQL:

```bash
# Check MySQL container is on same network
sudo docker inspect devcontainer-mysql-1 | grep -A 10 Networks

# Should show: devcontainer_fullstack-network
```

### Issue: Port Already in Use

If you get port binding errors:

```bash
# Check what's using the ports
sudo netstat -tulpn | grep -E '8081|5006'

# Option 1: Stop conflicting service
# Option 2: Change ports in docker-compose-backend-prebuilt.yml
```

### Issue: JAR Not Found During Build

```bash
# Make sure JAR exists before launching
ls -lh kitchensink/target/jboss-kitchensink.jar

# If not found, build it:
cd kitchensink
./gradlew clean build -x test
cd ..
```

---

## Best Practices

1. **Use the Launch Script**: `./launch-backend.sh` handles everything automatically
2. **Always Use sudo in Devcontainer**: When running Docker commands from inside devcontainer
3. **Verify Before Launch**: Check JAR exists and MySQL is running
4. **Check Logs**: Use `sudo docker compose logs` to diagnose issues
5. **Clean Restart**: If problems persist, stop and rebuild:
   ```bash
   sudo docker compose -f docker-compose-backend-prebuilt.yml down
   sudo docker compose -f docker-compose-backend-prebuilt.yml up -d --build
   ```

---

## Summary

| Scenario | Command | Notes |
|----------|---------|-------|
| Devcontainer (Recommended) | `./launch-backend.sh` | Automated, handles everything |
| Devcontainer (Manual) | `sudo docker compose -f docker-compose-backend-prebuilt.yml up -d` | Requires JAR built first |
| Host Machine | `./launch-backend.sh` | Works on host too |
| Host Machine (Manual) | `docker compose -f docker-compose-backend-prebuilt.yml up -d` | No sudo needed usually |

---

## Need More Help?

Check these files:
- `BACKEND_TEST_RESULTS.md` - Complete test documentation
- `BACKEND_LAUNCH_TROUBLESHOOTING.md` - Maven Central 403 errors
- `QUICKSTART.md` - Quick start guide
- `LAUNCH_INSTRUCTIONS.md` - Detailed launch instructions

Or view logs:
```bash
sudo docker compose -f docker-compose-backend-prebuilt.yml logs -f backend
```
