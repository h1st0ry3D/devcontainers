#!/bin/bash
set -e

export PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH"

echo "=========================================="
echo "  Brew Dev Container - Post Setup          "
echo "=========================================="

echo "Installing chezmoi..."
sudo -u linuxbrew HOME=/home/linuxbrew HOMEBREW_CACHE=/home/linuxbrew/.cache/Homebrew /home/linuxbrew/.linuxbrew/bin/brew install chezmoi

echo "Applying dotfiles from chezmoi..."
sudo -u linuxbrew HOME=/home/linuxbrew chezmoi init https://github.com/hstorz/dotfiles.git --no-tty || true
sudo -u linuxbrew HOME=/home/linuxbrew chezmoi apply --destination=/home/linuxbrew --no-tty || true

echo "=========================================="
echo "  Dev container ready!                    "
echo "=========================================="