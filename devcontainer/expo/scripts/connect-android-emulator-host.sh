#!/bin/bash
set -euo pipefail

TARGET="${1:-host.docker.internal:5555}"
ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-${ANDROID_HOME:-/usr/lib/android-sdk}}"
export PATH="$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$PATH"

if ! command -v adb >/dev/null 2>&1; then
	echo "❌ Error: adb is not installed or not on PATH."
	echo "   Expected it at: $ANDROID_SDK_ROOT/platform-tools/adb"
	exit 1
fi

echo "🔌 Connecting Android emulator through Podman host gateway: $TARGET"
adb start-server >/dev/null 2>&1 || true
adb connect "$TARGET"
echo ""
adb devices

DEVICE_STATE="$(adb devices | awk -v target="$TARGET" '$1 == target {print $2; exit}')"
case "$DEVICE_STATE" in
	device)
		echo "✅ Android emulator is connected."
		;;
	unauthorized)
		echo "❌ Android emulator is connected but unauthorized."
		echo "   Unlock the emulator on the host and accept the USB debugging/RSA prompt, then run this task again."
		exit 2
		;;
	offline)
		echo "❌ Android emulator is connected but offline."
		echo "   Restart ADB/emulator, then run this task again."
		exit 3
		;;
	*)
		echo "❌ Android emulator did not appear in adb devices as $TARGET."
		exit 4
		;;
esac