FROM mcr.microsoft.com/devcontainers/typescript-node:4.0.1-20-bookworm

ARG ANDROID_CMDLINE_TOOLS_VERSION=14742923

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

# Install native dependencies for Expo + Android development.
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive && \
    apt-get install -y --no-install-recommends \
        openjdk-17-jdk \
        android-tools-adb \
        android-tools-fastboot \
        watchman \
        curl unzip git sudo ca-certificates && \
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

# Install Android SDK command-line tools and the packages required by Expo Android builds.
RUN set -eux; \
    mkdir -p /usr/lib/android-sdk/cmdline-tools /usr/lib/android-sdk/licenses /root/.android; \
    touch /root/.android/repositories.cfg; \
    curl -fsSL "https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_CMDLINE_TOOLS_VERSION}_latest.zip" -o /tmp/android-cmdline-tools.zip; \
    unzip -q /tmp/android-cmdline-tools.zip -d /tmp/android-cmdline-tools; \
    mv /tmp/android-cmdline-tools/cmdline-tools /usr/lib/android-sdk/cmdline-tools/latest; \
    { \
        echo "8933bad161af4178b1185d1a37fbf41ea5269c55"; \
        echo "d56f5187479451eabf01fb78af6dfcb131a6481e"; \
        echo "24333f8a63b6825ea9c5514f83c2829b004d1fee"; \
    } > /usr/lib/android-sdk/licenses/android-sdk-license; \
    echo "84831b9409646a918e30573bab4c9c91346d8abd" > /usr/lib/android-sdk/licenses/android-sdk-preview-license; \
    yes | /usr/lib/android-sdk/cmdline-tools/latest/bin/sdkmanager --sdk_root=/usr/lib/android-sdk --licenses > /tmp/android-sdk-licenses.log || true; \
    /usr/lib/android-sdk/cmdline-tools/latest/bin/sdkmanager --sdk_root=/usr/lib/android-sdk \
        "platforms;android-36" \
        "build-tools;35.0.0" \
        "build-tools;36.0.0" \
        "ndk;27.1.12297006"; \
    yes | /usr/lib/android-sdk/cmdline-tools/latest/bin/sdkmanager --sdk_root=/usr/lib/android-sdk --licenses >> /tmp/android-sdk-licenses.log || true; \
    rm -rf /tmp/android-cmdline-tools /tmp/android-cmdline-tools.zip /tmp/android-sdk-licenses.log; \
    chown -R node:node /usr/lib/android-sdk

# Set up environment
ENV PATH="/usr/local/bin:${PATH}" \
    ANDROID_HOME=/usr/lib/android-sdk \
    ANDROID_SDK_ROOT=/usr/lib/android-sdk \
    REACT_NATIVE_DEBUGGER_DISABLED=true \
    NODE_OPTIONS=--max-old-space-size=4096

ENV PATH="${PATH}:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/cmdline-tools/latest/bin"

WORKDIR /workspace

# Allow node user to use sudo without password (for rootless Podman permission fixes)
RUN echo "node ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/node-nopasswd && \
    chmod 440 /etc/sudoers.d/node-nopasswd

# Verify build-time toolchain. Bun is installed later via a devcontainer Feature.
RUN node --version && npm --version && java -version && sdkmanager --version && adb version
