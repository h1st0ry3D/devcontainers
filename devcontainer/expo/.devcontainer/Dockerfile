FROM mcr.microsoft.com/devcontainers/base:bookworm

# Trust custom/corporate CAs (e.g., Zscaler) before external HTTPS downloads.
# The build context is the repository root, so certs are copied from .devcontainer/certs.
COPY .devcontainer/certs /tmp/devcontainer-certs
RUN set -eux; \
    if [ -d /tmp/devcontainer-certs ]; then \
        mkdir -p /usr/local/share/ca-certificates/devcontainer-custom; \
        find /tmp/devcontainer-certs -type f \( -name '*.crt' -o -name '*.pem' \) \
            -exec sh -c 'cp "$1" "/usr/local/share/ca-certificates/devcontainer-custom/$(basename "$1" | sed "s/.pem$/.crt/")"' _ {} \;; \
        update-ca-certificates; \
    fi

# Install core dependencies for Expo + Android development.
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive && \
    apt-get install -y --no-install-recommends \
        openjdk-17-jdk \
        android-tools-adb \
        android-tools-fastboot \
        watchman \
        curl unzip git sudo ca-certificates && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Node.js from NodeSource or Debian fallback (for corporate proxy compatibility)
RUN set -eux; \
    if curl -fsSL https://deb.nodesource.com/setup_22.x -o /tmp/ns_setup.sh; then \
        bash /tmp/ns_setup.sh && apt-get install -y --no-install-recommends nodejs && npm install -g npm@11.1.0; \
    else \
        apt-get update && apt-get install -y --no-install-recommends nodejs npm; \
    fi; \
    rm -f /tmp/ns_setup.sh && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Bun 1.2.4
ENV BUN_VERSION=1.2.4
RUN ARCH="$(dpkg --print-architecture)" && \
    case "$ARCH" in \
        amd64) BUN_ARCH="x64" ;; \
        arm64) BUN_ARCH="aarch64" ;; \
        *) echo "Unsupported architecture: $ARCH" >&2; exit 1 ;; \
    esac && \
    curl -fsSL "https://github.com/oven-sh/bun/releases/download/bun-v${BUN_VERSION}/bun-linux-${BUN_ARCH}.zip" -o /tmp/bun.zip && \
    unzip -q /tmp/bun.zip -d /tmp/bun-extract && \
    mv /tmp/bun-extract/bun-linux-${BUN_ARCH}/bun /usr/local/bin/ && \
    chmod +x /usr/local/bin/bun && ln -sf bun /usr/local/bin/bunx && \
    rm -rf /tmp/bun.zip /tmp/bun-extract

# Set up environment
ENV PATH="/usr/local/bin:${PATH}" \
    ANDROID_HOME=/usr/lib/android-sdk \
    REACT_NATIVE_DEBUGGER_DISABLED=true \
    NODE_OPTIONS=--max-old-space-size=4096

ENV PATH="${PATH}:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/cmdline-tools/latest/bin"

WORKDIR /workspace

# Allow vscode user to use sudo without password (for rootless Podman permission fixes)
RUN echo "vscode ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/vscode-nopasswd && \
    chmod 440 /etc/sudoers.d/vscode-nopasswd

# Verify base toolchain
RUN node --version && npm --version && bun --version
