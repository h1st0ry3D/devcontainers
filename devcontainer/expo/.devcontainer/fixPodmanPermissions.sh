#!/bin/bash
set -euo pipefail

APP_DIR="${1:-/workspace/app}"
if [ ! -f "$APP_DIR/package.json" ] && [ -f "/workspace/package.json" ]; then
	APP_DIR="/workspace"
fi

SUDO=""
if sudo -n true 2>/dev/null; then
	SUDO="sudo -n"
fi

repair_tmp() {
	if [ -n "$SUDO" ]; then
		$SUDO chmod 1777 /tmp || true
	else
		chmod 1777 /tmp 2>/dev/null || true
	fi
}

repair_workspace_bind_mount() {
	if [ ! -d "$APP_DIR" ] || [ -w "$APP_DIR" ]; then
		return
	fi

	if [ -n "$SUDO" ]; then
		$SUDO chmod o+rwX "$APP_DIR" || true
		$SUDO find "$APP_DIR" -type d -exec chmod o+rwx {} + || true
		$SUDO find "$APP_DIR" -type f -exec chmod o+rw {} + || true
		echo "✓ Repaired bind-mount permissions for $APP_DIR"
	else
		echo "⚠ sudo not available non-interactively; bind-mount permission repair skipped"
	fi
}

repair_native_project_dirs() {
	local native_dir

	for native_dir in "$APP_DIR/ios" "$APP_DIR/android"; do
		if [ ! -d "$native_dir" ]; then
			continue
		fi

		if [ -n "$SUDO" ]; then
			$SUDO find "$native_dir" -type d -exec chmod o+rwx {} + 2>/dev/null || true
			$SUDO find "$native_dir" -type f -exec chmod o+rw {} + 2>/dev/null || true
			echo "✓ Repaired native project permissions for $native_dir"
		else
			echo "⚠ sudo not available non-interactively; native project permission repair skipped for $native_dir"
		fi
	done
}

repair_node_modules_volume() {
	local node_modules_dir="$APP_DIR/node_modules"

	if [ ! -d "$node_modules_dir" ]; then
		return
	fi

	if touch "$node_modules_dir/.podman-write-test" 2>/dev/null; then
		rm -f "$node_modules_dir/.podman-write-test"
		return
	fi

	if [ -n "$SUDO" ]; then
		$SUDO chown -R vscode:vscode "$node_modules_dir" || true
		$SUDO chmod -R u+rwX,g+rwX "$node_modules_dir" || true
		echo "✓ Repaired node_modules volume permissions"
	else
		echo "⚠ sudo not available non-interactively; node_modules permission repair skipped"
	fi
}

repair_tmp
repair_workspace_bind_mount
repair_native_project_dirs
repair_node_modules_volume