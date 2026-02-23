#!/bin/bash
# Install oh-my-tmux and symlink ~/.tmux.conf
# Runs once after dotfiles are written; re-run by bumping the version comment above
# or: chezmoi state reset

set -e

OHMYTMUX="$HOME/.tmux"

# Check for the actual oh-my-tmux config file, not just the directory
# (the directory may already exist from TPM's plugins/ subdirectory)
if [ ! -f "$OHMYTMUX/.tmux.conf" ]; then
  echo "Installing oh-my-tmux..."
  git clone https://github.com/gpakosz/.tmux.git "$OHMYTMUX"
else
  echo "oh-my-tmux already installed at $OHMYTMUX, skipping clone."
fi

# Symlink ~/.tmux.conf → oh-my-tmux main config (only if clone succeeded)
if [ -f "$OHMYTMUX/.tmux.conf" ]; then
  ln -sf "$OHMYTMUX/.tmux.conf" "$HOME/.tmux.conf"
  echo "oh-my-tmux ready. ~/.tmux.conf.local holds your customisations."
else
  echo "ERROR: oh-my-tmux clone failed — ~/.tmux.conf not created." >&2
  exit 1
fi
