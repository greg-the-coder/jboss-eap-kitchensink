# Kitchensink: Spring Boot Migration

**Author:** Pete Muir (Original), Spring Boot Migration Team  
**Level:** Intermediate  
**Technologies:** Spring Boot 3.2, Spring Data JPA, Spring Security, Spring MVC, Bean Validation, H2/MySQL  
**Summary:** The `kitchensink` application demonstrates a modern Spring Boot 3.x web application with REST API, JPA persistence, and security. This is a migration from the original Java EE 6 JBoss EAP quickstart.  
**Target Platform:** Spring Boot 3.2+ with Java 21  
**Source:** Migrated from [JBoss EAP Quickstarts](https://github.com/jboss-developer/jboss-eap-quickstarts/)

## What is it?

The `kitchensink` application is a Spring Boot 3.x project that demonstrates modern Java enterprise development practices. It has been migrated from the original Java EE 6 JBoss EAP quickstart to showcase:

- **Spring Boot 3.2** with auto-configuration and embedded server
- **Spring Data JPA** for simplified data access
- **Spring MVC REST** controllers for RESTful web services
- **Spring Security** for authentication and authorization
- **Bean Validation** with Jakarta validation annotations
- **Containerization** with Docker and multi-stage builds
- **Production-ready features** with Spring Boot Actuator

## Migration Summary

This application has been transformed from Java EE 6 to Spring Boot 3.x:

| Original Technology | Migrated To | Notes |
|-------------------|-------------|-------|
| JBoss EAP 6 | Spring Boot 3.2 | Embedded Tomcat server |
| CDI | Spring IoC Container | Constructor-based dependency injection |
| EJB @Stateless | @Service | Spring service components |
| JAX-RS | Spring MVC @RestController | RESTful web services |
| JPA 2.0 | Spring Data JPA | Simplified repository pattern |
| JSF 2.1 | Static HTML + REST API | Modern frontend approach |
| Bean Validation 1.0 | Jakarta Validation 3.0 | Updated validation annotations |
| Java EE Security | Spring Security 6 | HTTP Basic authentication |
| Arquillian Tests | Spring Boot Test | Integration testing |

## System Requirements

- **Java:** 21 or later (LTS recommended)
- **Maven:** 3.9 or later
- **Docker:** Optional, for containerized deployment
- **Memory:** Minimum 512MB RAM

## Quick Start

### 1. Build and Run Locally

```bash
# Clone and navigate to project
cd kitchensink

# Build the application
mvn clean package

# Run the application
java -jar target/jboss-kitchensink.jar

# Or run with Maven
mvn spring-boot:run
```

### 2. Access the Application

- **Web Interface:** http://localhost:8080
- **REST API:** http://localhost:8080/rest/members
- **Health Check:** http://localhost:8080/actuator/health
- **Application Info:** http://localhost:8080/actuator/info

### 3. Docker Deployment

```bash
# Build Docker image
docker build -t kitchensink:latest .

# Run container
docker run -p 8080:8080 kitchensink:latest

# Or use the runtime-optimized image
docker build -f Dockerfile.runtime -t kitchensink:runtime .
docker run -p 8080:8080 kitchensink:runtime
```

## Configuration

### Application Profiles

The application supports multiple profiles:

- **default:** H2 in-memory database
- **dev:** H2 with file persistence (`application-dev.yml`)
- **prod:** MySQL database (`application-prod.yml`)
- **test:** H2 in-memory for testing (`application-test.yml`)

### Environment Variables

For production deployment, configure these environment variables:

```bash
# Database Configuration
SPRING_DATASOURCE_URL=jdbc:mysql://localhost:3306/kitchensink
SPRING_DATASOURCE_USERNAME=kitchensink_user
SPRING_DATASOURCE_PASSWORD=your_password

# Security Configuration
APP_SECURITY_USER_USERNAME=user
APP_SECURITY_USER_PASSWORD=secure_password
APP_SECURITY_ADMIN_USERNAME=admin
APP_SECURITY_ADMIN_PASSWORD=admin_password

# Server Configuration
SERVER_PORT=8080
```

### Database Setup

#### H2 (Development)
No setup required - uses in-memory database by default.

#### MySQL (Production)
```sql
CREATE DATABASE kitchensink;
CREATE USER 'kitchensink_user'@'%' IDENTIFIED BY 'your_password';
GRANT ALL PRIVILEGES ON kitchensink.* TO 'kitchensink_user'@'%';
FLUSH PRIVILEGES;
```

## REST API

### Endpoints

| Method | Endpoint | Description | Authentication |
|--------|----------|-------------|----------------|
| GET | `/rest/members` | List all members | None |
| GET | `/rest/members/{id}` | Get member by ID | None |
| POST | `/rest/members` | Create new member | None |
| GET | `/actuator/health` | Health check | None |
| GET | `/actuator/info` | Application info | None |

### Example Usage

```bash
# List all members
curl http://localhost:8080/rest/members

# Create a new member
curl -X POST http://localhost:8080/rest/members \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "phoneNumber": "1234567890"
  }'

# Get member by ID
curl http://localhost:8080/rest/members/1
```

## Testing

### Run Unit Tests
```bash
mvn test
```

### Run Integration Tests
```bash
mvn verify
```

### Test with Different Profiles
```bash
# Test with dev profile
mvn test -Dspring.profiles.active=dev

# Test with production-like settings
mvn test -Dspring.profiles.active=prod
```

## Security

The application includes Spring Security with:

- **HTTP Basic Authentication** for API access (configurable)
- **CORS support** for cross-origin requests
- **Security headers** (HSTS, X-Frame-Options, etc.)
- **Actuator endpoint protection**

For production:
- Enable HTTPS/TLS
- Use external authentication provider (OAuth2, LDAP)
- Configure proper CORS origins
- Use database-backed user management

## Monitoring and Operations

### Health Checks
- **Liveness:** `/actuator/health/liveness`
- **Readiness:** `/actuator/health/readiness`
- **Overall Health:** `/actuator/health`

### Metrics
- **Application Metrics:** `/actuator/metrics`
- **JVM Metrics:** Built-in with Micrometer

### Logging
Structured logging with configurable levels:
```properties
logging.level.org.jboss.as.quickstarts.kitchensink=DEBUG
logging.level.org.springframework.security=INFO
```

## Deployment Options

### 1. Standalone JAR
```bash
java -jar target/jboss-kitchensink.jar
```

### 2. Docker Container
```bash
docker run -p 8080:8080 kitchensink:latest
```

### 3. Kubernetes
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: kitchensink
spec:
  replicas: 3
  selector:
    matchLabels:
      app: kitchensink
  template:
    metadata:
      labels:
        app: kitchensink
    spec:
      containers:
      - name: kitchensink
        image: kitchensink:latest
        ports:
        - containerPort: 8080
        env:
        - name: SPRING_PROFILES_ACTIVE
          value: "prod"
```

### 4. OpenShift
The application includes OpenShift build configurations in `.openshift/` directory.

## Development

### Project Structure
```
src/
├── main/
│   ├── java/org/jboss/as/quickstarts/kitchensink/
│   │   ├── KitchensinkApplication.java    # Spring Boot main class
│   │   ├── config/                        # Configuration classes
│   │   ├── data/                          # Repository interfaces
│   │   ├── model/                         # JPA entities
│   │   ├── rest/                          # REST controllers
│   │   ├── service/                       # Business services
│   │   └── exception/                     # Exception handling
│   ├── resources/
│   │   ├── application.properties         # Main configuration
│   │   ├── application-*.yml             # Profile-specific config
│   │   └── import.sql                    # Sample data
│   └── webapp/                           # Static web resources
└── test/                                 # Test classes
```

### Key Classes

- **KitchensinkApplication:** Spring Boot main class
- **Member:** JPA entity with validation annotations
- **MemberRepository:** Spring Data JPA repository
- **MemberResourceRESTService:** REST controller
- **MemberRegistration:** Business service
- **SecurityConfig:** Spring Security configuration

## Migration Notes

### Breaking Changes from Java EE Version
1. **URL Changes:** Application runs on port 8080 by default
2. **API Endpoints:** REST endpoints moved to `/rest/members`
3. **Authentication:** HTTP Basic auth instead of container security
4. **Database:** H2 in-memory by default (was file-based)
5. **Packaging:** JAR instead of WAR deployment

### Compatibility
- **Java:** Requires Java 21+ (was Java 6+)
- **Database:** H2, MySQL, PostgreSQL supported
- **Containers:** Docker, Kubernetes, OpenShift ready

## Troubleshooting

### Common Issues

1. **Port Already in Use**
   ```bash
   # Change port
   java -jar target/jboss-kitchensink.jar --server.port=8081
   ```

2. **Database Connection Issues**
   ```bash
   # Check database connectivity
   curl http://localhost:8080/actuator/health
   ```

3. **Memory Issues**
   ```bash
   # Increase heap size
   java -Xmx1g -jar target/jboss-kitchensink.jar
   ```

### Logs
Application logs are available at:
- Console output (default)
- Configure file logging in `application.properties`

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes with tests
4. Submit a pull request

## License

Licensed under the Apache License, Version 2.0. See LICENSE file for details.

## Support

For issues and questions:
- Check the troubleshooting section
- Review Spring Boot documentation
- Open an issue in the project repository