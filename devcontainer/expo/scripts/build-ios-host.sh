#!/bin/bash
# Build the iOS dev client on macOS using dependencies copied from the running
# Podman devcontainer, so the host never runs npm/bun install.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="$(cd "$SCRIPT_DIR/../app" && pwd)"
HOST_NODE_MODULES="$APP_DIR/node_modules"
PODMAN_BIN="${PODMAN_BIN:-/opt/podman/bin/podman}"
TEMP_ROOT=""
RESTORE_ORIGINAL_NODE_MODULES=0
ORIGINAL_NODE_MODULES_BACKUP=""

normalize_ios_permissions() {
    if [ -d "$APP_DIR/ios" ]; then
        chmod -R o+rwX "$APP_DIR/ios" 2>/dev/null || true
    fi
}

cleanup() {
    local exit_code=$?

    if [ -L "$HOST_NODE_MODULES" ]; then
        rm -f "$HOST_NODE_MODULES"
    fi

    if [ "$RESTORE_ORIGINAL_NODE_MODULES" -eq 1 ] && [ -n "$ORIGINAL_NODE_MODULES_BACKUP" ] && [ -e "$ORIGINAL_NODE_MODULES_BACKUP" ]; then
        mv "$ORIGINAL_NODE_MODULES_BACKUP" "$HOST_NODE_MODULES"
    elif [ ! -e "$HOST_NODE_MODULES" ]; then
        mkdir -p "$HOST_NODE_MODULES"
    fi

    if [ -n "$TEMP_ROOT" ] && [ -d "$TEMP_ROOT" ]; then
        rm -rf "$TEMP_ROOT"
    fi

    exit "$exit_code"
}

trap cleanup EXIT

if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ Error: This script must run on macOS (host), not in the Linux container."
    exit 1
fi

if ! command -v "$PODMAN_BIN" >/dev/null 2>&1; then
    echo "❌ Error: Podman not found at $PODMAN_BIN"
    exit 1
fi

if ! command -v xcodebuild >/dev/null 2>&1; then
    echo "❌ Error: Xcode not found. Install Xcode from the App Store."
    exit 1
fi

if ! command -v pod >/dev/null 2>&1; then
    echo "❌ Error: CocoaPods not found. Install it first (for example: brew install cocoapods)."
    exit 1
fi

if [ ! -d "$APP_DIR/ios" ]; then
    echo "❌ Error: ios/ directory not found."
    echo "   Run this first in the container: cd app && bun run prebuild:ios"
    exit 1
fi

CONTAINER_ID="$($PODMAN_BIN ps --filter volume=expo-node_modules --format '{{.ID}}' | head -n1)"
if [ -z "$CONTAINER_ID" ]; then
    echo "❌ Error: No running Podman devcontainer found."
    echo "   Start or reopen the devcontainer in VS Code, then try again."
    exit 1
fi

CONTAINER_APP_DIR="/workspace/app"
if ! "$PODMAN_BIN" exec "$CONTAINER_ID" test -f "$CONTAINER_APP_DIR/package.json"; then
    CONTAINER_APP_DIR="/workspace"
fi

if ! "$PODMAN_BIN" exec "$CONTAINER_ID" test -f "$CONTAINER_APP_DIR/package.json"; then
    echo "❌ Error: Could not find package.json inside the running devcontainer."
    exit 1
fi

if ! "$PODMAN_BIN" exec "$CONTAINER_ID" test -f "$CONTAINER_APP_DIR/node_modules/expo/package.json"; then
    echo "📦 Container dependencies are missing; installing them inside the running Podman devcontainer..."
    "$PODMAN_BIN" exec -u vscode "$CONTAINER_ID" sh -lc "cd '$CONTAINER_APP_DIR' && bun install"
fi

TEMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/expo-ios-host.XXXXXX")"

if [ -L "$HOST_NODE_MODULES" ]; then
    ORIGINAL_NODE_MODULES_BACKUP="$TEMP_ROOT/original-node_modules"
    mv "$HOST_NODE_MODULES" "$ORIGINAL_NODE_MODULES_BACKUP"
    RESTORE_ORIGINAL_NODE_MODULES=1
elif [ -d "$HOST_NODE_MODULES" ] && [ -n "$(ls -A "$HOST_NODE_MODULES" 2>/dev/null)" ]; then
    ORIGINAL_NODE_MODULES_BACKUP="$TEMP_ROOT/original-node_modules"
    mv "$HOST_NODE_MODULES" "$ORIGINAL_NODE_MODULES_BACKUP"
    RESTORE_ORIGINAL_NODE_MODULES=1
elif [ -d "$HOST_NODE_MODULES" ]; then
    rmdir "$HOST_NODE_MODULES" 2>/dev/null || rm -rf "$HOST_NODE_MODULES"
fi

echo "📦 Copying node_modules from Podman container $CONTAINER_ID..."
"$PODMAN_BIN" cp "$CONTAINER_ID:$CONTAINER_APP_DIR/node_modules" "$TEMP_ROOT"
ln -s "$TEMP_ROOT/node_modules" "$HOST_NODE_MODULES"

echo "📦 Running pod install using dependencies copied from the container..."
cd "$APP_DIR/ios"
pod install
normalize_ios_permissions

XCODE_WORKSPACE="$(find "$APP_DIR/ios" -maxdepth 1 -name '*.xcworkspace' | head -n1)"
if [ -z "$XCODE_WORKSPACE" ]; then
    echo "❌ Error: No .xcworkspace found after pod install."
    exit 1
fi

echo ""
echo "🚀 Opening Xcode and keeping temporary node_modules available until Xcode closes..."
echo "   Build/run in Xcode, then quit Xcode to trigger automatic cleanup."
echo ""
open -a Xcode -W "$XCODE_WORKSPACE"
normalize_ios_permissions
