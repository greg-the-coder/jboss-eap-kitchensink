# Backend Launch Troubleshooting Guide

## Issue: Maven Central 403 Forbidden Error

### Problem Description

When launching the backend using `docker-compose-backend.yml`, you may encounter:

```
ERROR [build 4/6] RUN mvn dependency:go-offline -B
[FATAL] Non-resolvable parent POM for org.jboss.quickstarts.eap:jboss-kitchensink:6.4.0-SNAPSHOT: 
The following artifacts could not be resolved: 
org.springframework.boot:spring-boot-starter-parent:pom:3.2.1 (absent): 
Could not transfer artifact org.springframework.boot:spring-boot-starter-parent:pom:3.2.1 
from/to central (https://repo.maven.apache.org/maven2): 
status code: 403, reason phrase: Forbidden (403)
```

### Root Cause

This error occurs when:
1. **Maven Central is temporarily blocking requests** (rate limiting, geographic restrictions)
2. **Docker build context lacks Maven cache** (no cached dependencies)
3. **Network/proxy issues** preventing access to Maven Central
4. **Corporate firewall** blocking Maven Central access

---

## Solutions

### ✅ Solution 1: Use Pre-Built JAR (RECOMMENDED)

Build the JAR locally in the dev container (which has cached dependencies) and then launch it in Docker.

#### Option A: Automated Script (Easiest)

```bash
# From project root
./start-backend.sh
```

This script will:
1. Build JAR locally using Gradle (or Maven)
2. Stop any existing backend container
3. Build Docker image with pre-built JAR
4. Launch backend container

#### Option B: Manual Steps

```bash
# Step 1: Build JAR locally
cd ~/projects/jboss-eap-kitchensink/kitchensink

# Using Gradle (preferred)
./gradlew clean build -x test

# OR using Maven
mvn clean package -DskipTests

# Step 2: Launch backend with pre-built JAR
cd ~/projects/jboss-eap-kitchensink
docker compose -f docker-compose-backend-prebuilt.yml up -d --build
```

**Why this works**:
- Dev container has all Maven/Gradle dependencies cached
- No Maven Central download needed during Docker build
- Faster build (uses local cache)

---

### ✅ Solution 2: Fix Original Dockerfile (Advanced)

If you prefer to use the original `docker-compose-backend.yml`, the updated `Dockerfile` now includes:

1. **Maven settings with mirror configuration**
2. **Retry logic** for dependency downloads
3. **Alternative Maven Central URL**

Try again:

```bash
# Clean up old images
docker compose -f docker-compose-backend.yml down
docker rmi $(docker images | grep kitchensink-backend | awk '{print $3}') 2>/dev/null || true

# Rebuild with updated Dockerfile
docker compose -f docker-compose-backend.yml up -d --build
```

---

### ✅ Solution 3: Use Maven Proxy/Mirror

If you're behind a corporate firewall or experiencing persistent issues:

#### Create `kitchensink/settings.xml`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
          http://maven.apache.org/xsd/settings-1.0.0.xsd">
  
  <mirrors>
    <!-- Aliyun Mirror (China) -->
    <mirror>
      <id>aliyun</id>
      <mirrorOf>central</mirrorOf>
      <name>Aliyun Maven</name>
      <url>https://maven.aliyun.com/repository/public</url>
    </mirror>
    
    <!-- OR UK Mirror -->
    <!--
    <mirror>
      <id>uk</id>
      <mirrorOf>central</mirrorOf>
      <name>UK Maven</name>
      <url>https://uk.maven.org/maven2</url>
    </mirror>
    -->
  </mirrors>
  
  <proxies>
    <!-- If behind corporate proxy, configure here -->
    <!--
    <proxy>
      <id>corporate-proxy</id>
      <active>true</active>
      <protocol>http</protocol>
      <host>proxy.company.com</host>
      <port>8080</port>
    </proxy>
    -->
  </proxies>
