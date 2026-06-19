FROM mcr.microsoft.com/devcontainers/typescript-node:4.0.1-24-bookworm

# Install native dependencies for Expo + Android development.
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive && \
    apt-get install -y --no-install-recommends \
        watchman \
        libasound2 \
        libatk-bridge2.0-0 \
        libatspi2.0-0 \
        libgbm1 \
        libgtk-3-0 \
        libnss3 \
        libxkbcommon0 \
        curl unzip git ca-certificates && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Android's Linux SDK build tools, CMake, and NDK packages ship x86_64 host binaries.
# On arm64 devcontainers, provide the x86_64 loader/runtime so binfmt/qemu can run them.
RUN set -eux; \
    if [ "$(dpkg --print-architecture)" = "arm64" ]; then \
        dpkg --add-architecture amd64; \
        apt-get update; \
        export DEBIAN_FRONTEND=noninteractive; \
        apt-get install -y --no-install-recommends \
            qemu-user-static \
            libc6:amd64 \
            libstdc++6:amd64 \
            zlib1g:amd64; \
        apt-get clean; \
        rm -rf /var/lib/apt/lists/*; \
    fi

# Set up environment
ENV PATH="/usr/local/bin:${PATH}" \
    REACT_NATIVE_DEBUGGER_DISABLED=true \
    NODE_OPTIONS=--max-old-space-size=4096

WORKDIR /workspace

# The base image grants the `node` user passwordless sudo. This container runs
# non-root (`remoteUser: node`) and does not need sudo, so remove the NOPASSWD
# entry to prevent any process in the container from escalating to root.
RUN rm -f /etc/sudoers.d/node

# Pre-create the node-owned home directories that get volume-mounted in
# devcontainer.json, so the mounts land on dirs owned by uid 1000 (node) and
# the non-root user can write to them without a permission-fixup script.
RUN mkdir -p /home/node/.local/share/mise /home/node/.cache/mise \
    /home/node/.local/state/mise /home/node/.android \
    && chown -R node:node /home/node

# Verify the base image tooling. Project runtimes are installed after create via mise.
RUN node --version && npm --version
