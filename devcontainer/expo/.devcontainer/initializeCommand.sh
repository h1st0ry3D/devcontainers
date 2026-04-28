#!/bin/bash

get_ip() {
    case "$OSTYPE" in
        msys*|cygwin*|win32*)
            ipconfig | grep -oE 'IPv4[^:]*: ([0-9.]+)' | grep -oE '([0-9.]+)' | head -1
            ;;
        darwin*)
            # macOS - get the primary IP
            ipconfig getifaddr en0 2>/dev/null \
                || ipconfig getifaddr en1 2>/dev/null \
                || ifconfig | awk '/inet / && $2 != "127.0.0.1" {print $2; exit}'
            ;;
        *)
            hostname -I | awk '{print $1}'
            ;;
    esac
}

echo "Gathering host IP for REACT_NATIVE_PACKAGER_HOSTNAME..."
IP=$(get_ip)

if [ -z "$IP" ]; then
    IP="localhost"
    echo "Warning: Could not detect host IP, using localhost"
fi

echo "REACT_NATIVE_PACKAGER_HOSTNAME=${IP}" > .devcontainer/.env
echo "Host IP: ${IP}"
echo ""
echo "Note: This IP will be used by Metro bundler inside the container."
 