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
        watchman \
        libatk-bridge2.0-0 \
        libatspi2.0-0 \
        libgbm1 \
        libgtk-3-0 \
        libxkbcommon0 \
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
    mkdir -p /usr/lib/android-sdk/cmdline-tools /root/.android /home/node/.android; \
    touch /root/.android/repositories.cfg; \
    touch /home/node/.android/repositories.cfg; \
    curl --fail --show-error --silent --location --proto '=https' --tlsv1.2 \
        "https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_CMDLINE_TOOLS_VERSION}_latest.zip" \
        -o /tmp/android-cmdline-tools.zip; \
    unzip -q /tmp/android-cmdline-tools.zip -d /tmp/android-cmdline-tools; \
    mv /tmp/android-cmdline-tools/cmdline-tools /usr/lib/android-sdk/cmdline-tools/latest; \
    yes | /usr/lib/android-sdk/cmdline-tools/latest/bin/sdkmanager --sdk_root=/usr/lib/android-sdk --licenses > /tmp/android-sdk-licenses.log || true; \
    yes | /usr/lib/android-sdk/cmdline-tools/latest/bin/sdkmanager --sdk_root=/usr/lib/android-sdk \
        "platform-tools" \
        "platforms;android-36" \
        "build-tools;35.0.0" \
        "build-tools;36.0.0" \
        "cmake;3.22.1" \
        "ndk;27.1.12297006"; \
    yes | /usr/lib/android-sdk/cmdline-tools/latest/bin/sdkmanager --sdk_root=/usr/lib/android-sdk --licenses >> /tmp/android-sdk-licenses.log || true; \
    rm -rf /tmp/android-cmdline-tools /tmp/android-cmdline-tools.zip /tmp/android-sdk-licenses.log; \
    chown -R node:node /usr/lib/android-sdk /home/node/.android

# Set up environment
ENV PATH="/usr/local/bin:${PATH}" \
    ANDROID_HOME=/usr/lib/android-sdk \
    ANDROID_SDK_ROOT=/usr/lib/android-sdk \
    ANDROID_USER_HOME=/home/node/.android \
    REACT_NATIVE_DEBUGGER_DISABLED=true \
    NODE_OPTIONS=--max-old-space-size=4096

ENV PATH="${PATH}:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/cmdline-tools/latest/bin"

WORKDIR /workspace

# Allow node user to run only the hardened Podman permission repair helper.
COPY .devcontainer/expo-devcontainer-root-helper.sh /usr/local/bin/expo-devcontainer-root-helper
RUN chmod 755 /usr/local/bin/expo-devcontainer-root-helper && \
    printf 'node ALL=(root) NOPASSWD: /usr/local/bin/expo-devcontainer-root-helper *\n' > /etc/sudoers.d/node-expo-devcontainer && \
    chmod 440 /etc/sudoers.d/node-expo-devcontainer

# Verify build-time toolchain. Bun is installed later via a devcontainer Feature.
RUN node --version && npm --version && java -version && sdkmanager --version && adb version
