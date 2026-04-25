#!/bin/bash
# Build iOS dev-client on macOS host (helper for Linux container workflow)
#
# The devcontainer runs Linux, so it cannot compile iOS apps with Xcode.
# This script temporarily installs node_modules on the HOST macOS filesystem
# so CocoaPods can resolve dependencies, then cleans them up automatically.
#
# Usage:
#   cd /Users/heiko/Git/devcontainers/devcontainer/expo
#   ./scripts/build-ios-host.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="$(cd "$SCRIPT_DIR/../app" && pwd)"
HOST_NODE_MODULES="$APP_DIR/node_modules"

# ─── Validation ──────────────────────────────────────────────────

if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ Error: This script must run on macOS (host), not in the Linux container."
    exit 1
fi

if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Error: Xcode not found. Install Xcode from the App Store."
    exit 1
fi

if [ ! -d "$APP_DIR/ios" ]; then
    echo "❌ Error: ios/ directory not found."
    echo "   Run this first in the container: cd app && bun expo prebuild --platform ios"
    exit 1
fi

# ─── Temporary host node_modules ──────────────────────────────

if [ -d "$HOST_NODE_MODULES" ] && [ -n "$(ls -A "$HOST_NODE_MODULES" 2>/dev/null)" ]; then
    echo "⚠️  Existing host node_modules found. Removing for clean install..."
    rm -rf "$HOST_NODE_MODULES"
fi

echo "📦 Installing temporary node_modules on host for CocoaPods..."
cd "$APP_DIR"
npm install

# ─── CocoaPods ──────────────────────────────────────────────────

echo "📦 Running pod install..."
cd "$APP_DIR/ios"
if command -v pod &> /dev/null; then
    pod install
else
    echo "❌ Error: CocoaPods not found. Install it: sudo gem install cocoapods"
    exit 1
fi

# ─── Cleanup (automatic) ──────────────────────────────────────────

echo "🧹 Cleaning up temporary host node_modules..."
rm -rf "$HOST_NODE_MODULES"
echo "✓ Host node_modules removed. Container node_modules (Docker volume) is untouched."

# ─── Open Xcode ─────────────────────────────────────────────────

echo ""
echo "🚀 Opening Xcode..."
echo "   Select a Simulator and press Cmd+B (build) / Cmd+R (run)."
echo ""
open "$APP_DIR/ios"/*.xcworkspace
