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
# updateRemoteUserUID should handle this, but ensure workspace is writable
if [ ! -w /workspace ]; then
    echo "Warning: /workspace not writable, attempting fix..."
    # Try to fix ownership (works if container is restarted with correct UID)
    chmod 777 /workspace 2>/dev/null || true
fi

echo ""
echo "Checking node_modules mount..."
if mount | grep -q "node_modules.*volume"; then
    echo "✓ node_modules is on a volume (isolated from host)"
else
    echo "⚠ node_modules may be visible on host (bind mount limitation)"
fi

echo ""
echo "Installing project dependencies..."
if [ -f "/workspace/package.json" ]; then
    # Try bun install first, fall back to npm if it fails
    bun install || npm install
else
    echo "No package.json found. Skipping dependency install."
fi

echo ""
echo "Installing Expo dependencies..."
if [ -f "/workspace/package.json" ]; then
    if grep -q "\"expo\"" /workspace/package.json 2>/dev/null || grep -q '"expo"' /workspace/package.json 2>/dev/null; then
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
