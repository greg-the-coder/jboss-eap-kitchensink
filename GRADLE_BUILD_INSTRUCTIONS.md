# Gradle Build Instructions

## Overview
This project has been migrated from J2EE (JBoss EAP) to Spring Boot 3.x and converted from Maven to Gradle build system.

## Prerequisites

### Required Software
1. **Java Development Kit (JDK) 17 or higher**
   - Download from: https://adoptium.net/ (recommended) or https://www.oracle.com/java/technologies/downloads/
   - Verify installation: `java -version`

2. **Gradle 8.5 or higher** (optional if using wrapper)
   - Download from: https://gradle.org/install/
   - Verify installation: `gradle --version`

### Environment Setup

```bash
# Set JAVA_HOME (Linux/Mac)
export JAVA_HOME=/path/to/your/jdk17
export PATH=$JAVA_HOME/bin:$PATH

# Set JAVA_HOME (Windows)
set JAVA_HOME=C:\Path\To\Your\JDK17
set PATH=%JAVA_HOME%\bin;%PATH%
```

## Building the Project

### Option 1: Using Gradle (if installed)
```bash
cd ~/projects/jboss-eap-kitchensink
gradle build
```

### Option 2: Generate and use Gradle Wrapper (recommended)
```bash
# Generate wrapper (requires Gradle to be installed)
cd ~/projects/jboss-eap-kitchensink
gradle wrapper --gradle-version 8.5

# Build using wrapper (no Gradle installation needed after this)
./gradlew build          # Linux/Mac
gradlew.bat build        # Windows
```

### Option 3: Using Maven (pom.xml still present)
```bash
cd ~/projects/jboss-eap-kitchensink/kitchensink
mvn clean install
```

## Build Output

Successful build will produce:
- Executable JAR: `build/libs/jboss-kitchensink-6.4.0-SNAPSHOT.jar`
- Test reports: `build/reports/tests/test/index.html`
- Build logs: Console output or redirect to file with `gradle build > build.log 2>&1`

## Running the Application

### Using Gradle
```bash
gradle bootRun
```

### Using the JAR
```bash
java -jar build/libs/jboss-kitchensink-6.4.0-SNAPSHOT.jar
```

## Project Structure

```
jboss-eap-kitchensink/
├── build.gradle                          # Gradle build configuration
├── settings.gradle                       # Gradle settings
├── kitchensink/
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/                     # Java source files
│   │   │   │   └── org/jboss/as/quickstarts/kitchensink/
│   │   │   │       ├── KitchensinkApplication.java
│   │   │   │       ├── model/
│   │   │   │       │   └── Member.java
│   │   │   │       ├── data/
│   │   │   │       │   └── MemberRepository.java
│   │   │   │       ├── service/
│   │   │   │       │   └── MemberRegistration.java
│   │   │   │       ├── rest/
│   │   │   │       │   └── MemberResourceRESTService.java
│   │   │   │       ├── config/
│   │   │   │       │   └── SecurityConfig.java
│   │   │   │       └── exception/
│   │   │   │           ├── GlobalExceptionHandler.java
│   │   │   │           └── ErrorResponse.java
│   │   │   └── resources/
│   │   │       ├── application.properties
│   │   │       ├── application-dev.yml
│   │   │       └── application-prod.yml
│   │   └── test/
│   │       └── java/                     # Test source files
│   └── pom.xml                           # Maven POM (for Maven builds)
└── Dockerfile                            # Container configuration
```

## Gradle Build Configuration

### Dependencies
The build.gradle includes:
- Spring Boot 3.2.1 with starters for web, data-jpa, validation, security, actuator
- H2 database (for development/testing)
- MySQL connector (for production)
- Spring Boot Test with security test support

### Key Gradle Tasks
```bash
gradle clean           # Clean build directory
gradle build           # Compile, test, and package
gradle test            # Run tests only
gradle bootRun         # Run the application
gradle bootJar         # Create executable JAR
gradle tasks           # List all available tasks
```

## Troubleshooting

### Issue: "JAVA_HOME is not set"
**Solution**: Set JAVA_HOME environment variable to your JDK installation path

### Issue: "Gradle not found"
**Solution**: 
1. Install Gradle from https://gradle.org/install/, OR
2. Use Maven instead: `cd kitchensink && mvn clean install`

### Issue: "Could not target platform: 'Java SE 17'"
**Solution**: Ensure JDK 17 or higher is installed and JAVA_HOME is correctly set

### Issue: Build fails with compilation errors
**Solution**: Check the Spring Boot migration in the source files under kitchensink/src/main/java/

## Additional Resources

- Spring Boot Documentation: https://docs.spring.io/spring-boot/docs/3.2.1/reference/html/
- Gradle User Manual: https://docs.gradle.org/current/userguide/userguide.html
- Project Migration Summary: See MIGRATION_SUMMARY.md

## Configuration Profiles

The application supports multiple profiles:
- `dev`: Development profile with H2 in-memory database
- `prod`: Production profile (requires external database configuration)

Activate a profile:
```bash
gradle bootRun --args='--spring.profiles.active=dev'
# OR
java -jar build/libs/jboss-kitchensink-6.4.0-SNAPSHOT.jar --spring.profiles.active=prod
```

## Security Note

Default security is enabled. Update credentials in SecurityConfig.java for production use.
Never commit credentials to version control.
