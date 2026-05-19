#!/bin/bash

# Change DEVCONTAINER_PROJECT_SUBPATH to "app" for repositories that keep package.json below /workspace/app.
DEVCONTAINER_WORKSPACE_DIR="${DEVCONTAINER_WORKSPACE_DIR:-/workspace}"
DEVCONTAINER_PROJECT_SUBPATH="${DEVCONTAINER_PROJECT_SUBPATH:-.}"

join_project_path() {
	local base_dir="$1"
	local relative_path="${2:-.}"

	case "$relative_path" in
		""|".")
			printf '%s\n' "${base_dir%/}"
			;;
		*)
			printf '%s\n' "${base_dir%/}/$relative_path"
			;;
	esac
}

resolve_project_dir() {
	local base_dir="$1"
	local project_subpath="${2:-$DEVCONTAINER_PROJECT_SUBPATH}"
	local candidate_dir

	candidate_dir="$(join_project_path "$base_dir" "$project_subpath")"

	if [ -f "$candidate_dir/package.json" ]; then
		printf '%s\n' "$candidate_dir"
	elif [ -f "$base_dir/package.json" ]; then
		printf '%s\n' "$base_dir"
	else
		printf '%s\n' "$candidate_dir"
	fi
}

resolve_container_project_dir() {
	resolve_project_dir "$DEVCONTAINER_WORKSPACE_DIR" "$DEVCONTAINER_PROJECT_SUBPATH"
}

resolve_host_project_dir() {
	local repo_dir="$1"
	resolve_project_dir "$repo_dir" "$DEVCONTAINER_PROJECT_SUBPATH"
}