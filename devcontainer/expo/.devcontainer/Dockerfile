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
    # X11 and GTK libraries for React Native DevTools
    libatk-bridge2.0-0 \
    libgtk-3-0 \
    libxss1 \
    libnss3 \
    libgconf-2-4 \
    libgbm1 \
    libasound2 \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Install Node.js 22.x (LTS) - auto-detects architecture
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm@11.1.0

# Install Bun 1.2.4
ENV BUN_VERSION=1.2.4
RUN curl -fsSL https://bun.sh/install | bash -s bun-v${BUN_VERSION} \
    && mv ~/.bun/bin/bun /usr/local/bin/bun \
    && ln -s /usr/local/bin/bun /usr/local/bin/bunx

# Install expo-cli 6.3.12
ENV EXPO_CLI_VERSION=6.3.12
RUN bun install -g expo-cli@${EXPO_CLI_VERSION}

# Set up Android SDK environment
ENV ANDROID_HOME=/usr/lib/android-sdk
ENV PATH="${PATH}:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/cmdline-tools/latest/bin"

# Create workspace directory
WORKDIR /workspace

# Set Bun as default package manager
ENV BUN_INSTALL=/usr/local

# Disable React Native DevTools auto-launch (optional - container doesn't have GUI)
ENV REACT_NATIVE_DEBUGGER_DISABLED=true

# Verify installations
RUN echo "Node version: $(node --version)" \
    && echo "npm version: $(npm --version)" \
    && echo "Bun version: $(bun --version)" \
    && echo "expo-cli version: $(expo --version)"
