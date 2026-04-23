#!/bin/bash
set -e

echo "=========================================="
echo " Expo Dev Container - Setup "
echo "=========================================="

echo ""
echo "Running as user: $(whoami)"
echo "Workspace permissions: $(ls -ld /workspace 2>/dev/null || echo 'cannot access')"

echo ""
echo "Node version: $(node --version)"
echo "npm version: $(npm --version)"
echo "Bun version: $(bun --version)"

echo ""
echo "Checking for expo command..."
if command -v expo &> /dev/null; then
    echo "expo-cli version: $(expo --version)"
else
    echo "expo command not found. Installing expo-cli..."
    npm install -g expo-cli@6.3.12
    echo "expo-cli version: $(expo --version)"
fi

echo ""
echo "Setting up workspace permissions..."
if [ -w /workspace ]; then
    echo "Workspace is writable."
else
    echo "Warning: /workspace is not writable. Fixing permissions..."
    chmod -R u+w /workspace 2>/dev/null || chmod 777 /workspace 2>/dev/null || true
fi

echo ""
echo "Installing project dependencies..."
if [ -f "package.json" ]; then
    # Try bun install first, fall back to npm if it fails
    bun install || npm install
else
    echo "No package.json found. Skipping dependency install."
fi

echo ""
echo "Installing Expo dependencies..."
if [ -f "package.json" ]; then
    if grep -q "\"expo\"" package.json 2>/dev/null || grep -q '"expo"' package.json 2>/dev/null; then
        bun expo install || true
    fi
fi

echo ""
echo "Verifying Android SDK..."
if command -v adb &> /dev/null; then
    echo "ADB installed: $(adb version)"
else
    echo "Note: ADB not found in container. For Android development, use:"
    echo "  adb connect host.docker.internal:5555"
fi

echo ""
echo "=========================================="
echo " Dev container ready! "
echo "=========================================="
echo ""
echo "Available tools:"
echo "  node $(node --version)"
echo "  npm $(npm --version)"
echo "  bun $(bun --version)"
echo "  expo $(expo --version 2>/dev/null || echo 'not found')"
echo ""
echo "To run Expo app:"
echo "  bun expo start"
echo ""
echo "For development builds (dev client):"
echo "  bun expo run:android"
echo "  bun expo run:ios"
echo "=========================================="
