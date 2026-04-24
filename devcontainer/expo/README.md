# Expo Dev Container (React Native)

> 📱 Complete development environment for Expo/React Native with isolated dependencies

## 🚀 Quick Start

1. Open in VS Code
2. Press `Cmd+Shift+P` → **"Dev Containers: Reopen in Container"**
3. Wait for build (first time ~2-3 minutes)
4. Dependencies auto-install in isolated Docker volume

## 📁 Project Structure

```
.
├── .devcontainer/     # Container configuration
├── app/               # Your Expo/React Native app
│   ├── package.json
│   ├── src/
│   └── node_modules/  # 🐳 Docker volume (isolated from host)
├── .vscode/           # VS Code settings
└── README.md          # 📖 Full documentation in app/README.md
```

## 📖 Full Documentation

See **[app/README.md](app/README.md)** for complete documentation including:

- 🏗️ Project setup and structure
- 📱 iOS Simulator setup (macOS host)
- 🤖 Android Emulator connection
- 🔒 Isolated `node_modules` explanation
- 🐛 Debugging guide
- 🔧 Troubleshooting

## 🔒 Security: Isolated Dependencies

This devcontainer stores `node_modules` in a **Docker volume** - not on your host filesystem:

| Location | `node_modules` Status |
|----------|---------------------|
| **Host (your Mac)** | ❌ Empty directory (mount point only) |
| **Container** | ✅ 391+ packages (actual dependencies) |

**Never run `bun install` on your host** - use the container terminal instead!

## 🌐 Port Forwarding

The container forwards these ports for simulator/emulator communication:

| Port | Service |
|------|---------|
| 8081 | Metro Bundler |
| 19000 | Expo Dev Tools |
| 19001 | React Native Debugger |
| 19002 | Expo Dev Client |
| 19006 | Expo Web |

## 🛠️ Tech Stack

- ⚡ Bun (JavaScript runtime & package manager)
- 📱 Expo SDK 55
- ⚛️ React Native 0.83
- 🐳 Dev Container (Debian Bookworm)
- ☕ Java 17 (for Android builds)

---

**Detailed guide:** [app/README.md](app/README.md)
