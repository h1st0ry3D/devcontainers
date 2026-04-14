#!/bin/bash
set -e

echo "=========================================="
echo " Expo Dev Container - Post Create Setup "
echo "=========================================="

echo ""
echo "Installing Bun..."
if ! command -v bun &> /dev/null; then
    curl -fsSL https://bun.sh/install | bash
    export PATH="$HOME/.bun/bin:$PATH"
fi

echo ""
echo "Bun version: $(bun --version)"

echo ""
echo "Installing expo-cli globally..."
bun install -g expo-cli

echo ""
echo "Installing project dependencies with Bun..."
if [ -f "bun.lockb" ] || [ -f "package.json" ]; then
    bun install
else
    echo "No lockfile found. Running 'bun install' in project root..."
    bun install
fi

echo ""
echo "Installing Expo dependencies..."
if [ -f "package.json" ]; then
    # Check if expo is in dependencies
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
echo " Dev container ready with Bun! "
echo "=========================================="
echo ""
echo "To run Expo app:"
echo "  bun expo start"
echo ""
echo "For Android device/emulator:"
echo "  bun expo start --android"
echo ""
echo "For iOS simulator (macOS host only):"
echo "  bun expo start --ios"
echo ""
echo "For development builds (dev client):"
echo "  bun expo run:android"
echo "  bun expo run:ios"
echo ""
echo "Package Manager: Bun $(bun --version)"
echo "=========================================="
