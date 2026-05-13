#!/bin/bash
set -euo pipefail

ensure_allowed_path() {
	local resolved_path
	resolved_path="$(realpath -m "$1")"

	case "$resolved_path" in
		/workspace|/workspace/*)
			printf '%s\n' "$resolved_path"
			;;
		*)
			echo "Refusing to operate on path outside /workspace: $1" >&2
			exit 1
			;;
	esac
}

repair_tmp() {
	chmod 1777 /tmp
}

repair_workspace() {
	local workspace_dir app_dir uid gid
	workspace_dir="$(ensure_allowed_path "$1")"
	app_dir="$(ensure_allowed_path "$2")"
	uid="$3"
	gid="$4"

	find "$workspace_dir" \
		\( \
			-name ".DS_Store" -o \
			-path "$app_dir/node_modules" -o \
			-path "$app_dir/node_modules/*" -o \
			-path "$app_dir/ios/Pods" -o \
			-path "$app_dir/ios/Pods/*" -o \
			-path "$app_dir/ios/build" -o \
			-path "$app_dir/ios/build/*" -o \
			-path "$app_dir/android/build" -o \
			-path "$app_dir/android/build/*" -o \
			-path "$app_dir/android/.gradle" -o \
			-path "$app_dir/android/.gradle/*" \
		\) -prune -o \
		! -writable \
		-exec chown "$uid:$gid" {} +
}

repair_dir() {
	local target_dir uid gid
	target_dir="$(ensure_allowed_path "$1")"
	uid="$2"
	gid="$3"

	[ -d "$target_dir" ] || exit 0
	chown -R "$uid:$gid" "$target_dir"
}

case "${1:-}" in
	repair-tmp)
		repair_tmp
		;;
	repair-workspace)
		[ "$#" -eq 5 ] || exit 64
		shift
		repair_workspace "$@"
		;;
	repair-dir)
		[ "$#" -eq 4 ] || exit 64
		shift
		repair_dir "$@"
		;;
	*)
		echo "Unknown action: ${1:-}" >&2
		exit 64
		;;
esac
