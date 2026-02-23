# Homebrew Reference

Package management on macOS. The `Brewfile` at the repo root is the declarative package list.

## Key commands

```bash
# Install everything in the Brewfile
brew bundle --file="$(chezmoi source-path)/Brewfile"

# Check what's not in the Brewfile (packages installed outside it)
brew bundle check --file="$(chezmoi source-path)/Brewfile"

# Add a new package to the Brewfile
brew install <package>
# Then add it manually to Brewfile, or:
brew bundle dump --force --file="$(chezmoi source-path)/Brewfile"

# Update all packages
brew upgrade

# Remove unused dependencies
brew autoremove
```

## Brewfile format

```ruby
# CLI tools
brew "ripgrep"
brew "fzf"

# GUI apps
cask "ghostty"
cask "obsidian"

# Mac App Store
mas "1Password", id: 1333542190

# VS Code extensions
vscode "ms-python.python"
```

## Key tools installed

See the Brewfile for the full list. Highlights:

- **Shell**: `zsh`, `zsh-completions`, `starship`, `zinit`
- **Navigation**: `fzf`, `zoxide`, `eza`, `bat`, `ripgrep`, `fd`
- **Git**: `git`, `git-lfs`, `lazygit`, `diff-so-fancy`, `gh`
- **Runtime**: `mise`, `uv`
- **Terminal**: `tmux`, `ghostty`
- **Editors**: `neovim`
- **System**: `htop`, `btop`, `dust`, `jq`, `mtr`, `nmap`
