# Dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/) on macOS.

## Bootstrap

```bash
chezmoi init --apply https://github.com/harrymasson/dotfiles.git
brew bundle --file="$(chezmoi source-path)/Brewfile"
mise install && exec zsh
```

See [docs/getting-started/install.md](docs/getting-started/install.md) for the full guide.

## Docs

```bash
make docs
```

Opens the documentation site at http://127.0.0.1:8000. Requires `pip install mkdocs-material`.

## What's managed

Zsh, Git, Tmux, Neovim, Ghostty, mise (Node/Python), Starship, Homebrew Brewfile, btop/htop.

## Key commands

```bash
chezmoi status          # see what's drifted
chezmoi diff            # preview changes
chezmoi apply           # apply to ~/
chezmoi edit ~/.zshrc   # edit a managed file
```
