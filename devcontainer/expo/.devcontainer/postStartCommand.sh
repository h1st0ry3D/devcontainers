#!/bin/bash
set -euo pipefail

APP_DIR="/workspace/app"
if [ ! -f "$APP_DIR/package.json" ] && [ -f "/workspace/package.json" ]; then
	APP_DIR="/workspace"
fi

bash /workspace/.devcontainer/fixPodmanPermissions.sh "$APP_DIR"
