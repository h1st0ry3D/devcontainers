# Brew Dev Container

Dev container with Homebrew, opencode (AI agent), and dotfiles from hstorz/dotfiles.

## How It Works

1. **Base Image** - Ubuntu Noble
2. **Install Homebrew** - Official install script (Linuxbrew)
3. **Run brew bundle** - At build time from github.com/hstorz/dotfiles/Brewfile
4. **Apply chezmoi** - On container start (postCreateCommand)

## Quick Start

1. Open project in VS Code
2. `Ctrl+Shift+P` → **"Dev Containers: Reopen in Container"**
3. Wait for container to build

## Usage

### AI Agent (opencode)
```bash
opencode
```

### Terminal
```bash
zsh
```

## Installed Tools

| Tool | Description |
|------|-------------|
| `opencode` | AI coding assistant |
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
brew/
└── .devcontainer/
    ├── devcontainer.json
    ├── Dockerfile
    ├── postCreateCommand.sh
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

### Re-run bundle install
```bash
brew bundle install
```