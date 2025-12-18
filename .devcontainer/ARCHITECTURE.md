# DevContainer Architecture

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                          Host Machine                                │
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │                     Docker Engine                              │  │
│  │  ┌─────────────────────────────────────────────────────────┐  │  │
│  │  │              Dev Container Environment                   │  │  │
│  │  │  ┌───────────────────────────────────────────────────┐  │  │  │
│  │  │  │         Workspace Container (workspace)            │  │  │  │
│  │  │  │  ┌──────────────────────────────────────────────┐  │  │  │  │
│  │  │  │  │   Base: eclipse-temurin:17-jdk-jammy         │  │  │  │  │
│  │  │  │  │                                               │  │  │  │  │
│  │  │  │  │   Tools Installed:                           │  │  │  │  │
│  │  │  │  │   • Java 21 (OpenJDK)                        │  │  │  │  │
│  │  │  │  │   • Gradle 8.5                               │  │  │  │  │
│  │  │  │  │   • Maven 3.9.6                              │  │  │  │  │
│  │  │  │  │   • Git, curl, wget                          │  │  │  │  │
│  │  │  │  │   • Zsh with oh-my-zsh                       │  │  │  │  │
│  │  │  │  │   • Docker CLI                               │  │  │  │  │
│  │  │  │  │                                               │  │  │  │  │
│  │  │  │  │   Ports Exposed:                             │  │  │  │  │
│  │  │  │  │   • 8080 → Spring Boot App                   │  │  │  │  │
│  │  │  │  │   • 5005 → Debug Port                        │  │  │  │  │
│  │  │  │  │                                               │  │  │  │  │
│  │  │  │  │   Volumes Mounted:                           │  │  │  │  │
│  │  │  │  │   • /workspace ← Repository                  │  │  │  │  │
│  │  │  │  │   • /workspace/.gradle ← Gradle cache        │  │  │  │  │
│  │  │  │  │   • /root/.m2 ← Maven cache                  │  │  │  │  │
│  │  │  │  │   • /var/run/docker.sock ← Docker socket     │  │  │  │  │
│  │  │  │  └──────────────────────────────────────────────┘  │  │  │  │
│  │  │  └───────────────────────────────────────────────────┘  │  │  │
│  │  │                                                          │  │  │
│  │  │  ┌───────────────────────────────────────────────────┐  │  │  │
│  │  │  │       MySQL Container (mysql)                     │  │  │  │
│  │  │  │  ┌──────────────────────────────────────────────┐  │  │  │  │
│  │  │  │  │   Image: mysql:8.0                           │  │  │  │  │
│  │  │  │  │                                               │  │  │  │  │
│  │  │  │  │   Database: kitchensink                      │  │  │  │  │
│  │  │  │  │   User: kitchensink / kitchensink            │  │  │  │  │
│  │  │  │  │                                               │  │  │  │  │
│  │  │  │  │   Port: 3306                                  │  │  │  │  │
│  │  │  │  │                                               │  │  │  │  │
│  │  │  │  │   Volume: mysql-data:/var/lib/mysql          │  │  │  │  │
│  │  │  │  │   Init: init-db.sql                          │  │  │  │  │
│  │  │  │  └──────────────────────────────────────────────┘  │  │  │  │
│  │  │  └───────────────────────────────────────────────────┘  │  │  │
│  │  │                                                          │  │  │
│  │  │  ┌───────────────────────────────────────────────────┐  │  │  │
│  │  │  │     PostgreSQL Container (postgres)               │  │  │  │
│  │  │  │  ┌──────────────────────────────────────────────┐  │  │  │  │
│  │  │  │  │   Image: postgres:16-bookworm                │  │  │  │  │
│  │  │  │  │                                               │  │  │  │  │
│  │  │  │  │   Database: kitchensink                      │  │  │  │  │
│  │  │  │  │   User: kitchensink / kitchensink            │  │  │  │  │
│  │  │  │  │                                               │  │  │  │  │
│  │  │  │  │   Port: 5432                                  │  │  │  │  │
│  │  │  │  │                                               │  │  │  │  │
│  │  │  │  │   Volume: postgres-data:/var/lib/postgresql  │  │  │  │  │
│  │  │  │  └──────────────────────────────────────────────┘  │  │  │  │
│  │  │  └───────────────────────────────────────────────────┘  │  │  │
│  │  │                                                          │  │  │
│  │  │  ┌───────────────────────────────────────────────────┐  │  │  │
│  │  │  │            Shared Volumes                         │  │  │  │
│  │  │  │  • mysql-data (persistent)                        │  │  │  │
│  │  │  │  • postgres-data (persistent)                     │  │  │  │
│  │  │  │  • gradle-cache (persistent)                      │  │  │  │
│  │  │  │  • maven-cache (persistent)                       │  │  │  │
│  │  │  └───────────────────────────────────────────────────┘  │  │  │
│  │  └─────────────────────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                    VS Code / Coder IDE                               │
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │  Extensions Auto-Installed:                                   │  │
│  │  • Java Extension Pack                                        │  │
│  │  • Spring Boot Extensions                                     │  │
│  │  • Gradle & Maven for Java                                    │  │
│  │  • Docker Extension                                           │  │
│  │  • GitLens                                                     │  │
│  │  • REST Client                                                │  │
│  │  • SonarLint                                                  │  │
│  └───────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
```

## 🔄 Network Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      Docker Network                             │
│                                                                 │
│  ┌─────────────┐         ┌──────────────┐                     │
│  │  workspace  │◄────────┤    mysql     │                     │
│  │  container  │         │  (port 3306) │                     │
│  │             │         └──────────────┘                     │
│  │  Shares     │                │                              │
│  │  network    │         ┌──────────────┐                     │
│  │  with mysql │────────►│  postgres    │                     │
│  │             │         │  (port 5432) │                     │
│  └─────────────┘         └──────────────┘                     │
│         │                                                       │
│         │ (Docker socket mounted)                              │
│         ▼                                                       │
│  ┌─────────────┐                                               │
│  │Docker Engine│                                               │
│  └─────────────┘                                               │
└─────────────────────────────────────────────────────────────────┘
         │
         │ (Port forwarding)
         ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Host Machine Ports                           │
│  • localhost:8080  → Spring Boot Application                   │
│  • localhost:3306  → MySQL Database                            │
│  • localhost:5432  → PostgreSQL Database                       │
│  • localhost:5005  → Java Debug Port                           │
└─────────────────────────────────────────────────────────────────┘
```

