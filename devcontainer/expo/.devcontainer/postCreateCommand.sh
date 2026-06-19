#!/bin/bash
# Installs app dependencies after container creation.
set -euo pipefail

WORKSPACE_DIR="/workspace"
APP_DIR="$WORKSPACE_DIR/app"
if [ ! -f "$APP_DIR/package.json" ] && [ -f "$WORKSPACE_DIR/package.json" ]; then
	APP_DIR="$WORKSPACE_DIR"
fi

TEMP_NPMRC_PATH=""

cleanup() {
	if [ -n "$TEMP_NPMRC_PATH" ] && [ -f "$TEMP_NPMRC_PATH" ]; then
		rm -f "$TEMP_NPMRC_PATH"
	fi
}

trap cleanup EXIT

ensure_shell_activation() {
	local shell_rc="$1"
	local activation_line="$2"

	touch "$shell_rc"
	if ! grep -Fqx "$activation_line" "$shell_rc"; then
		printf '\n%s\n' "$activation_line" >> "$shell_rc"
	fi
}

configure_registry_auth() {
	local env_file="$WORKSPACE_DIR/mise.env"
	local npmrc_path="$WORKSPACE_DIR/.npmrc"
	local local_npmrc_path="$WORKSPACE_DIR/.npmrc.local"

	if [ -f "$env_file" ]; then
		set -a
		# shellcheck disable=SC1090
		source "$env_file"
		set +a
	fi

	if [ ! -f "$npmrc_path" ] || [ ! -f "$local_npmrc_path" ]; then
		return 0
	fi

	TEMP_NPMRC_PATH="$(mktemp)"
	cat "$npmrc_path" "$local_npmrc_path" > "$TEMP_NPMRC_PATH"
	export NPM_CONFIG_USERCONFIG="$TEMP_NPMRC_PATH"
}

configure_mise() {
	if ! command -v mise >/dev/null 2>&1; then
		echo "✗ mise is not available on PATH" >&2
		exit 1
	fi

	ensure_shell_activation "$HOME/.bashrc" 'eval "$(mise activate bash)"'
	ensure_shell_activation "$HOME/.zshrc" 'eval "$(mise activate zsh)"'

	if [ ! -f "$WORKSPACE_DIR/mise.toml" ]; then
		echo "⚠ No mise.toml found at $WORKSPACE_DIR; skipping toolchain install"
		return 0
	fi

	echo "Installing toolchain from $WORKSPACE_DIR/mise.toml..."
	cd "$WORKSPACE_DIR"
	if grep -Eq '^\[tools\.android-sdk\]$|^android-sdk[[:space:]]*=' "$WORKSPACE_DIR/mise.toml"; then
		echo "Ensuring Java is installed before Android SDK setup..."
		mise install java
	fi
	mise install
	mise reshim
}

prepare_android_user_home() {
	local android_user_home="${ANDROID_USER_HOME:-$HOME/.android}"

	mkdir -p "$android_user_home/cache"
	touch "$android_user_home/repositories.cfg"
}

print_tool_versions() {
	echo "Toolchain ready:"
	echo "  mise: $(mise --version)"
	echo "  node: $(mise exec -- node --version)"
	echo "  bun: $(mise exec -- bun --version)"
	echo "  python: $(mise exec -- python3 --version)"
	echo "  java: $(mise exec -- sh -lc 'java -version 2>&1 | head -n 1')"
	echo "  sdkmanager: $(mise exec -- sdkmanager --version)"
}

echo "=========================================="
echo "  Expo Dev Container - Post-Create Setup "
echo "=========================================="

configure_registry_auth
prepare_android_user_home
configure_mise
print_tool_versions
echo "Resolved project directory: $APP_DIR"
echo "Android SDK root: ${ANDROID_HOME:-/root/.local/share/mise/installs/android-sdk/20.0}"
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
	mise exec -- bun install --frozen-lockfile --ignore-scripts
	echo "✓ Dependencies installed"
else
	echo "⚠ No package.json found at $APP_DIR; skipping dependency install"
fi

echo ""
echo "✓ Post-create setup complete"
