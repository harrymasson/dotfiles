# Dotfiles

Personal macOS dotfiles managed with [chezmoi](https://www.chezmoi.io/). One repo drives shell config, editor setup, keyboard remapping, runtime versions, and package installs across machines — with machine-specific variations handled through templates rather than branches.

## What's managed

- **Zsh** — modular config chain with plugins (autosuggestions, syntax highlighting, vi-mode, fzf)
- **Git** — global config, ignore patterns, diff-so-fancy pager, lazygit
- **Tmux** — oh-my-tmux with Catppuccin theme, custom keybindings
- **Neovim** — LazyVim setup
- **Karabiner-Elements** — caps→ctrl globally; cmd↔opt swap for external keyboards
- **Ghostty** — terminal with Catppuccin themes
- **mise** — polyglot runtime version manager (Node, Python)
- **Homebrew** — `Brewfile` for reproducible package installs
- **Starship** — shell prompt

## Design goals

- **Single source of truth** — one repo manages all personal configs across machines
- **Machine-specific without branching** — templates and data files handle per-machine differences
- **Work/personal separation** — work config lives in an overlay repo; personal stays clean
- **Secrets never committed** — SSH keys generated per-machine; sensitive values in untracked `local/` files
- **Fast bootstrap** — new machine fully configured in a few commands

## Sections

- **[Getting Started](getting-started/index.md)** — what's managed, install on a new machine, repo structure
- **[Quick Reference](quick-reference/index.md)** — workflow guides: navigation, git, development, sessions, remote
- **[Tools](tools/chezmoi.md)** — per-tool config reference: chezmoi, git, homebrew, mise, tmux, zsh
- **[Worklog](worklog/index.md)** — setup notes and migration docs (historical, not evergreen)
- **[Archive](archive/past-experiments.md)** — past experiments and abandoned approaches

## Quick start

```bash
# 1. Apply dotfiles (will prompt for machine type: personal/work)
chezmoi init --apply https://github.com/harrymasson/dotfiles.git

# 2. Install all Homebrew packages declared in Brewfile
brew bundle --file="$(chezmoi source-path)/Brewfile"

# 3. Install pinned runtime versions (Node, Python via mise)
mise install

# 4. Reload shell to pick up the new config
exec zsh
```

View docs locally: `mkdocs serve` from the repo root.
