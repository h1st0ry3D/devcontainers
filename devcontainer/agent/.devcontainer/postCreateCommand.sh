#!/bin/bash
set -e

export HOMEBREW_NONINTERACTIVE=1
export HOMEBREW_NO_AUTO_UPDATE=1

echo "=========================================="
echo "  Agent Dev Container - Post Setup         "
echo "=========================================="

echo "Fixing Homebrew permissions..."
sudo chown -R $(whoami) /home/linuxbrew/.linuxbrew

echo "Installing chezmoi..."
yes | brew install chezmoi

echo "Applying dotfiles from chezmoi..."
chezmoi init https://github.com/hstorz/dotfiles.git --no-tty || true
chezmoi apply --destination=$HOME --no-tty || true

echo "Installing packages from Brewfile..."
yes | brew bundle --file=$HOME/Brewfile || true

echo "=========================================="
echo "  Dev container ready!                    "
echo "=========================================="
