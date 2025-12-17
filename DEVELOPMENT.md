# Development Environment Setup

This document describes how to set up your development environment for the JBoss EAP Kitchensink Spring Boot application.

## 🚀 Quick Start with Dev Container (Recommended)

The fastest way to get started is using the pre-configured development container. This provides a complete, reproducible development environment with all tools pre-installed.

### Prerequisites
- [Docker Desktop](https://www.docker.com/products/docker-desktop) or Docker Engine
- [Visual Studio Code](https://code.visualstudio.com/) with [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
- **OR** [Coder](https://coder.com/) Cloud Development Environment

### Using VS Code

1. **Clone the repository**
   ```bash
   git clone https://github.com/greg-the-coder/jboss-eap-kitchensink.git
   cd jboss-eap-kitchensink
   ```

2. **Open in VS Code**
   ```bash
   code .
   ```

3. **Reopen in Container**
   - Press `F1` or `Ctrl+Shift+P` (Windows/Linux) / `Cmd+Shift+P` (Mac)
   - Type: `Dev Containers: Reopen in Container`
   - Wait for the container to build (first time takes 5-10 minutes)

4. **Start developing!**
   - Run the quick-start script: `.devcontainer/quick-start.sh`
   - Or use the integrated terminal for manual commands

### Using Coder

1. **Create a workspace** pointing to this repository
2. **Select the devcontainer** configuration
3. **Wait for initialization** (automatic)
4. **Access your browser-based IDE**

### What's Included

The dev container includes:
- ✅ Java 17 (Eclipse Temurin JDK)
- ✅ Gradle 8.5
- ✅ Maven 3.9.6
- ✅ MySQL 8.0 database
- ✅ PostgreSQL 16 database
- ✅ Docker-in-Docker support
- ✅ All VS Code extensions for Java/Spring Boot development
- ✅ Pre-configured database connections
- ✅ Health checks and monitoring tools

📚 **Full documentation**: [.devcontainer/README.md](.devcontainer/README.md)

---

## 🛠️ Manual Local Setup (Alternative)

If you prefer to set up your local environment manually:

### Prerequisites

Install the following tools:

1. **Java Development Kit (JDK) 17 or higher**
   - Download: https://adoptium.net/
   - Verify: `java -version`

2. **Gradle 8.5 or higher**
   - Download: https://gradle.org/releases/
   - Or use the Gradle wrapper: `./gradlew`
   - Verify: `gradle --version`

3. **Maven 3.8+ (optional)**
   - Download: https://maven.apache.org/download.cgi
   - Verify: `mvn --version`

4. **Docker & Docker Compose**
   - Download: https://docs.docker.com/get-docker/
   - Verify: `docker --version && docker-compose --version`

5. **MySQL 8.0 or PostgreSQL 16 (optional for local testing)**
   - For development, H2 in-memory database is used by default

### Build and Run

1. **Clone the repository**
   ```bash
   git clone https://github.com/greg-the-coder/jboss-eap-kitchensink.git
   cd jboss-eap-kitchensink/kitchensink
   ```

2. **Build the application**
   ```bash
   gradle build
   # or use the wrapper
   ./gradlew build
   ```

3. **Run tests**
   ```bash
   gradle test
   # or
   ./gradlew test
   ```

4. **Run the application**
   
   With H2 in-memory database (development):
   ```bash
   gradle bootRun --args='--spring.profiles.active=dev'
   ```
   
   With MySQL (production-like):
   ```bash
   # Start MySQL using docker-compose
   docker-compose -f .devcontainer/docker-compose.yml up -d mysql
   
   # Run application
   gradle bootRun --args='--spring.profiles.active=prod'
   ```

5. **Access the application**
   - Application: http://localhost:8080
   - API: http://localhost:8080/rest/members
   - Health: http://localhost:8080/actuator/health
   - H2 Console (dev): http://localhost:8080/h2-console

### IDE Setup

#### IntelliJ IDEA
1. Import project as Gradle project
2. Set JDK to Java 17
3. Enable annotation processing
4. Install Spring Boot plugin

#### Eclipse
1. Import as existing Gradle project
2. Set JDK to Java 17
3. Install Spring Tools 4 plugin

#### VS Code
1. Install Java Extension Pack
2. Install Spring Boot Extension Pack
3. Open project folder
4. VS Code will auto-detect and configure

---

## 🐳 Docker Deployment

### Build Docker Image

```bash
cd kitchensink
docker build -t kitchensink:latest .
```

### Run Container

With environment variables:
```bash
docker run -p 8080:8080 \
  -e SPRING_PROFILES_ACTIVE=prod \
  -e DB_URL=jdbc:mysql://host.docker.internal:3306/kitchensink \
  -e DB_USERNAME=kitchensink \
  -e DB_PASSWORD=kitchensink \
  kitchensink:latest
```

### Using Docker Compose

The repository includes a complete docker-compose configuration:

```bash
# Start all services (app + databases)
docker-compose -f .devcontainer/docker-compose.yml up -d

# View logs
docker-compose -f .devcontainer/docker-compose.yml logs -f

# Stop services
docker-compose -f .devcontainer/docker-compose.yml down
```

---

## 🧪 Testing

### Run All Tests
```bash
gradle test
```

### Run Specific Test Class
```bash
gradle test --tests MemberRegistrationTest
```

### Run with Coverage
```bash
gradle test jacocoTestReport
```

Coverage report: `build/reports/jacoco/test/html/index.html`

---

## 🔧 Configuration

### Spring Profiles

- **dev** (default): H2 in-memory database, debug logging
- **prod**: MySQL database, production settings
- **test**: H2 database, test-specific configuration

### Environment Variables

You can override configuration using environment variables:

```bash
# Security credentials
export APP_SECURITY_USER_USERNAME=myuser
export APP_SECURITY_USER_PASSWORD=SecurePass123!

# Database connection
export DB_URL=jdbc:mysql://localhost:3306/kitchensink
export DB_USERNAME=kitchensink
export DB_PASSWORD=kitchensink

# SSL/TLS
export SSL_KEY_STORE=/path/to/keystore.p12
export SSL_KEY_STORE_PASSWORD=changeit
```

📚 **Full security documentation**: [kitchensink/SECURITY_CONFIGURATION.md](kitchensink/SECURITY_CONFIGURATION.md)

---

## 🐛 Debugging

### Remote Debugging

Start application with debug enabled:
```bash
gradle bootRun --debug-jvm
```

Connect debugger to port `5005`.

### VS Code Debug Configuration

Create `.vscode/launch.json`:
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "java",
      "name": "Debug Spring Boot",
      "request": "attach",
      "hostName": "localhost",
      "port": 5005
    }
  ]
}
```

---

## 📚 Additional Resources

- [Dev Container Documentation](.devcontainer/README.md)
- [Security Configuration](kitchensink/SECURITY_CONFIGURATION.md)
- [Spring Boot Documentation](https://spring.io/projects/spring-boot)
- [Gradle User Guide](https://docs.gradle.org/current/userguide/userguide.html)

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests: `gradle test`
5. Build: `gradle build`
6. Submit a pull request

---

## 💡 Quick Tips

- Use the quick-start script in dev container: `.devcontainer/quick-start.sh`
- Check application health: `curl http://localhost:8080/actuator/health`
- Test API endpoints: `curl http://localhost:8080/rest/members`
- View H2 console (dev): http://localhost:8080/h2-console (JDBC URL: `jdbc:h2:mem:kitchensink-dev`)

---

## 🆘 Troubleshooting

### Build Failures
- Clear Gradle cache: `rm -rf ~/.gradle/caches`
- Rebuild: `gradle clean build`
- Check Java version: `java -version` (must be 17+)

### Database Connection Issues
- Verify MySQL is running: `docker ps`
- Check connection: `mysql -h localhost -u kitchensink -pkitchensink`
- Review logs: `docker logs <container-id>`

### Port Conflicts
- Check port usage: `lsof -i :8080`
- Change port in `application.properties`: `server.port=8081`

For more troubleshooting, see [.devcontainer/README.md#troubleshooting](.devcontainer/README.md#-troubleshooting)