## 📦 Volume Architecture

```
Persistent Volumes (Survive container restarts):
┌────────────────────────────────────────────────────────┐
│  mysql-data                                            │
│  • Stores MySQL database files                        │
│  • Mounted to: /var/lib/mysql in mysql container      │
│  • Size: Grows with data (typically 100MB-1GB)        │
└────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────┐
│  postgres-data                                         │
│  • Stores PostgreSQL database files                   │
│  • Mounted to: /var/lib/postgresql/data               │
│  • Size: Grows with data (typically 100MB-1GB)        │
└────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────┐
│  gradle-cache                                          │
│  • Stores Gradle dependencies and build cache         │
│  • Mounted to: /workspace/.gradle                     │
│  • Size: 500MB-2GB (faster subsequent builds)         │
└────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────┐
│  maven-cache                                           │
│  • Stores Maven dependencies                          │
│  • Mounted to: /root/.m2                              │
│  • Size: 500MB-2GB (faster subsequent builds)         │
└────────────────────────────────────────────────────────┘

Bind Mounts (Direct access to host filesystem):
┌────────────────────────────────────────────────────────┐
│  Repository Root                                       │
│  • Source: Host repository directory                  │
│  • Target: /workspace in workspace container          │
│  • Type: Cached (optimized for read-heavy workloads)  │
└────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────┐
│  Docker Socket                                         │
│  • Source: /var/run/docker.sock (host)                │
│  • Target: /var/run/docker.sock (container)           │
│  • Enables Docker-in-Docker functionality             │
└────────────────────────────────────────────────────────┘
```

