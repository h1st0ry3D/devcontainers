#!/bin/bash
set -euo pipefail

WORKSPACE_DIR="/workspace"
APP_DIR="${1:-$WORKSPACE_DIR/app}"
if [ ! -f "$APP_DIR/package.json" ] && [ -f "$WORKSPACE_DIR/package.json" ]; then
	APP_DIR="$WORKSPACE_DIR"
fi

CURRENT_UID="$(id -u)"
CURRENT_GID="$(id -g)"
SUDO=""
if sudo -n true 2>/dev/null; then
	SUDO="sudo -n"
fi

run_as_root() {
	if [ -n "$SUDO" ]; then
		$SUDO "$@"
	else
		"$@"
	fi
}

can_write_dir() {
	local dir="$1"
	local probe_file="$dir/.devcontainer-write-probe-$$"

	[ -d "$dir" ] || return 1
	touch "$probe_file" 2>/dev/null || return 1
	rm -f "$probe_file"
}

can_write_file() {
	local file="$1"

	[ ! -f "$file" ] || : >> "$file" 2>/dev/null
}

require_sudo() {
	if [ -n "$SUDO" ]; then
		return 0
	fi

	echo "⚠ $1 is not writable, and passwordless sudo is unavailable."
	echo "  Rebuild/reopen the devcontainer. For rootless Podman, keep .devcontainer/devcontainer.json using '--userns=keep-id'."
	return 1
}

repair_tmp() {
	run_as_root chmod 1777 /tmp 2>/dev/null || true
}

workspace_is_writable() {
	can_write_dir "$WORKSPACE_DIR" \
		&& can_write_dir "$APP_DIR" \
		&& can_write_file "$WORKSPACE_DIR/.gitignore" \
		&& can_write_file "$APP_DIR/.gitignore" \
		&& can_write_file "$APP_DIR/package.json"
}

find_unwritable_workspace_path() {
	find "$WORKSPACE_DIR" \
		\( \
			-name ".DS_Store" -o \
			-path "$APP_DIR/node_modules" -o \
			-path "$APP_DIR/node_modules/*" -o \
			-path "$APP_DIR/ios/Pods" -o \
			-path "$APP_DIR/ios/Pods/*" -o \
			-path "$APP_DIR/ios/build" -o \
			-path "$APP_DIR/ios/build/*" -o \
			-path "$APP_DIR/android/build" -o \
			-path "$APP_DIR/android/build/*" -o \
			-path "$APP_DIR/android/.gradle" -o \
			-path "$APP_DIR/android/.gradle/*" \
		\) -prune -o \
		! -writable \
		-print -quit 2>/dev/null || true
}

repair_workspace_bind_mount() {
	local unwritable_path

	unwritable_path="$(find_unwritable_workspace_path)"
	if workspace_is_writable && [ -z "$unwritable_path" ]; then
		echo "✓ Workspace bind mount is writable"
		return
	fi

	require_sudo "$WORKSPACE_DIR" || return

	echo "Repairing Podman bind-mount ownership for $WORKSPACE_DIR..."
	if [ -n "$unwritable_path" ]; then
		echo "First unwritable path: $unwritable_path"
	fi
	run_as_root find "$WORKSPACE_DIR" \
		\( \
			-name ".DS_Store" -o \
			-path "$APP_DIR/node_modules" -o \
			-path "$APP_DIR/node_modules/*" -o \
			-path "$APP_DIR/ios/Pods" -o \
			-path "$APP_DIR/ios/Pods/*" -o \
			-path "$APP_DIR/ios/build" -o \
			-path "$APP_DIR/ios/build/*" -o \
			-path "$APP_DIR/android/build" -o \
			-path "$APP_DIR/android/build/*" -o \
			-path "$APP_DIR/android/.gradle" -o \
			-path "$APP_DIR/android/.gradle/*" \
		\) -prune -o \
		! -writable \
		-exec chown "$CURRENT_UID:$CURRENT_GID" {} + 2>/dev/null || true
dock
	if workspace_is_writable; then
		echo "✓ Repaired workspace bind-mount ownership"
	else
		echo "⚠ $WORKSPACE_DIR is still not writable. Rebuild/reopen the devcontainer and verify Podman is using '--userns=keep-id'."
	fi
}

repair_node_modules_volume() {
	local node_modules_dir="$APP_DIR/node_modules"

	[ -d "$node_modules_dir" ] || return
	if can_write_dir "$node_modules_dir"; then
		echo "✓ node_modules volume is writable"
		return
	fi

	require_sudo "$node_modules_dir" || return

	echo "Repairing node_modules volume ownership..."
	run_as_root chown -R "$CURRENT_UID:$CURRENT_GID" "$node_modules_dir"
	can_write_dir "$node_modules_dir" && echo "✓ Repaired node_modules volume ownership"
}

repair_tmp
repair_workspace_bind_mount
repair_node_modules_volume