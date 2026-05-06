# Android Emulator Integration Guide

This guide explains how to run your Android emulator on the host machine while the Expo dev server runs inside the dev container (via Podman).

## Architecture Overview

```
┌─────────────────────────────────────┐
│        Host Machine (macOS)         │
├─────────────────────────────────────┤
│ - Android Emulator (AVD)            │
│ - adb server                        │
│ - Forwarded Metro port              │
└────────────────┬────────────────────┘
                 │ adb connect / TCP 5555
                 │ Emulator reaches Metro via forwarded port 8081
┌────────────────▼────────────────────┐
│   Podman Container (rootless)       │
├─────────────────────────────────────┤
│ - Expo CLI & Metro (port 8081)      │
│ - Build tools (JDK, gradle, etc.)   │
│ - adb client (connects to host)     │
└─────────────────────────────────────┘
```

## Prerequisites

- **Host**: Android Studio with Emulator or standalone Android Emulator installed
- **Container**: Already set up with Expo CLI via `bun expo`, `adb`, and Android build tools
- **Network**: Container must reach host via `host.docker.internal` (configured in devcontainer.json)

## Step-by-Step Setup

### 1. Start the Expo Dev Server in Container

Run the default Metro task in VS Code:

```bash
# Terminal → Run Task → "Start Metro (Expo)"
# Or run manually in devcontainer:
bun expo start
```

The server will start on port 8081 (forwarded to host).

### 2. Launch Android Emulator on Host

On your macOS host:

```bash
# List available AVDs
emulator -list-avds

# Start your desired emulator
emulator -avd <your_avd_name> &
```

Or open Android Studio → Virtual Device Manager → Play on your emulator.

### 3. Connect Emulator to Container via adb

From the devcontainer terminal, connect to the emulator running on the host:

```bash
# Via the "Connect Android Emulator" VS Code task:
# Terminal → Run Task → "Connect Android Emulator"

# Or manually:
adb connect host.docker.internal:5555
```

Verify connection:

```bash
adb devices

# Expected output:
# List of attached devices
# host.docker.internal:5555    device
```

If connection fails:
- Ensure emulator is running on the host
- Try restarting adb server: `adb kill-server && adb devices`
- Check if Android Emulator's adb server is accessible: `lsof -i :5555` (on host)

### 4. Install and Run Your App

Once connected, build and run your app on the emulator:

```bash
# Option A: Use Expo CLI (automatically deploys to connected device)
bun expo start --android

# Option B: Use Gradle directly (for dev client builds)
cd /workspace/app/android
./gradlew installDebug
```

The Metro bundler will connect to your emulator automatically.

### 5. View Logs

Monitor device logs from the container:

```bash
adb logcat

# Filter by your app's tag
adb logcat | grep "ReactNativeJS"
```

## Troubleshooting

### "adb: no devices/emulators found"

**Problem**: Emulator is running on host but adb can't connect.

**Solutions**:
1. Verify emulator is actually running:
   ```bash
   # On macOS host
   lsof -i :5555
   ```

2. Try direct connection instead of hostname:
   ```bash
   # Get host IP from container perspective
   ping -c 1 host.docker.internal
   
   # Connect to that IP:5555
   adb connect <IP>:5555
   ```

3. Restart adb server:
   ```bash
   adb kill-server
   adb start-server
   adb connect host.docker.internal:5555
   ```

### Metro bundler can't connect to emulator

**Problem**: Build succeeds but app shows "Connection refused".

**Solution**: Ensure Metro knows the correct host IP:
```bash
# In container, set explicit packager hostname
REACT_NATIVE_PACKAGER_HOSTNAME=host.docker.internal bun expo start
```

Or update `.env`:
```bash
echo "REACT_NATIVE_PACKAGER_HOSTNAME=$(ipconfig getifaddr en0)" > .devcontainer/.env
```

### Emulator crashes or adb disconnects frequently

**Problem**: Connection is unstable.

**Solutions**:
1. Increase adb timeout:
   ```bash
   adb connect host.docker.internal:5555
   ```

2. Restart both adb and emulator:
   ```bash
   # On host
   adb kill-server
   pkill -9 emulator
   # Then restart emulator and reconnect
   ```

3. Check Podman network isolation:
   ```bash
   # Verify host-gateway is reachable
   podman run -it --add-host=host.docker.internal:host-gateway \
          mcr.microsoft.com/devcontainers/typescript-node:4.0.1-20-bookworm \
     ping -c 1 host.docker.internal
   ```

### "Permission denied" errors during install

**Problem**: App installation fails with permission errors.

**Solution**:
```bash
# Clear app data and cache
adb shell pm clear com.yourapp.package

# Or uninstall and reinstall
adb uninstall com.yourapp.package
```

## Performance Tips

1. **Use Hermes engine** in your `app.json`:
   ```json
   {
     "plugins": [
       ["expo-build-properties", {
         "android": {
           "enableHermes": true
         }
       }]
     ]
   }
   ```

2. **Increase container memory limit** for faster builds:
   ```json
   // devcontainer.json
   "runArgs": ["--memory=8g", ...]
   ```

3. **Use `--clear` sparingly** (clears module cache):
   ```bash
   bun expo start --clear  # Only when necessary
   ```

4. **Enable fast refresh** to speed up development:
   - Enabled by default in Expo projects
   - Changes appear instantly without rebuild

## Switching Between Android and Web

```bash
# Android (via emulator/device)
bun expo start --android

# Web (browser on host)
bun expo start --web

# Dev Client (custom dev build)
bun expo start --dev-client
```

When switching, press `w` (web), `i` (iOS), or `a` (Android) in the Metro prompt.

## Advanced: Building Dev Client APK

For native module changes, prebuild and install a dev client:

```bash
# Generate native code
bun run prebuild:android

# Build dev client APK
cd /workspace/app/android
./gradlew assembleDebug

# Install on connected device/emulator
adb install app/build/outputs/apk/debug/app-debug.apk
```

## References

- [Expo CLI Docs - Android Emulator](https://docs.expo.dev/build-reference/android/)
- [adb Documentation](https://developer.android.com/tools/adb)
- [Android Emulator Networking](https://developer.android.com/studio/run/emulator-networking)
- [Podman Host Gateway](https://docs.podman.io/en/latest/markdown/podman-run.1.html#add-host-host-gateway)
