# Agent Dev Container

Dev container with Homebrew, opencode (AI agent), pi (AI agent), and dotfiles from hstorz/dotfiles.

## How It Works

1. **Base Image** - Ubuntu Noble
2. **Install Homebrew** - Official install script (Linuxbrew)
3. **Install packages from Brewfile** - At build time from github.com/hstorz/dotfiles/Brewfile
4. **Apply chezmoi dotfiles** - On container start (postCreateCommand)

### UID Matching

The container user (`linuxbrew`) uses UID 1000 to match your host user. This prevents file ownership issues on bind-mounted files.

## Quick Start

1. Open project in VS Code
2. `Ctrl+Shift+P` → **"Dev Containers: Reopen in Container"**
3. Wait for container to build

## Usage

### AI Agents
```bash
opencode  # OpenCode AI agent
pi        # Pi AI agent
```

### Terminal
```bash
zsh
```

## Installed Tools

| Tool | Description |
|------|-------------|
| `opencode` | AI coding assistant |
| `pi` | AI coding agent |
| `lazygit` | TUI git client |
| `fzf` | Fuzzy finder |
| `tmux` | Terminal multiplexer |
| `starship` | Prompt |
| `biome` | JS/TS formatter/linter |
| `chezmoi` | Dotfiles manager |
| `delta` | Git pager |

## Zsh Plugins

- zsh-autosuggestions
- zsh-syntax-highlighting

## Dotfiles

Applied via chezmoi from github.com/hstorz/dotfiles:
- `.zshrc` - Zsh configuration
- `.zprofile` - Login profile
- `.tmux.conf` - Tmux settings

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

### Homebrew not found
```bash
export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
```

### chezmoi dotfiles not applied
```bash
chezmoi apply
```

### Re-run brew bundle
```bash
brew bundle install
```
