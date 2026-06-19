#!/bin/bash
set -e

echo "=========================================="
echo "  Agent Dev Container - Post Setup         "
echo "=========================================="

echo "Applying dotfiles from chezmoi..."
chezmoi init https://github.com/h1st0ry3D/dotfiles.git --no-tty || true
chezmoi apply --destination=$HOME --no-tty || true

echo "=========================================="
echo "  Dev container ready!                    "
echo "=========================================="
