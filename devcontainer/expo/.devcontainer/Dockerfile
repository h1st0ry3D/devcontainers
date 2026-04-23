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
    libatk-bridge2.0-0 \
    libgtk-3-0 \
    libxss1 \
    libnss3 \
    libgconf-2-4 \
    libgbm1 \
    libasound2 \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Install Node.js 22.x (LTS)
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm@11.1.0

# Install Bun 1.2.4
ENV BUN_VERSION=1.2.4
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then ARCH="x64"; fi && \
    if [ "$ARCH" = "aarch64" ]; then ARCH="aarch64"; fi && \
    curl -fsSL "https://github.com/oven-sh/bun/releases/download/bun-v${BUN_VERSION}/bun-linux-${ARCH}.zip" -o /tmp/bun.zip && \
    unzip -q /tmp/bun.zip -d /tmp/bun-extract && \
    mkdir -p /usr/local/bin && \
    mv /tmp/bun-extract/bun-linux-${ARCH}/bun /usr/local/bin/bun && \
    chmod +x /usr/local/bin/bun && \
    rm -rf /tmp/bun.zip /tmp/bun-extract && \
    ln -sf /usr/local/bin/bun /usr/local/bin/bunx

# Install expo-cli globally with npm (predictable location)
ENV EXPO_CLI_VERSION=6.3.12
RUN npm install -g expo-cli@${EXPO_CLI_VERSION}

# Ensure expo is in PATH (npm global bin)
ENV PATH="/usr/local/bin:/usr/bin:${PATH}"

# Set up Android SDK environment
ENV ANDROID_HOME=/usr/lib/android-sdk
ENV PATH="${PATH}:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/cmdline-tools/latest/bin"

# Create workspace directory
WORKDIR /workspace

# Disable React Native DevTools auto-launch
ENV REACT_NATIVE_DEBUGGER_DISABLED=true

# Increase Node memory limit for large builds
ENV NODE_OPTIONS=--max-old-space-size=4096

# Verify installations
RUN echo "Node version: $(node --version)" && \
    echo "npm version: $(npm --version)" && \
    echo "Bun version: $(bun --version)" && \
    echo "expo-cli version: $(expo --version)" && \
    echo "expo location: $(which expo)"
