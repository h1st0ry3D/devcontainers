# Agent Dev Container

Dev container with Homebrew, opencode (AI agent), pi (AI agent), and dotfiles from hstorz/dotfiles.

## How It Works

1. **Base Image** - `mcr.microsoft.com/devcontainers/base:bookworm` (Debian 12 with `vscode` user at UID 1000)
2. **Homebrew** - Official install script, all tools installed via `brew bundle` at build time
3. **Dotfiles** - Applied via chezmoi on container start

## Quick Start

Open in VS Code → `Ctrl+Shift+P` → **"Dev Containers: Reopen in Container"**

## Usage

```bash
opencode  # OpenCode AI agent
pi        # Pi AI agent
zsh       # Default shell
```

## Installed Tools

| Tool | Description |
|------|-------------|
| `opencode` | AI coding assistant |
| `pi` | AI coding agent |
| `chezmoi` | Dotfiles manager |
| `lazygit` | TUI git client |
| `fzf` | Fuzzy finder |
| `tmux` | Terminal multiplexer |
| `starship` | Prompt |
| `biome` | JS/TS formatter/linter |
| `delta` | Git pager |

## Files

```
agent/
├── .devcontainer/
│   ├── devcontainer.json
│   ├── Dockerfile
│   └── postCreateCommand.sh
├── .dockerignore
└── README.md
```

## Troubleshooting

```bash
# Homebrew not found
export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"

# Re-run dotfiles
chezmoi apply

# Re-install Brewfile packages
brew bundle install
```
