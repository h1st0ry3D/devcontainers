# Expo Dev Container (Bun + ARM64)

VS Code Dev Container for Expo (React Native) development optimized for **ARM64 Mac** (Apple Silicon) using **Bun** as the package manager.

## Features

- ⚡ **Bun** - Fast JavaScript runtime and package manager
- 🍎 **ARM64 optimized** - Native Apple Silicon support
- 📱 **iOS + Android** - Support for both platforms
- 🔧 **Pre-configured** - VS Code extensions and settings included

## Quick Start

1. Open the project in VS Code
2. `Cmd+Shift+P` → **"Dev Containers: Reopen in Container"**
3. Wait for container to build and start

## Running the App

```bash
# Start Metro bundler
bun expo start
```

### Android Emulator

1. Start **Android Studio** emulator on host
2. In container, connect to host emulator:

```bash
adb connect host.docker.internal:5555
bun expo start --android
```

### Android Device (Physical)

1. Enable USB debugging on device
2. Connect via USB
3. In container:

```bash
adb devices
bun expo start --android
```

### iOS Simulator (macOS Host)

Prerequisites:
- Xcode installed on macOS host
- iOS Simulator app running

1. Start iOS Simulator on your **macOS host**:
   ```bash
   # On macOS host
   xcrun simctl boot "iPhone 16 Pro"
   ```
2. In container terminal:

```bash
bun expo start --ios
```

Or press `i` when running `bun expo start` to launch in iOS Simulator.

> **Note:** On macOS, the container shares host filesystem, so Xcode tools are accessible through the mounted Docker socket.

## Package Manager: Bun

This devcontainer uses **Bun** instead of npm/yarn for faster installs and better performance.

### Common Commands

| npm command | Bun equivalent |
|-------------|----------------|
| `npm install` | `bun install` |
| `npm install <pkg>` | `bun add <pkg>` |
| `npm install -g <pkg>` | `bun install -g <pkg>` |
| `npx expo` | `bun expo` |
| `npm run <script>` | `bun run <script>` |

### Installing Packages

```bash
# Add a dependency
bun add react-native-reanimated

# Add a dev dependency
bun add -d @types/react

# Update dependencies
bun update

# Install with Expo
bun expo install expo-camera
```

## Platform Support

This single configuration works for both **Android** and **iOS** development:

| Platform | Requirements |
|----------|--------------|
| **Android** | Works on any host (Linux, macOS, Windows) |
| **iOS** | Requires macOS host with Xcode installed |

The container mounts the Docker socket for host communication.

## Environment Variables

`.devcontainer/.env`:
- `REACT_NATIVE_PACKAGER_HOSTNAME` - Metro bundler IP (auto-detected)

## Troubleshooting

### Bun not found

```bash
# Re-install Bun if needed
curl -fsSL https://bun.sh/install | bash
source ~/.bashrc
```

### Android

```bash
adb kill-server
adb start-server
adb connect host.docker.internal:5555
```

### iOS

```bash
# List available simulators
xcrun simctl list devices available

# Boot specific device
xcrun simctl boot <device-id>

# Then start Expo
bun expo start --ios
```

### Metro connection issues

```bash
REACT_NATIVE_PACKAGER_HOSTNAME=<host-ip> bun expo start
```

### Container won't start on ARM64

Ensure Docker Desktop is set to use Apple Silicon:
- **Docker Desktop** → **Settings** → **General** → **Use Virtualization framework** ✓
- **Docker Desktop** → **Settings** → **General** → **Use Rosetta for x86/amd64 emulation** (optional)

## Ports

| Port | Service |
|------|---------|
| 8081 | Metro Bundler |
| 19000 | Expo Dev Tools |
| 19001 | React Native Debugger |
| 19002 | Expo Dev Client |
| 19006 | Expo Web |

## VS Code Extensions

Pre-installed extensions:
- Biome
- Expo Tools

## Performance Tips

1. **Use Bun**: 3-5x faster than npm for package installation
2. **ARM64 images**: Native Apple Silicon performance (no Rosetta emulation)
3. **Watchman**: File watching optimized for container environments
4. **Volume mounts**: Code is mounted from host for instant sync

## References

- [Expo Documentation](https://docs.expo.dev/)
- [Bun Documentation](https://bun.sh/docs)
- [Dev Containers Specification](https://containers.dev/)