</settings>
```

#### Update Dockerfile to use custom settings:

```dockerfile
# Add after WORKDIR /app
COPY settings.xml /root/.m2/settings.xml
```

---

### ✅ Solution 4: Run Backend Directly (Development Only)

For development, you can run the backend directly without Docker:

```bash
cd ~/projects/jboss-eap-kitchensink/kitchensink

# Using Gradle
./gradlew bootRun

# OR using Maven
mvn spring-boot:run

# Backend will be available at http://localhost:8080
```

**Note**: This requires MySQL to be running in the dev container.

---

## Verification

After applying any solution, verify the backend is running:

### 1. Check Container Status

```bash
docker ps | grep kitchensink-backend
```

Expected output:
```
kitchensink-backend   Up X seconds (healthy)
```

### 2. Test Health Endpoint

```bash
curl http://localhost:8080/actuator/health
```

Expected response:
```json
{"status":"UP","groups":["liveness","readiness"]}
```

### 3. Test API Endpoint

```bash
curl http://localhost:8080/rest/members
```

Expected response (may be empty on first start):
```json
[]
```

### 4. View Logs

```bash
# For pre-built JAR approach
docker compose -f docker-compose-backend-prebuilt.yml logs -f backend

# For original approach
docker compose -f docker-compose-backend.yml logs -f backend
```

---

## Comparison: docker-compose Files

### `docker-compose-backend.yml` (Original)
- Builds JAR inside Docker (multi-stage build)
- Downloads dependencies from Maven Central during build
- **Issue**: May fail with 403 Forbidden errors
- **Use when**: Maven Central is accessible

### `docker-compose-backend-prebuilt.yml` (Alternative)
- Uses pre-built JAR from local build
- No dependency downloads during Docker build
- **Advantage**: Faster, uses local cache, no Maven Central issues
- **Use when**: Getting Maven Central errors
- **Requires**: JAR built locally first

---

## Quick Command Reference

### Build JAR Locally

```bash
# Gradle
cd kitchensink && ./gradlew clean build -x test

# Maven
cd kitchensink && mvn clean package -DskipTests
```

### Launch Backend (Pre-built)

```bash
# Automated
./start-backend.sh

# Manual
docker compose -f docker-compose-backend-prebuilt.yml up -d --build
```

### Launch Backend (Original)

```bash
docker compose -f docker-compose-backend.yml up -d --build
```

### View Logs

```bash
# Pre-built
docker compose -f docker-compose-backend-prebuilt.yml logs -f backend

# Original
docker compose -f docker-compose-backend.yml logs -f backend
```

### Stop Backend

```bash
# Pre-built
docker compose -f docker-compose-backend-prebuilt.yml down

# Original
docker compose -f docker-compose-backend.yml down
```

---

## Additional Troubleshooting

## Additional Troubleshooting

### Issue: "target/jboss-kitchensink.jar not found" during Docker build

**Error Message**:
```
failed to compute cache key: failed to calculate checksum of ref: 
"/kitchensink/target/jboss-kitchensink.jar": not found
```

**Cause**: JAR not built before using `docker-compose-backend-prebuilt.yml`

**Solutions**:

#### Solution 1: Use Automated Script (Easiest)
```bash
./start-backend.sh
```
This script automatically builds the JAR before launching Docker.

#### Solution 2: Build JAR Manually
```bash
# Option A: Using dedicated build script
./build-backend-jar.sh

# Option B: Manual build
cd kitchensink

# If Gradle
./gradlew clean build -x test

# If Maven  
mvn clean package -DskipTests

# Verify JAR exists
ls -lh target/jboss-kitchensink.jar
```

#### Solution 3: Check JAR Location
```bash
# The JAR must be in kitchensink/target/ directory
cd kitchensink

# If using Gradle, JAR might be in build/libs/
if [ -f "build/libs/jboss-kitchensink.jar" ]; then
    mkdir -p target
    cp build/libs/jboss-kitchensink.jar target/
    echo "JAR copied to target/"
fi

