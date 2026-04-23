# Expo Dev Container (React Native)

A complete development environment for Expo/React Native with Bun, optimized for ARM64 Mac (Apple Silicon) with support for Android and iOS development.

## Features

- ⚡ **Bun** - Fast JavaScript runtime and package manager
- 📱 **iOS + Android** - Support for both platforms
- 🐳 **Dev Container** - Consistent, isolated environment
- 🍎 **ARM64 Optimized** - Native Apple Silicon support
- 🔧 **Pre-configured** - VS Code tasks and debug configs included

## Quick Start

### 1. Open in Dev Container

1. Open the project in VS Code
2. Press `Cmd+Shift+P` (macOS) or `Ctrl+Shift+P` (Linux/Windows)
3. Select **"Dev Containers: Reopen in Container"**
4. Wait for the container to build (first time may take 2-3 minutes)

### 2. Install Dependencies

The container automatically installs dependencies on first launch. If needed, run manually:

```bash
bun install
```

## Running the App

### Option 1: VS Code Tasks (Recommended)

Press `Cmd+Shift+P` → **"Tasks: Run Task"** and select:

| Task | Description |
|------|-------------|
| **Start Metro (Expo)** | Start the Metro bundler |
| **Start Android** | Start Android development build |
| **Start iOS** | Start iOS development build (macOS host only) |
| **Connect Android Emulator** | Connect to host Android emulator |

Or use the keyboard shortcut: `Cmd+Shift+B` (runs default task - Start Metro)

### Option 2: Terminal Commands

```bash
# Start Metro bundler
bun expo start

# Start with Android
bun expo start --android

# Start with iOS (macOS only)
bun expo start --ios

# Start with Web
bun expo start --web
```

## Android Development

### Prerequisites

- Android Studio installed on your **host** machine
- Android emulator created in Android Studio

### Steps

1. **Start Android Emulator on Host**
   - Open Android Studio
   - Open Device Manager
   - Start your emulator (e.g., "Pixel 7 API 34")

2. **Connect Container to Emulator**
   
   In the devcontainer terminal:
   ```bash
   adb connect host.docker.internal:5555
   ```
   
   Or use VS Code task: `Cmd+Shift+P` → **"Tasks: Run Task"** → **"Connect Android Emulator"**

3. **Start Expo**
   ```bash
   bun expo start --android
   ```
   
   Or press `a` in the Metro terminal

### Troubleshooting Android

```bash
# Check connected devices
adb devices

# Restart ADB server
adb kill-server
adb start-server

# Reconnect
adb connect host.docker.internal:5555
```

## iOS Development

### Prerequisites

- macOS host with Xcode installed
- iOS Simulator available

### Steps

1. **Start iOS Simulator**
   
   On your **macOS host** (not in container):
   ```bash
   # List available simulators
   xcrun simctl list devices available
   
   # Start specific simulator
   xcrun simctl boot "iPhone 15 Pro"
   ```

2. **Start Expo**
   
   In the devcontainer:
   ```bash
   bun expo start --ios
   ```
   
   Or press `i` in the Metro terminal

### Troubleshooting iOS

```bash
# Boot simulator from command line
xcrun simctl boot <device-id>

# Open Simulator app
open -a Simulator

# If Metro can't connect, check the .env file:
cat .devcontainer/.env
# Should show: REACT_NATIVE_PACKAGER_HOSTNAME=<your-host-ip>
```

## Debugging

### VS Code Debugger

Press `F5` or go to **Run and Debug** panel:

- **Debug Android (Expo)** - Launch with debugger attached
- **Debug iOS (Expo)** - Launch with debugger attached
- **Debug Web (Expo)** - Launch web with debugger
- **Attach to Metro** - Attach to already running Metro

### React Native Debugger

The container forwards the React Native debugger port (19001). You can connect from your host using React Native Debugger app or Chrome DevTools.

## Development Builds (Native Code)

For development client builds (when you need native modules):

```bash
# Generate native code
bun expo prebuild

# Build Android
bun expo run:android

# Build iOS (macOS only)
bun expo run:ios
```

