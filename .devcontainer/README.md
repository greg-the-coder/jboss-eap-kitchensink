# Development Container Configuration

This directory contains the development container configuration for the JBoss EAP Kitchensink Full-Stack application. The devcontainer provides a **complete, automated full-stack environment** with all services running via Docker Compose.

## 🎯 What Runs Automatically

When you open this project in VS Code with Dev Containers, **5 containers start automatically**:

| Service | Container | Port | Purpose |
|---------|-----------|------|---------|
| **Workspace** | Development environment | - | Your IDE workspace with all dev tools |
| **Backend** | Spring Boot app | 8080 | REST API (auto-built from kitchensink/) |
| **Frontend** | Next.js app | 3000 | Web UI (auto-built from frontend/) |
| **MySQL** | Database | 3306 | Primary database for backend |
| **PostgreSQL** | Database | 5432 | Alternative database option |

**Key Point**: The backend and frontend applications are **automatically built and running** when the devcontainer starts. You can immediately access:
- Frontend: http://localhost:3000
- Backend API: http://localhost:8080
- Backend Health: http://localhost:8080/actuator/health

## 🚀 Features

### Backend
- **Java 21 (Eclipse Temurin)** - Latest LTS version with full JDK
- **Gradle 8.5** - Primary build tool for the Spring Boot application
- **Maven 3.9.6** - Alternative build tool
- **Spring Boot 3.x** - Modern Java framework

### Frontend
- **Node.js 20.x (LTS)** - Latest long-term support version
- **npm, yarn, pnpm** - Multiple package managers
- **TypeScript** - Type-safe JavaScript
- **Next.js 16** - React framework for production
- **ESLint & Prettier** - Code quality and formatting

### Infrastructure
- **MySQL 8.0** - Production-like relational database
- **PostgreSQL 16** - Alternative database option
- **Docker-in-Docker** - Build and test container images
- **VS Code Extensions** - Pre-configured for full-stack development
- **Zsh Shell** - Enhanced shell experience with oh-my-zsh

## 📦 What's Included

### Backend Tools
- Java Development Kit (JDK) 17
- Gradle 8.5 with wrapper support
- Apache Maven 3.9.6
- Spring Boot development tools
- Java debugging support

### Frontend Tools
- Node.js 20.x (LTS)
- npm 10+ (latest)
- yarn (alternative package manager)
- pnpm (fast, disk-efficient package manager)
- TypeScript compiler
- ESLint (linting)
- Prettier (code formatting)

### Common Tools
- Git, curl, wget, and other utilities
- vim, nano for text editing
- Network tools (netcat, ping, net-tools)
- jq for JSON processing

### VS Code Extensions

#### Backend Extensions
- **Java Extension Pack** - Complete Java development support
- **Spring Boot Extensions** - Spring Boot development tools
- **Gradle & Maven Support** - Build tool integration

#### Frontend Extensions
- **ESLint** - JavaScript/TypeScript linting
- **Prettier** - Code formatting
- **Tailwind CSS IntelliSense** - Tailwind CSS support
- **ES7+ React/Redux/React-Native snippets** - React development
- **npm Intellisense** - npm package autocomplete

#### Common Extensions
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
- `3000` - Next.js frontend development server
- `8080` - Spring Boot backend application
- `3306` - MySQL database
- `5432` - PostgreSQL database
- `5005` - Java remote debugging

## 🔧 Managing Running Services

All services are managed by Docker Compose and start automatically when you open the devcontainer.

### View Running Services
```bash
# From within the devcontainer workspace
docker-compose ps

# Expected output:
# NAME                STATUS              PORTS
# backend             running (healthy)   8080/tcp
# frontend            running (healthy)   3000/tcp
# mysql               running (healthy)   3306/tcp
# postgres            running (healthy)   5432/tcp
# workspace           running             0.0.0.0:3000->3000, 8080->8080, etc.
```

### View Service Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f mysql
```

### Restart a Service
```bash
# Restart backend (e.g., after code changes)
docker-compose restart backend

# Restart frontend
docker-compose restart frontend

# Rebuild and restart (after Dockerfile changes)
docker-compose up -d --build backend
docker-compose up -d --build frontend
```

### Stop/Start Services
```bash
# Stop a service
docker-compose stop backend

# Start a service
docker-compose start backend

# Stop all services (except workspace)
docker-compose stop backend frontend mysql postgres
```

### Check Service Health
```bash
# Backend health check
curl http://localhost:8080/actuator/health

# Frontend health check (if /api/health endpoint exists)
curl http://localhost:3000/api/health

# MySQL
docker-compose exec mysql mysqladmin ping -h localhost -u root -proot

# PostgreSQL
docker-compose exec postgres pg_isready -U kitchensink
```

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
   - Frontend dependencies will be automatically installed

### Using with Coder Cloud Development Environment

1. **Create a new workspace** in Coder pointing to this repository
2. **Select the devcontainer** configuration when prompted
3. **Wait for initialization** - Coder will build the container automatically
4. **Access your IDE** through the browser or local VS Code

## 🏗️ Backend Development

### Build the Backend

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

### Run Backend Tests

```bash
cd kitchensink
gradle test
# or
mvn test
```

### Run the Backend Application

**With development profile (H2 in-memory database):**
```bash
cd kitchensink
gradle bootRun --args='--spring.profiles.active=dev'
# or
java -jar build/libs/jboss-kitchensink-*.jar --spring.profiles.active=dev
```

**With MySQL database:**
```bash
# Ensure MySQL container is running
docker-compose -f .devcontainer/docker-compose.yml up -d mysql

