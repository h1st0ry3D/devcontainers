FROM mcr.microsoft.com/devcontainers/base:bookworm

# Optional: trust custom/corporate CAs placed in .devcontainer/certs
# (e.g. ZscalerRootCA.pem). These files are copied from build context.
COPY certs /tmp/devcontainer-certs

# Register custom CA certs before any external HTTPS downloads.
RUN set -eux; \
    if [ -d /tmp/devcontainer-certs ]; then \
        mkdir -p /usr/local/share/ca-certificates/devcontainer-custom; \
        find /tmp/devcontainer-certs -type f \( -name '*.crt' -o -name '*.pem' \) | while read -r cert; do \
            cert_name="$(basename "$cert")"; \
            cp "$cert" "/usr/local/share/ca-certificates/devcontainer-custom/${cert_name%.*}.crt"; \
        done; \
        if [ "$(find /usr/local/share/ca-certificates/devcontainer-custom -type f | wc -l)" -gt 0 ]; then \
            update-ca-certificates; \
        fi; \
    fi

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
    sudo \
    libatk-bridge2.0-0 \
    libgtk-3-0 \
    libxss1 \
    libnss3 \
    libgconf-2-4 \
    libgbm1 \
    libasound2 \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Install Node.js
# Prefer NodeSource 22.x, but fall back to Debian packages when HTTPS interception
# (e.g. corporate proxy) prevents validating NodeSource certificates.
RUN set -eux; \
    if curl -fsSL https://deb.nodesource.com/setup_22.x -o /tmp/nodesource_setup.sh; then \
        bash /tmp/nodesource_setup.sh; \
        apt-get install -y --no-install-recommends nodejs; \
        npm install -g npm@11.1.0; \
    else \
        echo "Warning: NodeSource setup failed, falling back to Debian nodejs/npm packages"; \
        apt-get update; \
        apt-get install -y --no-install-recommends nodejs npm; \
    fi; \
    rm -f /tmp/nodesource_setup.sh; \
    apt-get clean -y && rm -rf /var/lib/apt/lists/*

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

# Fix for React Native DevTools sandbox issue in containers
# Create scripts to fix chrome-sandbox permissions dynamically
RUN mkdir -p /usr/local/share/devcontainer-fixes && \
    printf '%s\n' '#!/bin/bash' \
    '# Fix chrome-sandbox permissions for React Native DevTools' \
    'find /home /tmp -name "chrome-sandbox" -type f 2>/dev/null | while read -r sandbox; do' \
    '    if [ -f "$sandbox" ]; then' \
    '        sudo chown root:root "$sandbox" 2>/dev/null || true' \
    '        sudo chmod 4755 "$sandbox" 2>/dev/null || true' \
    '    fi' \
    'done' > /usr/local/share/devcontainer-fixes/fix-chrome-sandbox.sh && \
    chmod +x /usr/local/share/devcontainer-fixes/fix-chrome-sandbox.sh

# Add sudoers rule for vscode to run chrome-sandbox fix without password
RUN echo "vscode ALL=(ALL) NOPASSWD: /usr/local/share/devcontainer-fixes/fix-chrome-sandbox.sh" > /etc/sudoers.d/vscode-chrome-sandbox && \
    chmod 440 /etc/sudoers.d/vscode-chrome-sandbox

# Install inotify-tools for watching file creation
RUN apt-get update && apt-get install -y inotify-tools && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Create background watcher script for chrome-sandbox files
RUN printf '%s\n' '#!/bin/bash' \
    '# Watch for chrome-sandbox creation and fix permissions immediately' \
    'mkdir -p /tmp/dotslash-1000 /home/vscode/.cache/dotslash' \
    'inotifywait -m -r -e create /tmp/dotslash-1000 /home/vscode/.cache/dotslash --format "%w%f" 2>/dev/null | while read -r file; do' \
    '    if [[ "$file" == *"chrome-sandbox" ]]; then' \
    '        sleep 0.5' \
    '        sudo chown root:root "$file" 2>/dev/null || true' \
    '        sudo chmod 4755 "$file" 2>/dev/null || true' \
    '    fi' \
    'done' > /usr/local/share/devcontainer-fixes/watch-chrome-sandbox.sh && \
    chmod +x /usr/local/share/devcontainer-fixes/watch-chrome-sandbox.sh

# Add chrome-sandbox fix to bashrc so it runs for every new shell
RUN echo 'if [ -f /usr/local/share/devcontainer-fixes/fix-chrome-sandbox.sh ]; then /usr/local/share/devcontainer-fixes/fix-chrome-sandbox.sh >/dev/null 2>&1; fi' >> /etc/bash.bashrc

# Verify installations
RUN echo "Node version: $(node --version)" && \
    echo "npm version: $(npm --version)" && \
    echo "Bun version: $(bun --version)" && \
    echo "expo-cli version: $(expo --version)" && \
    echo "expo location: $(which expo)"