Or use VS Code tasks:
- **"Prebuild (Generate Native Code)"**
- **"Build Android (Dev Client)"**
- **"Build iOS (Dev Client)"**

## Package Management with Bun

This devcontainer uses Bun instead of npm/yarn:

```bash
# Install dependencies
bun install

# Add a package
bun add <package-name>

# Add dev dependency
bun add -d <package-name>

# Expo install (installs compatible versions)
bun expo install <package-name>

# Run scripts
bun run <script-name>
```

## Project Structure

```
.
├── .devcontainer/          # Dev container configuration
│   ├── devcontainer.json   # Container settings
│   ├── Dockerfile          # Container image definition
│   ├── postCreateCommand.sh # Post-create setup
│   └── .env               # Auto-generated host IP
├── .vscode/               # VS Code settings
│   ├── tasks.json         # Task definitions
│   ├── launch.json        # Debug configurations
│   └── settings.json      # Editor settings
├── src/                   # Source code
│   └── app/              # Expo Router app directory
├── package.json          # Dependencies and scripts
└── README.md             # This file
```

## Environment Variables

The container automatically sets these:

| Variable | Description |
|----------|-------------|
| `REACT_NATIVE_PACKAGER_HOSTNAME` | Host IP for Metro bundler (auto-detected) |
| `ANDROID_HOME` | Android SDK location |
| `BUN_INSTALL` | Bun installation directory |
| `CHOKIDAR_USEPOLLING` | File watching mode for containers |

## Ports

The container forwards these ports:

| Port | Service |
|------|---------|
| 8081 | Metro Bundler |
| 19000 | Expo Dev Tools |
| 19001 | React Native Debugger |
| 19002 | Expo Dev Client |
| 19006 | Expo Web |

## Troubleshooting

### "Metro bundler not connecting"

1. Check the host IP was detected:
   ```bash
   cat .devcontainer/.env
   ```

2. If needed, manually set it:
   ```bash
   export REACT_NATIVE_PACKAGER_HOSTNAME=$(ipconfig getifaddr en0)
   bun expo start
   ```

### "adb: command not found"

ADB is installed in the container. Make sure you're inside the container terminal (not your host).

### "iOS simulator not found"

iOS simulator must be started from **macOS host**, not from within the container. The container runs Linux and cannot run iOS Simulator directly.

### "Bun not found"

If Bun is not in your PATH:
```bash
export PATH="/usr/local/bin:$PATH"
```

Or reload the window: `Cmd+Shift+P` → **"Developer: Reload Window"**

### Rebuild Container

If you encounter persistent issues:

```bash
# In VS Code
cmd+shift+p → "Dev Containers: Rebuild and Reopen in Container"

# Or from terminal
docker buildx prune -f
```

## Tips & Best Practices

1. **Use VS Code Tasks**: Instead of typing commands, use `Cmd+Shift+P` → "Tasks: Run Task"

2. **Android First**: Always start the Android emulator on host before starting Expo

3. **Connect ADB**: Run `adb connect host.docker.internal:5555` before starting Android builds

4. **Hot Reload**: Changes are automatically reflected in the running app

5. **Debugging**: Use `F5` to start debugging - breakpoints work in both JS and native code

6. **Package Scripts**: Add frequently used commands to `package.json` scripts section

## Useful Commands

```bash
# Check versions
node --version    # Node.js version
npm --version     # npm version
bun --version     # Bun version
expo --version    # Expo CLI version
adb version       # ADB version
java -version     # Java version

# List Android devices
adb devices

# List iOS simulators (from macOS host)
xcrun simctl list devices

# Expo diagnostics
bun expo doctor

# Clear caches
bun expo start --clear
```

## References

- [Expo Documentation](https://docs.expo.dev/)
- [Bun Documentation](https://bun.sh/docs)
- [Dev Containers](https://containers.dev/)
- [React Native Debugging](https://reactnative.dev/docs/debugging)

---

**Note**: This devcontainer is optimized for ARM64 (Apple Silicon) Macs but works on Intel Macs and Linux too. iOS development requires a macOS host.
