# Development Container Configuration

This directory contains the development container configuration for the JBoss EAP Kitchensink Spring Boot application. The devcontainer provides a complete, reproducible development environment with all necessary tools pre-installed.

## 🚀 Features

- **Java 17 (Eclipse Temurin)** - Latest LTS version with full JDK
- **Gradle 8.5** - Primary build tool for the Spring Boot application
- **Maven 3.9.6** - Alternative build tool
- **MySQL 8.0** - Production-like database for testing
- **PostgreSQL 16** - Alternative database option
- **Docker-in-Docker** - Build and test container images
- **VS Code Extensions** - Pre-configured Java, Spring Boot, and development tools
- **Zsh Shell** - Enhanced shell experience with oh-my-zsh

## 📦 What's Included

### Development Tools
- Java Development Kit (JDK) 17
- Gradle 8.5 with wrapper support
- Apache Maven 3.9.6
- Git, curl, wget, and other utilities
- vim, nano for text editing
- Network tools (netcat, ping, net-tools)

### VS Code Extensions
- **Java Extension Pack** - Complete Java development support
- **Spring Boot Extensions** - Spring Boot development tools
- **Gradle & Maven Support** - Build tool integration
- **Docker Extension** - Container management
- **GitLens** - Enhanced Git capabilities
- **REST Client** - API testing
- **SonarLint** - Code quality analysis
- **YAML & XML Support** - Configuration file editing

### Database Services
- **MySQL 8.0** on port 3306
  - Database: `kitchensink`
  - User: `kitchensink`
  - Password: `kitchensink`
  
- **PostgreSQL 16** on port 5432
  - Database: `kitchensink`
  - User: `kitchensink`
  - Password: `kitchensink`

### Ports
- `8080` - Spring Boot application
- `3306` - MySQL database
- `5432` - PostgreSQL database
- `5005` - Java remote debugging

## 🛠️ Getting Started

