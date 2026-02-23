#!/bin/bash
# Install TPM (Tmux Plugin Manager)
# Runs once after dotfiles are written. Re-run by changing the version comment.
# Requires oh-my-tmux to already be installed (run_once_after_install-oh-my-tmux.sh runs first).

set -e

TPM_DIR="$HOME/.tmux/plugins/tpm"

if [ ! -d "$TPM_DIR" ]; then
  echo "Installing TPM..."
  git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
else
  echo "TPM already installed at $TPM_DIR, skipping clone."
fi

echo "TPM ready. Open a tmux session and press C-a I to install plugins."
