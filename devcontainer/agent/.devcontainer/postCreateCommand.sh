#!/bin/bash
set -e

export PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH"

echo "=========================================="
echo "  Brew Dev Container - Post Setup          "
echo "=========================================="

echo "Applying dotfiles from chezmoi..."
chezmoi init https://github.com/hstorz/dotfiles.git --no-tty || true
chezmoi apply --destination=$HOME --no-tty || true

echo "=========================================="
echo "  Dev container ready!                    "
echo "=========================================="