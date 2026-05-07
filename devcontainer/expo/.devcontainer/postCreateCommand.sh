#!/bin/bash
# Repairs Podman mount permissions and installs app dependencies after container creation.
set -euo pipefail

APP_DIR="/workspace/app"
if [ ! -f "$APP_DIR/package.json" ] && [ -f "/workspace/package.json" ]; then
	APP_DIR="/workspace"
fi

echo "=========================================="
echo "  Expo Dev Container - Post-Create Setup "
echo "=========================================="
echo "Node version: $(node --version)"
echo "npm version: $(npm --version)"
echo "Bun version: $(bun --version)"

if ! command -v bun >/dev/null 2>&1; then
	echo "✗ Bun is not available on PATH" >&2
	exit 1
fi

bash /workspace/.devcontainer/fixPodmanPermissions.sh "$APP_DIR"

if [ -f "$APP_DIR/package.json" ]; then
	echo ""
	echo "Installing dependencies in $APP_DIR..."
	cd "$APP_DIR"
	if [ -f bun.lock ] || [ -f bun.lockb ]; then
		bun install --frozen-lockfile
	else
		bun install
	fi
	echo "✓ Dependencies installed"
else
	echo "⚠ No package.json found at $APP_DIR; skipping dependency install"
fi

echo ""
echo "✓ Post-create setup complete"
