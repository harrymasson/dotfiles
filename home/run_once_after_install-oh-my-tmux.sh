#!/bin/bash
# Install oh-my-tmux and symlink ~/.tmux.conf
# Runs once after dotfiles are written; re-run by bumping the version comment above
# or: chezmoi state reset

set -e

OHMYTMUX="$HOME/.tmux"

if [ ! -d "$OHMYTMUX" ]; then
  echo "Installing oh-my-tmux..."
  git clone https://github.com/gpakosz/.tmux.git "$OHMYTMUX"
else
  echo "oh-my-tmux already installed at $OHMYTMUX, skipping clone."
fi

# Symlink ~/.tmux.conf → oh-my-tmux main config
ln -sf "$OHMYTMUX/.tmux.conf" "$HOME/.tmux.conf"

echo "oh-my-tmux ready. ~/.tmux.conf.local holds your customisations."
