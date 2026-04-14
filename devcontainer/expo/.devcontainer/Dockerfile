FROM mcr.microsoft.com/devcontainers/base:bookworm

# Install dependencies for Android development
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install -y --no-install-recommends \
    openjdk-17-jdk \
    android-tools-adb \
    android-tools-fastboot \
    watchman \
    curl \ 
    unzip \
    git \
    ca-certificates \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Install Bun
RUN curl -fsSL https://bun.sh/install | bash \
    && mv ~/.bun/bin/bun /usr/local/bin/bun \
    && ln -s /usr/local/bin/bun /usr/local/bin/bunx

# Install global packages using Bun
RUN bun install -g expo-cli

# Set up Android SDK environment
ENV ANDROID_HOME=/usr/lib/android-sdk
ENV PATH="${PATH}:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/cmdline-tools/latest/bin"

# Create workspace directory
WORKDIR /workspace

# Set Bun as default package manager
ENV BUN_INSTALL=/usr/local