# Run application with production profile
cd kitchensink
gradle bootRun --args='--spring.profiles.active=prod'
```

### Access the Backend

- REST API: http://localhost:8080/rest/members
- Health Check: http://localhost:8080/actuator/health
- H2 Console (dev profile): http://localhost:8080/h2-console

## 🎨 Frontend Development

### Install Frontend Dependencies

```bash
cd frontend
npm install
```

### Run Frontend Development Server

```bash
cd frontend
npm run dev
```

The frontend will be available at http://localhost:3000

### Build Frontend for Production

```bash
cd frontend
npm run build
```

### Run Frontend Linting

```bash
cd frontend
npm run lint
```

### Frontend Environment Variables

The frontend uses these environment variables (configured in `.env.local`):

```env
NEXT_PUBLIC_API_URL=http://localhost:8080
```

To connect to a different backend:
```bash
cd frontend
NEXT_PUBLIC_API_URL=http://your-backend:8080 npm run dev
```

## 🚀 Full-Stack Development

### Start Both Backend and Frontend

**Terminal 1 (Backend):**
```bash
cd kitchensink
gradle bootRun --args='--spring.profiles.active=dev'
```

**Terminal 2 (Frontend):**
```bash
cd frontend
npm run dev
```

Now you can:
- Access frontend UI: http://localhost:3000
- Make API calls to backend: http://localhost:8080

### Running with Databases

**Start MySQL:**
```bash
docker-compose -f .devcontainer/docker-compose.yml up -d mysql
```

**Start PostgreSQL:**
```bash
docker-compose -f .devcontainer/docker-compose.yml up -d postgres
```

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

### Backend Environment Variables

The following backend environment variables are pre-configured:

- `JAVA_HOME=/opt/java/openjdk`
- `GRADLE_HOME=/opt/gradle-8.5`
- `MAVEN_HOME=/opt/apache-maven-3.9.6`
- `SPRING_PROFILES_ACTIVE=dev`
- `DB_HOST=localhost`
- `DB_PORT=3306`
- `DB_NAME=kitchensink`
- `DB_USERNAME=kitchensink`
- `DB_PASSWORD=kitchensink`

### Frontend Environment Variables

- `NODE_ENV=development`
- `NEXT_PUBLIC_API_URL=http://localhost:8080`

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

### Backend Debugging (Java)

1. **Start application with debug enabled:**
   ```bash
   cd kitchensink
   gradle bootRun --debug-jvm
   ```

2. **In VS Code:**
   - Press `F5` or go to Run and Debug
   - Select "Attach to Remote Java Application"
   - Debug port: 5005

### Frontend Debugging (Next.js)

1. **Start frontend in debug mode:**
   ```bash
   cd frontend
   npm run dev
   ```

2. **In VS Code:**
   - Open the Debug panel
   - Select "Next.js: debug server-side" or "Next.js: debug client-side"
   - Press `F5`

3. **Or use Browser DevTools:**
   - Chrome: Open DevTools (F12)
   - React DevTools extension recommended

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

### Adding Global npm Packages

Edit `.devcontainer/Dockerfile`:

```dockerfile
RUN npm install -g \
    your-package
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
- [Next.js Documentation](https://nextjs.org/docs)
- [Gradle User Manual](https://docs.gradle.org/)
- [Node.js Documentation](https://nodejs.org/docs/)
- [TypeScript Documentation](https://www.typescriptlang.org/docs/)

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

- Check what's using the port: `lsof -i :8080` or `lsof -i :3000`
- Change port in `docker-compose.yml` or application configuration

### Backend (Gradle/Maven) issues

- Clear Gradle cache: `rm -rf ~/.gradle/caches`
- Clear Maven cache: `rm -rf ~/.m2/repository`
- Refresh dependencies: `gradle --refresh-dependencies`

### Frontend (npm) issues

- Clear npm cache: `npm cache clean --force`
- Delete node_modules: `rm -rf node_modules`
- Reinstall dependencies: `npm install`
- Check Node.js version: `node --version`

### TypeScript errors

- Check TypeScript version: `npx tsc --version`
- Restart TypeScript server in VS Code: `Ctrl+Shift+P` → "TypeScript: Restart TS Server"

## 🎯 Quick Reference

### Backend Commands
```bash
cd kitchensink
gradle build              # Build backend
gradle test               # Run backend tests
gradle bootRun            # Run Spring Boot app (port 8080)
gradle clean              # Clean build artifacts
```

### Frontend Commands
```bash
cd frontend
npm install               # Install dependencies
npm run dev               # Run Next.js dev server (port 3000)
npm run build             # Build for production
npm run start             # Start production server
npm run lint              # Lint code
```

### Database Commands
```bash
docker-compose up -d mysql      # Start MySQL
docker-compose up -d postgres   # Start PostgreSQL
docker-compose down             # Stop all services
docker-compose logs -f mysql    # View MySQL logs
```

## 🤝 Contributing

When contributing changes to the devcontainer:

1. Test the changes by rebuilding the container
2. Verify all tools work as expected (both backend and frontend)
3. Update this README with any new features or changes
4. Document any breaking changes

## 📄 License

This devcontainer configuration follows the same license as the main project.
