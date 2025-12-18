# Dockerfile for JBoss EAP Kitchensink Full-Stack Development Environment
# Supports both Backend (Java/Spring Boot) and Frontend (Next.js/TypeScript)

FROM eclipse-temurin:21-jdk-jammy

# Install essential tools
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    unzip \
    vim \
    nano \
    jq \
    netcat \
    iputils-ping \
    net-tools \
    socat \
    fortune-mod \
    cowsay \
    lolcat \
    ca-certificates \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 20.x (LTS) for frontend development
RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Verify Node.js and npm installation
RUN node --version && npm --version

# Install global npm packages for frontend development
RUN npm install -g \
    npm@latest \
    yarn \
    pnpm \
    typescript \
    eslint \
    prettier

# Add games to PATH for fortune and cowsay
ENV PATH="$PATH:/usr/games"

# Install zsh and configure it
RUN apt-get update && apt-get install -y zsh && \
    sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.1.5/zsh-in-docker.sh)" && \
    rm -rf /var/lib/apt/lists/*

# Install Gradle 8.5
ENV GRADLE_VERSION=8.5
RUN wget -q https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip -P /tmp && \
    unzip -q /tmp/gradle-${GRADLE_VERSION}-bin.zip -d /opt && \
    ln -s /opt/gradle-${GRADLE_VERSION}/bin/gradle /usr/local/bin/gradle && \
    rm /tmp/gradle-${GRADLE_VERSION}-bin.zip

# Install Maven (as alternative build tool)
ENV MAVEN_VERSION=3.9.6
RUN wget -q https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz -P /tmp && \
    tar -xzf /tmp/apache-maven-${MAVEN_VERSION}-bin.tar.gz -C /opt && \
    ln -s /opt/apache-maven-${MAVEN_VERSION}/bin/mvn /usr/local/bin/mvn && \
    rm /tmp/apache-maven-${MAVEN_VERSION}-bin.tar.gz

# Set environment variables
ENV JAVA_HOME=/opt/java/openjdk
ENV GRADLE_HOME=/opt/gradle-${GRADLE_VERSION}
ENV MAVEN_HOME=/opt/apache-maven-${MAVEN_VERSION}
ENV PATH="${JAVA_HOME}/bin:${GRADLE_HOME}/bin:${MAVEN_HOME}/bin:${PATH}"

# Configure Gradle to use project cache directory
ENV GRADLE_USER_HOME=/workspace/.gradle

# Configure npm cache directory
ENV NPM_CONFIG_CACHE=/workspace/.npm

# Set welcome message
RUN printf 'echo ""\n' >> ~/.zshrc && \
    printf 'echo "🚀 JBoss EAP Kitchensink Full-Stack Development Environment"\n' >> ~/.zshrc && \
    printf 'echo ""\n' >> ~/.zshrc && \
    printf 'echo "Backend:  Java 21"\n' >> ~/.zshrc && \
    printf 'echo "          Gradle 8.5"\n' >> ~/.zshrc && \
    printf 'echo "          Maven 3.9.6"\n' >> ~/.zshrc && \
    printf 'echo "Frontend: Node.js $(node --version)"\n' >> ~/.zshrc && \
    printf 'echo "          npm $(npm --version)"\n' >> ~/.zshrc && \
    printf 'echo ""\n' >> ~/.zshrc && \
    printf 'echo "📦 Backend Commands:"\n' >> ~/.zshrc && \
    printf 'echo "  cd kitchensink && gradle build           - Build backend"\n' >> ~/.zshrc && \
    printf 'echo "  cd kitchensink && gradle test            - Run backend tests"\n' >> ~/.zshrc && \
    printf 'echo "  cd kitchensink && gradle bootRun         - Run Spring Boot app (port 8080)"\n' >> ~/.zshrc && \
    printf 'echo ""\n' >> ~/.zshrc && \
    printf 'echo "🎨 Frontend Commands:"\n' >> ~/.zshrc && \
    printf 'echo "  cd frontend && npm install               - Install dependencies"\n' >> ~/.zshrc && \
    printf 'echo "  cd frontend && npm run dev               - Run Next.js dev server (port 3000)"\n' >> ~/.zshrc && \
    printf 'echo "  cd frontend && npm run build             - Build production frontend"\n' >> ~/.zshrc && \
    printf 'echo "  cd frontend && npm run lint              - Lint frontend code"\n' >> ~/.zshrc && \
    printf 'echo ""\n' >> ~/.zshrc && \
    printf 'echo "🗄️  Database Commands:"\n' >> ~/.zshrc && \
    printf 'echo "  docker-compose up -d mysql               - Start MySQL database"\n' >> ~/.zshrc && \
    printf 'echo "  docker-compose up -d postgres            - Start PostgreSQL database"\n' >> ~/.zshrc && \
    printf 'echo "  docker-compose down                      - Stop all databases"\n' >> ~/.zshrc && \
    printf 'echo ""\n' >> ~/.zshrc && \
    printf 'fortune | cowsay | lolcat\n' >> ~/.zshrc && \
    printf 'echo ""\n' >> ~/.zshrc

# Set working directory
WORKDIR /workspace

# Default command
ENTRYPOINT ["/bin/zsh"]
