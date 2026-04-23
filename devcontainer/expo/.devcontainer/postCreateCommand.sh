#!/bin/bash
set -e

echo "=========================================="
echo " Expo Dev Container - Post Create Setup "
echo "=========================================="

echo ""
echo "Running as user: $(whoami)"
echo "Workspace permissions: $(ls -ld /workspace 2>/dev/null || echo 'cannot access')"

echo ""
echo "Node version: $(node --version)"
echo "npm version: $(npm --version)"
echo "Bun version: $(bun --version)"

echo ""
echo "Fixing workspace permissions..."
sudo chown -R vscode:vscode /workspace 2>/dev/null || true

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
        bun expo install
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