### Prerequisites
- [Visual Studio Code](https://code.visualstudio.com/)
- [Docker Desktop](https://www.docker.com/products/docker-desktop) or [Docker Engine](https://docs.docker.com/engine/install/)
- [Dev Containers Extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) for VS Code

### Using with VS Code

1. **Open the repository in VS Code**
   ```bash
   code jboss-eap-kitchensink
   ```

2. **Reopen in Container**
   - Press `F1` or `Ctrl+Shift+P` (Windows/Linux) / `Cmd+Shift+P` (Mac)
   - Type and select: `Dev Containers: Reopen in Container`
   - Wait for the container to build (first time takes ~5-10 minutes)

3. **Start developing!**
   - The terminal will open with zsh shell
   - All tools are pre-configured and ready to use

### Using with Coder Cloud Development Environment

1. **Create a new workspace** in Coder pointing to this repository
2. **Select the devcontainer** configuration when prompted
3. **Wait for initialization** - Coder will build the container automatically
4. **Access your IDE** through the browser or local VS Code

## 🏗️ Building and Running

### Build the Application

Using Gradle:
```bash
cd kitchensink
gradle build
```

Using Maven:
```bash
cd kitchensink
mvn clean package
```

### Run Tests

```bash
gradle test
# or
mvn test
```

### Run the Application

**With development profile (H2 in-memory database):**
```bash
gradle bootRun --args='--spring.profiles.active=dev'
# or
java -jar build/libs/jboss-kitchensink-*.jar --spring.profiles.active=dev
```

**With MySQL database:**
```bash
# Ensure MySQL container is running
docker-compose -f .devcontainer/docker-compose.yml ps

# Run application with production profile
gradle bootRun --args='--spring.profiles.active=prod'
```

### Access the Application

- Application: http://localhost:8080
- API Endpoints: http://localhost:8080/rest/members
- Health Check: http://localhost:8080/actuator/health
- H2 Console (dev profile): http://localhost:8080/h2-console

## 🐳 Docker Compose Services

### Start all services:
```bash
docker-compose -f .devcontainer/docker-compose.yml up -d
```

### Stop all services:
```bash
docker-compose -f .devcontainer/docker-compose.yml down
```

### View logs:
```bash
docker-compose -f .devcontainer/docker-compose.yml logs -f
```

### Check service status:
```bash
docker-compose -f .devcontainer/docker-compose.yml ps
```

## 🔧 Environment Variables

The following environment variables are pre-configured:

- `JAVA_HOME=/opt/java/openjdk`
- `GRADLE_HOME=/opt/gradle-8.5`
- `MAVEN_HOME=/opt/apache-maven-3.9.6`
- `SPRING_PROFILES_ACTIVE=dev`
- `DB_HOST=localhost`
- `DB_PORT=3306`
- `DB_NAME=kitchensink`
- `DB_USERNAME=kitchensink`
- `DB_PASSWORD=kitchensink`

You can override these in your terminal or in `.devcontainer/devcontainer.json`.

## 🗄️ Database Connections

### MySQL Connection

**From inside the container:**
```bash
mysql -h localhost -u kitchensink -pkitchensink kitchensink
```

**Connection String:**
```
jdbc:mysql://localhost:3306/kitchensink?useSSL=false&serverTimezone=UTC
```

### PostgreSQL Connection

**From inside the container:**
```bash
psql -h localhost -U kitchensink -d kitchensink
```

**Connection String:**
```
jdbc:postgresql://localhost:5432/kitchensink
```

## 🐛 Debugging

### Remote Debugging

1. **Start application with debug enabled:**
   ```bash
   gradle bootRun --debug-jvm
   ```

2. **In VS Code:**
   - Press `F5` or go to Run and Debug
   - Select "Attach to Remote Java Application"
   - Debug port: 5005

### Debug Configuration

Create `.vscode/launch.json`:
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "java",
      "name": "Debug Spring Boot App",
      "request": "attach",
      "hostName": "localhost",
      "port": 5005
    }
  ]
}
```

## 📝 Customization

### Adding VS Code Extensions

Edit `.devcontainer/devcontainer.json` and add extension IDs to the `extensions` array:

```json
"extensions": [
    "your.extension.id"
]
```

### Adding System Packages

Edit `.devcontainer/Dockerfile` and add packages to the `apt-get install` command:

```dockerfile
RUN apt-get update && apt-get install -y \
    your-package \
    && rm -rf /var/lib/apt/lists/*
```

### Changing Database Configuration

Edit `.devcontainer/docker-compose.yml` to modify database settings:

```yaml
environment:
  MYSQL_DATABASE: your_database
  MYSQL_USER: your_user
  MYSQL_PASSWORD: your_password
```

## 🔄 Rebuilding the Container

If you make changes to the devcontainer configuration:

1. **In VS Code:**
   - Press `F1`
   - Type and select: `Dev Containers: Rebuild Container`

2. **Or manually:**
   ```bash
   docker-compose -f .devcontainer/docker-compose.yml build --no-cache
   ```

## 📚 Additional Resources

- [VS Code Dev Containers Documentation](https://code.visualstudio.com/docs/devcontainers/containers)
- [Spring Boot Documentation](https://spring.io/projects/spring-boot)
- [Gradle User Manual](https://docs.gradle.org/)
- [Coder Documentation](https://coder.com/docs)

## 🐛 Troubleshooting

### Container fails to build

- Check Docker is running: `docker ps`
- Check disk space: `docker system df`
- Clean up Docker: `docker system prune -a`

### Database connection errors

- Verify database is running: `docker-compose ps`
- Check database logs: `docker-compose logs mysql`
- Test connection: `mysql -h localhost -u kitchensink -pkitchensink`

### Port conflicts

- Check what's using the port: `lsof -i :8080`
- Change port in `docker-compose.yml` or `application.properties`

### Gradle/Maven issues

- Clear Gradle cache: `rm -rf ~/.gradle/caches`
- Clear Maven cache: `rm -rf ~/.m2/repository`
- Refresh dependencies: `gradle --refresh-dependencies`

## 🤝 Contributing

When contributing changes to the devcontainer:

1. Test the changes by rebuilding the container
2. Verify all tools work as expected
3. Update this README with any new features or changes
4. Document any breaking changes

## 📄 License

This devcontainer configuration follows the same license as the main project.