# Verify
ls -lh target/jboss-kitchensink.jar
```

### Issue: Gradle puts JAR in build/libs/ instead of target/

**Cause**: Gradle and Maven use different output directories

**Solution**: The `start-backend.sh` script automatically handles this by copying the JAR from `build/libs/` to `target/`. If building manually:

```bash
cd kitchensink
./gradlew clean build -x test

# Copy to target/ for Docker compatibility
mkdir -p target
cp build/libs/jboss-kitchensink.jar target/jboss-kitchensink.jar

# Verify
ls -lh target/jboss-kitchensink.jar
```

### Issue: "target/jboss-kitchensink.jar not found"

**Cause**: JAR not built before using pre-built approach

**Solution**:
```bash
cd kitchensink
./gradlew clean build -x test
# Verify JAR exists
ls -lh target/jboss-kitchensink.jar
```

### Issue: "Network devcontainer_kitchensink-network not found"

**Cause**: Dev Container not running

**Solution**:
```bash
# Ensure Dev Container is open in VS Code
# Or create network manually:
docker network create devcontainer_kitchensink-network
```

### Issue: Backend container exits immediately

**Cause**: JAR might be corrupted or MySQL not accessible

**Solutions**:
```bash
# 1. Rebuild JAR
cd kitchensink
./gradlew clean build -x test

# 2. Check MySQL is running
docker ps | grep mysql

# 3. View detailed logs
docker compose -f docker-compose-backend-prebuilt.yml logs backend
```

### Issue: Port 8080 already in use

**Cause**: Another process using port 8080

**Solution**:
```bash
# Find process
lsof -i :8080

# Kill process (replace <PID>)
kill -9 <PID>

# Or change port in docker-compose file
ports:
  - "8081:8080"  # Use 8081 instead
```

---

## Recommended Approach

### For Development (Daily Use)

**Option 1**: Automated Script
```bash
./start-backend.sh
```

**Option 2**: Direct Run (No Docker)
```bash
cd kitchensink && ./gradlew bootRun
```

### For Testing Full Docker Setup

```bash
# Build locally first
cd kitchensink && ./gradlew clean build -x test && cd ..

# Then launch
docker compose -f docker-compose-backend-prebuilt.yml up -d
```

### For CI/CD Pipelines

Use original `docker-compose-backend.yml` with:
- Maven/Gradle repository mirrors configured
- Dependency caching in CI system
- Retry logic for transient failures

---

## Files Created

| File | Purpose |
|------|---------|
| `Dockerfile` (updated) | Multi-stage build with retry logic |
| `Dockerfile.runtime` | Runtime-only (uses pre-built JAR) |
| `docker-compose-backend.yml` | Original (builds JAR in Docker) |
| `docker-compose-backend-prebuilt.yml` | Alternative (uses pre-built JAR) |
| `start-backend.sh` | Automated build and launch script |

---

## Summary

### Problem
Maven Central 403 Forbidden errors during Docker build

### Root Cause
Docker build context lacks cached dependencies and Maven Central may be blocking requests

### Recommended Solution
Use **pre-built JAR approach** with `docker-compose-backend-prebuilt.yml` or `./start-backend.sh`

### Why It Works
- Builds JAR locally using dev container's cached dependencies
- No Maven Central access needed during Docker build
- Faster and more reliable

---

## Next Steps

1. **Try automated script**:
   ```bash
   ./start-backend.sh
   ```

2. **If successful**, backend will be available at:
   - API: http://localhost:8080
   - Health: http://localhost:8080/actuator/health

3. **Then launch frontend**:
   ```bash
   docker compose -f docker-compose-frontend.yml up -d
   ```

4. **Access full application**:
   - Frontend: http://localhost:3000

---

**Last Updated**: December 18, 2025  
**Issue**: Maven Central 403 Forbidden  
**Status**: ✅ Solutions Provided  
**Recommended**: Use `start-backend.sh` or `docker-compose-backend-prebuilt.yml`
