# 🚀 Kitchensink Full-Stack Application

Modern full-stack member registration application demonstrating the migration from legacy J2EE (JBoss EAP) to a modern architecture with **Spring Boot 3.x** backend and **Next.js 15** frontend.

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Features](#features)
- [Technology Stack](#technology-stack)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Project Structure](#project-structure)
- [Development](#development)
- [Docker Deployment](#docker-deployment)
- [Configuration](#configuration)
- [API Documentation](#api-documentation)
- [Security](#security)
- [Testing](#testing)
- [Migration Guide](#migration-guide)

## 🎯 Overview

This application demonstrates a complete migration from a traditional J2EE application with EJB, CDI, JAX-RS, and JSF to a modern microservices architecture:

- **Backend**: Spring Boot 3.x REST API with Spring Data JPA and Spring Security
- **Frontend**: Next.js 15 with TypeScript, React 19, and Tailwind CSS
- **Database**: H2 (development), MySQL (production)
- **Deployment**: Docker containers ready for Kubernetes

### What Was Migrated

- ✅ **EJB → Spring Services**: Stateless EJBs converted to Spring `@Service` components
- ✅ **CDI → Spring DI**: Dependency injection migrated to Spring's `@Autowired`
- ✅ **JAX-RS → Spring MVC**: REST endpoints converted to `@RestController`
- ✅ **JSF UI → Next.js**: Server-side JSF replaced with React-based SPA
- ✅ **JPA**: Retained with Spring Data JPA repositories
- ✅ **Bean Validation**: Maintained with Jakarta Validation API
- ✅ **Security**: Java EE security replaced with Spring Security

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         Client (Browser)                     │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      │ HTTP/HTTPS
                      │
┌─────────────────────▼───────────────────────────────────────┐
│               Next.js Frontend (Port 3000)                   │
│  • React 19 Components                                       │
│  • TypeScript                                                │
│  • Tailwind CSS                                              │
│  • React Query (Data Management)                             │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      │ REST API (JSON)
                      │
┌─────────────────────▼───────────────────────────────────────┐
│            Spring Boot Backend (Port 8080)                   │
│  • Spring MVC REST Controllers                               │
│  • Spring Data JPA                                           │
│  • Spring Security                                           │
│  • Bean Validation                                           │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      │ JDBC
                      │
┌─────────────────────▼───────────────────────────────────────┐
│                    Database Layer                            │
│  • H2 (Development)                                          │
│  • MySQL (Production)                                        │
└─────────────────────────────────────────────────────────────┘
```

## ✨ Features

### Backend Features

- RESTful API with JSON responses
- Spring Data JPA for database operations
- Bean Validation with custom validators
- Spring Security with Basic Authentication
- Global exception handling
- Health check endpoints (Spring Actuator)
- Profile-based configuration (dev/prod)
- Graceful shutdown support
- Structured logging to stdout/stderr

### Frontend Features

- Modern React-based UI with Server Components
- Type-safe development with TypeScript
- Responsive design (mobile-first)
- Real-time data updates with React Query
- Client-side and server-side validation
- Search, sort, and filter capabilities
- Multiple view modes (table/grid)
- Toast notifications
- Loading states and skeletons
- Error boundaries and fallbacks

## 🛠️ Technology Stack

### Backend

| Technology | Version | Purpose |
|------------|---------|---------|
| Java | 17+ | Programming language |
| Spring Boot | 3.2.1 | Application framework |
| Spring Data JPA | 3.2.x | Data access |
| Spring Security | 6.2.x | Authentication/Authorization |
| Hibernate | 6.x | ORM |
| H2 Database | 2.x | Development database |
| MySQL | 8.x | Production database |
| Bean Validation | 3.0.x | Input validation |
| Spring Actuator | 3.2.x | Monitoring |
| Logback | 1.4.x | Logging |

### Frontend

| Technology | Version | Purpose |
|------------|---------|---------|
| Next.js | 15 | React framework |
| React | 19 | UI library |
| TypeScript | 5.x | Type safety |
| Tailwind CSS | 3.x | Styling |
| React Query | 5.x | Data fetching |
| React Hook Form | 7.x | Form management |
| Zod | 3.x | Schema validation |
| Axios | 1.x | HTTP client |

### DevOps

- **Docker**: Containerization
- **Docker Compose**: Multi-container orchestration
- **Node.js**: 20.x (for frontend build)

## 📦 Prerequisites

### Required

- **Java Development Kit (JDK)**: 17 or higher
- **Node.js**: 18.x or higher
- **Maven**: 3.8+
- **Docker**: 20.x or higher (for containerized deployment)

### Optional

- **MySQL**: 8.x (for production database)
- **Docker Compose**: For simplified multi-container deployment

## 🚀 Quick Start

### Option 1: Local Development

#### 1. Start the Backend

```bash
# Navigate to backend directory
cd kitchensink

# Run with Maven
./mvnw spring-boot:run -Dspring-boot.run.profiles=dev


```

Backend will start on: [http://localhost:8080](http://localhost:8080)

#### 2. Start the Frontend

```bash
# Navigate to frontend directory (in a new terminal)
cd frontend

# Install dependencies
npm install

# Start development server
npm run dev
```

Frontend will start on: [http://localhost:3000](http://localhost:3000)

#### 3. Access the Application

- **Frontend UI**: [http://localhost:3000](http://localhost:3000)
- **Backend API**: [http://localhost:8080/rest/members](http://localhost:8080/rest/members)
- **H2 Console**: [http://localhost:8080/h2-console](http://localhost:8080/h2-console)
  - JDBC URL: `jdbc:h2:mem:kitchensink-dev`
  - Username: `sa`
  - Password: (leave empty)
- **Health Check**: [http://localhost:8080/actuator/health](http://localhost:8080/actuator/health)

### Option 2: Docker Compose (Recommended)

```bash
# From project root
docker-compose up --build
```

This will start:
- Frontend on port 3000
- Backend on port 8080
- MySQL database on port 3306

Access: [http://localhost:3000](http://localhost:3000)

## 📁 Project Structure

```
jboss-eap-kitchensink/
├── kitchensink/                    # Spring Boot Backend
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/
│   │   │   │   └── org/jboss/as/quickstarts/kitchensink/
│   │   │   │       ├── config/     # Configuration classes
│   │   │   │       │   ├── SecurityConfig.java
│   │   │   │       │   └── CorsConfig.java
│   │   │   │       ├── controller/ # REST Controllers
│   │   │   │       │   └── MemberResourceRESTService.java
│   │   │   │       ├── model/      # JPA Entities
│   │   │   │       │   └── Member.java
│   │   │   │       ├── repository/ # Spring Data Repositories
│   │   │   │       │   └── MemberRepository.java
│   │   │   │       ├── service/    # Business Logic
│   │   │   │       │   └── MemberRegistration.java
│   │   │   │       ├── exception/  # Exception Handlers
│   │   │   │       │   └── GlobalExceptionHandler.java
│   │   │   │       └── KitchensinkApplication.java
│   │   │   └── resources/
│   │   │       ├── application.properties
│   │   │       ├── application-dev.yml
│   │   │       └── application-prod.yml
│   │   └── test/                   # Tests
│   ├── Dockerfile                  # Backend Docker image
│   └── pom.xml                     # Maven dependencies
│
├── frontend/                       # Next.js Frontend
│   ├── src/
│   │   ├── app/                    # Next.js App Router
│   │   │   ├── layout.tsx
│   │   │   ├── page.tsx
│   │   │   ├── providers.tsx
│   │   │   └── members/[id]/       # Dynamic routes
│   │   ├── components/             # React Components
│   │   ├── hooks/                  # Custom React Hooks
│   │   ├── lib/                    # Utilities
│   │   └── types/                  # TypeScript Types
│   ├── public/                     # Static assets
│   ├── Dockerfile                  # Frontend Docker image
│   ├── next.config.ts              # Next.js config
│   ├── tailwind.config.ts          # Tailwind config
│   ├── tsconfig.json               # TypeScript config
│   └── package.json
│
├── docker-compose.yml              # Multi-container setup
└── README_FULLSTACK.md             # This file
```

## 💻 Development

### Backend Development

```bash
cd kitchensink

# Run in development mode with auto-reload (if using spring-boot-devtools)
./mvnw spring-boot:run -Dspring-boot.run.profiles=dev

# Build JAR
./mvnw clean package

# Run tests
./mvnw test

# Check code style
./mvnw checkstyle:check
```

### Frontend Development

```bash
cd frontend

# Development with hot reload
npm run dev

# Build for production
npm run build

# Start production server locally
npm start

# Lint code
npm run lint

# Type check
npm run build  # TypeScript is checked during build
```

### Database Management

#### Development (H2)

Access H2 console: [http://localhost:8080/h2-console](http://localhost:8080/h2-console)

#### Production (MySQL)

```bash
# Create database
mysql -u root -p
CREATE DATABASE kitchensink CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'kitchensink'@'localhost' IDENTIFIED BY 'your_password';
GRANT ALL PRIVILEGES ON kitchensink.* TO 'kitchensink'@'localhost';
FLUSH PRIVILEGES;
```

## 🐳 Docker Deployment

### Build Individual Images

**Backend:**
```bash
cd kitchensink
docker build -t kitchensink-backend:latest .
```

**Frontend:**
```bash
cd frontend
docker build \
  --build-arg NEXT_PUBLIC_API_URL=http://localhost:8080 \
  -t kitchensink-frontend:latest .
```

### Run with Docker Compose

```bash
# Build and start all services
docker-compose up --build

# Run in detached mode
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down

# Stop and remove volumes
docker-compose down -v
```

### Docker Compose Services

The `docker-compose.yml` includes:
- `frontend`: Next.js application (port 3000)
- `backend`: Spring Boot API (port 8080)
- `mysql`: MySQL database (port 3306)

### Environment Variables for Production

Create a `.env` file in the project root:

```env
# Database
MYSQL_ROOT_PASSWORD=secure_root_password
MYSQL_DATABASE=kitchensink
MYSQL_USER=kitchensink
MYSQL_PASSWORD=secure_password

# Backend
SPRING_PROFILES_ACTIVE=prod
DB_URL=jdbc:mysql://mysql:3306/kitchensink
DB_USERNAME=kitchensink
DB_PASSWORD=secure_password

# Frontend
NEXT_PUBLIC_API_URL=http://localhost:8080

# CORS
ALLOWED_ORIGINS=http://localhost:3000,https://your-domain.com
```

## ⚙️ Configuration

### Backend Configuration Files

- `application.properties`: Base configuration
- `application-dev.yml`: Development profile (H2 database)
- `application-prod.yml`: Production profile (MySQL database)

### Key Configuration Properties

```yaml
# Server
server:
  port: 8080
  shutdown: graceful

# Database (Production)
spring:
  datasource:
    url: ${DB_URL}
    username: ${DB_USERNAME}
    password: ${DB_PASSWORD}

# CORS
cors:
  allowed-origins: ${ALLOWED_ORIGINS}
```

### Frontend Environment Variables

```bash
# API URL
NEXT_PUBLIC_API_URL=http://localhost:8080

# Environment
NODE_ENV=production
```

## 📡 API Documentation

### Endpoints

#### Members API

**Get All Members**
```http
GET /rest/members
Content-Type: application/json

Response: 200 OK
[
  {
    "id": 1,
    "name": "John Doe",
    "email": "john.doe@example.com",
    "phoneNumber": "1234567890"
  }
]
```

**Get Member by ID**
```http
GET /rest/members/{id}
Content-Type: application/json

Response: 200 OK
{
  "id": 1,
  "name": "John Doe",
  "email": "john.doe@example.com",
  "phoneNumber": "1234567890"
}
```

**Register New Member**
```http
POST /rest/members
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john.doe@example.com",
  "phoneNumber": "1234567890"
}

Response: 201 Created
{
  "id": 1,
  "name": "John Doe",
  "email": "john.doe@example.com",
  "phoneNumber": "1234567890"
}
```

**Validation Errors**
```http
Response: 400 Bad Request
{
  "timestamp": "2024-01-15T10:30:00",
  "status": 400,
  "error": "Bad Request",
  "message": "Validation failed",
  "path": "/rest/members",
  "validationErrors": {
    "email": "Must be a valid email address",
    "phoneNumber": "Phone number must be 10-12 digits"
  }
}
```

### Health Check

```http
GET /actuator/health

Response: 200 OK
{
  "status": "UP"
}
```

## 🔒 Security

### Authentication

- **Current**: REST API is **open** (permitAll) for development
- **Production**: Change to `.authenticated()` in `SecurityConfig.java`

### Security Headers

The application includes:
- HTTP Strict Transport Security (HSTS)
- X-Frame-Options: DENY
- X-Content-Type-Options: nosniff

### CORS

Configured in `CorsConfig.java` and profile-specific YAML files.

### Credentials Management

- **Development**: Hardcoded credentials with **warnings**
- **Production**: Use environment variables
  - `DB_PASSWORD`
  - `SSL_KEY_STORE_PASSWORD`
  - `ALLOWED_ORIGINS`

### HTTPS

For production, enable SSL in `application-prod.yml`:

```yaml
server:
  ssl:
    enabled: true
    key-store: ${SSL_KEY_STORE}
    key-store-password: ${SSL_KEY_STORE_PASSWORD}
    key-store-type: PKCS12
```

## 🧪 Testing

### Backend Tests

```bash
cd kitchensink

# Run all tests
./mvnw test

# Run specific test
./mvnw test -Dtest=MemberRegistrationTest

# Generate test coverage
./mvnw jacoco:report
```

### Frontend Tests

```bash
cd frontend

# Run tests (after configuring Jest)
npm test

# Run tests in watch mode
npm test -- --watch

# Generate coverage
npm test -- --coverage
```

## 📚 Migration Guide

### From J2EE to Spring Boot

This project demonstrates the following migrations:

1. **EJB to Spring Services**
   ```java
   // Before (J2EE)
   @Stateless
   public class MemberRegistration {
       @Inject
       private EntityManager em;
   }
   
   // After (Spring Boot)
   @Service
   public class MemberRegistration {
       private final MemberRepository repository;
       
       public MemberRegistration(MemberRepository repository) {
           this.repository = repository;
       }
   }
   ```

2. **JAX-RS to Spring MVC**
   ```java
   // Before (JAX-RS)
   @Path("/members")
   public class MemberResourceRESTService {
       @GET
       @Produces(MediaType.APPLICATION_JSON)
       public List<Member> listAllMembers() { }
   }
   
   // After (Spring MVC)
   @RestController
   @RequestMapping("/rest/members")
   public class MemberResourceRESTService {
       @GetMapping
       public List<Member> listAllMembers() { }
   }
   ```

3. **JSF to Next.js**
   - Server-side JSF pages → React components
   - Managed beans → React hooks and state management
   - Ajax → React Query for data fetching

## 🤝 Contributing

1. Create feature branch from `main`
2. Follow code style guidelines
3. Write tests for new features
4. Update documentation
5. Submit pull request

## 📄 License

This project is a modernized version of the JBoss Kitchensink quickstart application.

## 🆘 Troubleshooting

### Backend Issues

**Port 8080 already in use:**
```bash
# Change port in application.properties
server.port=8081
```

**Database connection failed:**
- Check MySQL is running
- Verify credentials in environment variables
- Test connection: `mysql -u kitchensink -p`

### Frontend Issues

**API connection refused:**
- Ensure backend is running on port 8080
- Check `NEXT_PUBLIC_API_URL` in `.env.local`
- Verify CORS configuration in backend

**Build errors:**
```bash
# Clear cache and reinstall
rm -rf node_modules .next
npm install
npm run build
```

### Docker Issues

**Port conflicts:**
```bash
# Check what's using ports
lsof -i :3000
lsof -i :8080

# Use different ports in docker-compose.yml
```

**Container health checks failing:**
```bash
# Check container logs
docker-compose logs backend
docker-compose logs frontend

# Execute commands in container
docker-compose exec backend curl http://localhost:8080/actuator/health
```

## 📞 Support

For questions or issues:
1. Check this README
2. Review individual component READMEs (`kitchensink/README.md`, `frontend/README.md`)
3. Check application logs
4. Review Spring Boot and Next.js documentation

## 🎉 Acknowledgments

- Original JBoss EAP Kitchensink quickstart application
- Spring Boot team for excellent framework
- Next.js team for amazing React framework
- Open source community

---

**Built with ❤️ demonstrating modern Java and React development practices**