## 🔄 Startup Sequence

```
1. User Action
   ↓
   "Dev Containers: Reopen in Container"
   ↓
2. Docker Compose
   ↓
   Read: .devcontainer/docker-compose.yml
   ↓
3. Build/Pull Images
   ↓
   ├─► Build workspace (Dockerfile) [5-10 min first time]
   ├─► Pull mysql:8.0 [1-2 min]
   └─► Pull postgres:16-bookworm [1-2 min]
   ↓
4. Create Volumes
   ↓
   ├─► mysql-data
   ├─► postgres-data
   ├─► gradle-cache
   └─► maven-cache
   ↓
5. Start Services
   ↓
   ├─► MySQL (with init-db.sql)
   ├─► PostgreSQL
   └─► Workspace (waits for databases)
   ↓
6. Health Checks
   ↓
   ├─► MySQL ready? ✓
   └─► PostgreSQL ready? ✓
   ↓
7. Post-Create Commands
   ↓
   • Initialize Gradle wrapper
   • Verify Gradle installation
   ↓
8. VS Code Connection
   ↓
   ├─► Install extensions
   ├─► Apply settings
   ├─► Forward ports
   └─► Open terminal (zsh)
   ↓
9. Ready!
   ↓
   Display welcome message
```

## 🔒 Security Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    Security Layers                              │
│                                                                 │
│  Layer 1: Network Isolation                                    │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │  • Containers in isolated Docker network                  │ │
│  │  • Only specified ports exposed to host                   │ │
│  │  • Workspace shares network with mysql (minimal exposure) │ │
│  └───────────────────────────────────────────────────────────┘ │
│                                                                 │
│  Layer 2: File System                                          │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │  • Workspace has read/write to /workspace only            │ │
│  │  • Docker socket (privileged, required for Docker-in-Docker)│
│  │  • Database volumes isolated from workspace               │ │
│  └───────────────────────────────────────────────────────────┘ │
│                                                                 │
│  Layer 3: Credentials                                          │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │  • Database credentials in environment (dev-only values)  │ │
│  │  • No production credentials stored                       │ │
│  │  • Configurable via devcontainer.json                     │ │
│  └───────────────────────────────────────────────────────────┘ │
│                                                                 │
│  Layer 4: User Context                                         │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │  • Running as root (standard for dev containers)          │ │
│  │  • Note: This is acceptable for development environments  │ │
│  │  • Production containers use non-root (see app Dockerfile)│ │
│  └───────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

## 🎯 Data Flow

```
Development Workflow:
┌──────────┐     ┌────────────┐     ┌──────────┐     ┌──────────┐
│Developer │────►│  VS Code   │────►│Workspace │────►│  MySQL   │
│  writes  │     │   saves    │     │ container│     │  or H2   │
│   code   │     │   file     │     │  builds  │     │ database │
└──────────┘     └────────────┘     └──────────┘     └──────────┘
                                           │
                                           ▼
                                    ┌──────────────┐
                                    │ Spring Boot  │
                                    │   runs on    │
                                    │  port 8080   │
                                    └──────────────┘
                                           │
                                           ▼
                                    ┌──────────────┐
                                    │   Browser    │
                                    │  localhost   │
                                    │    :8080     │
                                    └──────────────┘

Build & Cache Flow:
┌─────────────┐     ┌──────────────┐     ┌──────────────┐
│   Gradle    │────►│ gradle-cache │────►│  Faster      │
│   build     │     │   volume     │     │ subsequent   │
└─────────────┘     └──────────────┘     │   builds     │
                                          └──────────────┘
```

## 🔧 Extension Architecture

