#!/bin/bash
set -e

echo "=========================================="
echo "  Agent Dev Container - Post Setup         "
echo "=========================================="

echo "Fixing Homebrew permissions..."
sudo chown -R $(whoami) /home/linuxbrew/.linuxbrew

echo "Applying dotfiles from chezmoi..."
chezmoi init https://github.com/hstorz/dotfiles.git --no-tty || true
chezmoi apply --destination=$HOME --no-tty || true

echo "=========================================="
echo "  Dev container ready!                    "
echo "=========================================="
