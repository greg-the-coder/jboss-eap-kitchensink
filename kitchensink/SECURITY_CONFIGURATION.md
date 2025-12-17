# Security Configuration Guide

## Overview

The Kitchensink Spring Boot application implements security using Spring Security with externalized credentials for better security posture.

## Default Configuration

The application provides default credentials for development purposes, but these should be changed for production environments.

### Security Credentials

All security credentials are externalized and can be overridden via environment variables:

#### User Account
- **Username**: Set via `APP_SECURITY_USER_USERNAME` environment variable (default: `user`)
- **Password**: Set via `APP_SECURITY_USER_PASSWORD` environment variable (default: `password`)
- **Roles**: `USER`

#### Admin Account
- **Username**: Set via `APP_SECURITY_ADMIN_USERNAME` environment variable (default: `admin`)
- **Password**: Set via `APP_SECURITY_ADMIN_PASSWORD` environment variable (default: `admin`)
- **Roles**: `USER`, `ADMIN`

## Running with Custom Credentials

### Using Environment Variables

```bash
# Set environment variables
export APP_SECURITY_USER_USERNAME=myuser
export APP_SECURITY_USER_PASSWORD=SecurePassword123!
export APP_SECURITY_ADMIN_USERNAME=myadmin
export APP_SECURITY_ADMIN_PASSWORD=SecureAdminPass456!

# Run the application
java -jar target/jboss-kitchensink.jar
```

### Using Command-Line Arguments

```bash
java -jar target/jboss-kitchensink.jar \
  --app.security.user.username=myuser \
  --app.security.user.password=SecurePassword123! \
  --app.security.admin.username=myadmin \
  --app.security.admin.password=SecureAdminPass456!
```

### Docker Environment

```bash
docker run -p 8080:8080 \
  -e APP_SECURITY_USER_USERNAME=myuser \
  -e APP_SECURITY_USER_PASSWORD=SecurePassword123! \
  -e APP_SECURITY_ADMIN_USERNAME=myadmin \
  -e APP_SECURITY_ADMIN_PASSWORD=SecureAdminPass456! \
  kitchensink:latest
```

### Kubernetes Secrets

Create a Kubernetes secret:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: kitchensink-credentials
type: Opaque
stringData:
  user-username: myuser
  user-password: SecurePassword123!
  admin-username: myadmin
  admin-password: SecureAdminPass456!
```

Reference in deployment:

```yaml
env:
  - name: APP_SECURITY_USER_USERNAME
    valueFrom:
      secretKeyRef:
        name: kitchensink-credentials
        key: user-username
  - name: APP_SECURITY_USER_PASSWORD
    valueFrom:
      secretKeyRef:
        name: kitchensink-credentials
        key: user-password
  - name: APP_SECURITY_ADMIN_USERNAME
    valueFrom:
      secretKeyRef:
        name: kitchensink-credentials
        key: admin-username
  - name: APP_SECURITY_ADMIN_PASSWORD
    valueFrom:
      secretKeyRef:
        name: kitchensink-credentials
        key: admin-password
```

## Security Features

### Authentication
- HTTP Basic Authentication for REST APIs
- BCrypt password hashing for secure credential storage
- Stateless session management suitable for microservices

### Authorization
- Role-based access control (RBAC)
- Public endpoints: `/actuator/health`, `/actuator/info`, `/rest/**`
- Protected endpoints require authentication

### Security Headers
- HTTP Strict Transport Security (HSTS) with 1-year max-age
- X-Frame-Options: DENY (prevents clickjacking)
- X-Content-Type-Options: nosniff
- XSS Protection disabled (modern browsers have built-in protection)

### SSL/TLS Configuration (Production)

For production deployments, enable HTTPS by adding the following to your configuration:

```properties
server.ssl.enabled=true
server.ssl.key-store=${SSL_KEY_STORE:/path/to/keystore.p12}
server.ssl.key-store-password=${SSL_KEY_STORE_PASSWORD}
server.ssl.key-store-type=PKCS12
server.ssl.key-alias=tomcat
```

Generate a keystore:

```bash
keytool -genkeypair -alias tomcat -keyalg RSA -keysize 2048 \
  -storetype PKCS12 -keystore keystore.p12 -validity 3650 \
  -storepass changeit
```

## Production Recommendations

1. **Replace In-Memory Authentication**: For production, implement database-backed authentication or integrate with an external identity provider (LDAP, OAuth2, SAML, etc.)

2. **Use Secrets Management**: Use a dedicated secrets management solution (AWS Secrets Manager, HashiCorp Vault, Azure Key Vault, etc.)

3. **Enable HTTPS**: Always use HTTPS/TLS in production environments

4. **Enforce Authentication**: Change REST API endpoints from `permitAll()` to `authenticated()` in SecurityConfig

5. **Implement Rate Limiting**: Add rate limiting to prevent brute-force attacks

6. **Monitor Security Events**: Implement security event logging and monitoring

7. **Regular Security Updates**: Keep dependencies updated to patch security vulnerabilities

8. **Strong Password Policy**: Enforce strong password requirements for user accounts

## Development Profile

The development profile (`application-dev.yml`) also supports externalized credentials:

```yaml
spring:
  security:
    user:
      name: ${DEV_USERNAME:dev}
      password: ${DEV_PASSWORD:dev}
```

Set `DEV_USERNAME` and `DEV_PASSWORD` environment variables to override development defaults.

## Testing

Security is disabled for tests via the test profile (`application-test.yml`) to simplify test execution.

## Questions or Issues?

For security concerns or questions, please contact your security team or refer to Spring Security documentation: https://docs.spring.io/spring-security/reference/