```
VS Code Extensions (Auto-installed in dev container):

Core Java Development:
┌────────────────────────────────────────────────────────┐
│ Language Support for Java (Red Hat)                    │
│ • IntelliSense, code navigation, refactoring           │
│ • Syntax highlighting, error detection                 │
└────────────────────────────────────────────────────────┘
┌────────────────────────────────────────────────────────┐
│ Debugger for Java                                      │
│ • Breakpoints, step debugging, variable inspection     │
│ • Remote debugging support (port 5005)                 │
└────────────────────────────────────────────────────────┘
┌────────────────────────────────────────────────────────┐
│ Test Runner for Java                                   │
│ • Run/debug JUnit tests                                │
│ • Test explorer view                                   │
└────────────────────────────────────────────────────────┘

Spring Boot:
┌────────────────────────────────────────────────────────┐
│ Spring Boot Tools                                      │
│ • Spring Boot dashboard                                │
│ • Live application information                         │
│ • Quick navigation to beans, endpoints                 │
└────────────────────────────────────────────────────────┘
┌────────────────────────────────────────────────────────┐
│ Spring Initializr                                      │
│ • Create new Spring projects                           │
│ • Add dependencies                                     │
└────────────────────────────────────────────────────────┘

Build Tools:
┌────────────────────────────────────────────────────────┐
│ Gradle for Java                                        │
│ • Task runner, dependency management                   │
│ • Gradle wrapper support                               │
└────────────────────────────────────────────────────────┘
┌────────────────────────────────────────────────────────┐
│ Maven for Java                                         │
│ • POM editing, dependency management                   │
│ • Maven lifecycle commands                             │
└────────────────────────────────────────────────────────┘

DevOps:
┌────────────────────────────────────────────────────────┐
│ Docker                                                 │
│ • Docker file support, image management                │
│ • Container management from VS Code                    │
└────────────────────────────────────────────────────────┘
┌────────────────────────────────────────────────────────┐
│ GitLens                                                │
│ • Git blame, history, compare                          │
│ • Rich commit information                              │
└────────────────────────────────────────────────────────┘

Quality & Testing:
┌────────────────────────────────────────────────────────┐
│ SonarLint                                              │
│ • Code quality analysis                                │
│ • Bug detection, code smells                           │
└────────────────────────────────────────────────────────┘
┌────────────────────────────────────────────────────────┐
│ REST Client                                            │
│ • Test API endpoints                                   │
│ • Create .http files for requests                      │
└────────────────────────────────────────────────────────┘

Configuration:
┌────────────────────────────────────────────────────────┐
│ YAML, XML Support                                      │
│ • Syntax highlighting for config files                 │
│ • Schema validation                                    │
└────────────────────────────────────────────────────────┘
```

## 🚀 Performance Optimization

```
Optimization Strategy:

1. Image Layer Caching
   ┌─────────────────────────────────────────┐
   │ Base image (eclipse-temurin)            │  ← Rarely changes
   ├─────────────────────────────────────────┤
   │ System packages (apt-get)               │  ← Rarely changes
   ├─────────────────────────────────────────┤
   │ Zsh installation                        │  ← Rarely changes
   ├─────────────────────────────────────────┤
   │ Gradle installation                     │  ← Rarely changes
   ├─────────────────────────────────────────┤
   │ Maven installation                      │  ← Rarely changes
   ├─────────────────────────────────────────┤
   │ Environment variables                   │  ← May change
   ├─────────────────────────────────────────┤
   │ Welcome message script                  │  ← May change
   └─────────────────────────────────────────┘

2. Volume Caching
   • Gradle cache: Prevents re-downloading dependencies
   • Maven cache: Prevents re-downloading dependencies
   • Database volumes: Preserve data across restarts

3. Parallel Service Startup
   • MySQL and PostgreSQL start in parallel
   • Workspace waits only for required services

4. Optimized File Watching
   • .gradle/ and build/ excluded from file watcher
   • Reduces CPU usage during builds

5. Network Mode Sharing
   • Workspace shares network with mysql
   • Eliminates network hop for database connections
   • Faster database access
```

---

**Visual Diagrams Created Using**: ASCII Art
**Last Updated**: 2024-12-17
**Version**: 1.0.0
