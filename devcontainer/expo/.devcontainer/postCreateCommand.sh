#!/bin/bash
# Repairs Podman mount permissions and installs app dependencies after container creation.
set -euo pipefail

APP_DIR="/workspace/app"
if [ ! -f "$APP_DIR/package.json" ] && [ -f "/workspace/package.json" ]; then
	APP_DIR="/workspace"
fi

configure_bun_defaults() {
	cat > "$HOME/.bunfig.toml" <<'EOF'
[install]
minimumReleaseAge = 259200
EOF
}

echo "=========================================="
echo "  Expo Dev Container - Post-Create Setup "
echo "=========================================="
echo "Node version: $(node --version)"
echo "npm version: $(npm --version)"
echo "Bun version: $(bun --version)"
echo "Python version: $(python3 --version)"

if ! command -v bun >/dev/null 2>&1; then
	echo "✗ Bun is not available on PATH" >&2
	exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
	echo "✗ Python 3 is not available on PATH" >&2
	exit 1
fi

bash /workspace/.devcontainer/fixPodmanPermissions.sh "$APP_DIR"
configure_bun_defaults
echo "Configured Bun minimum release age to 3 days in $HOME/.bunfig.toml"
echo "Python package installs require a virtual environment by default."
echo "Gradle dependencies are cached in ${GRADLE_USER_HOME:-/workspace/.gradle}."
echo "Use bun install/bun add for JavaScript dependencies to avoid npm lifecycle scripts."

if [ -f "$APP_DIR/package.json" ]; then
	echo ""
	echo "Installing dependencies in $APP_DIR..."
	cd "$APP_DIR"
	if [ ! -f bun.lock ] && [ ! -f bun.lockb ]; then
		echo "✗ Missing bun lockfile. Commit bun.lock before rebuilding this devcontainer." >&2
		exit 1
	fi
	bun install --frozen-lockfile --ignore-scripts
	echo "✓ Dependencies installed"
else
	echo "⚠ No package.json found at $APP_DIR; skipping dependency install"
fi

echo ""
echo "✓ Post-create setup complete"
