# Dockerfile for JBoss EAP Kitchensink Spring Boot Development Environment

FROM eclipse-temurin:17-jdk-jammy

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
    fortune-mod \
    cowsay \
    lolcat \
    && rm -rf /var/lib/apt/lists/*

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

# Set welcome message
RUN printf 'echo ""\n' >> ~/.zshrc && \
    printf 'echo "🚀 JBoss EAP Kitchensink Spring Boot Development Environment"\n' >> ~/.zshrc && \
    printf 'echo ""\n' >> ~/.zshrc && \
    printf 'echo "Java:   $(java -version 2>&1 | head -n 1)"\n' >> ~/.zshrc && \
    printf 'echo "Gradle: $(gradle --version | grep "Gradle" | head -n 1)"\n' >> ~/.zshrc && \
    printf 'echo "Maven:  $(mvn --version | head -n 1)"\n' >> ~/.zshrc && \
    printf 'echo ""\n' >> ~/.zshrc && \
    printf 'echo "📦 Quick Commands:"\n' >> ~/.zshrc && \
    printf 'echo "  gradle build           - Build the application"\n' >> ~/.zshrc && \
    printf 'echo "  gradle test            - Run tests"\n' >> ~/.zshrc && \
    printf 'echo "  gradle bootRun         - Run the application"\n' >> ~/.zshrc && \
    printf 'echo "  docker-compose up -d   - Start MySQL database"\n' >> ~/.zshrc && \
    printf 'echo "  docker-compose down    - Stop MySQL database"\n' >> ~/.zshrc && \
    printf 'echo ""\n' >> ~/.zshrc && \
    printf 'fortune | cowsay | lolcat\n' >> ~/.zshrc && \
    printf 'echo ""\n' >> ~/.zshrc

# Set working directory
WORKDIR /workspace

# Default command
ENTRYPOINT ["/bin/zsh"]
