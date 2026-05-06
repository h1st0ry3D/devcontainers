#!/bin/bash
set -euo pipefail

TARGET="${1:-host.docker.internal:5555}"

if ! command -v adb >/dev/null 2>&1; then
	echo "❌ Error: adb is not installed in this environment."
	exit 1
fi

echo "🔌 Connecting Android emulator through Podman host gateway: $TARGET"
adb start-server >/dev/null 2>&1 || true
adb connect "$TARGET"
echo ""
adb devices