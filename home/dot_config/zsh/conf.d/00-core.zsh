# ~/.config/zsh/conf.d/00-core.zsh
# Purpose: Core environment — editor, color, PATH additions, shell options.
# Source: chezmoi: home/dot_config/zsh/conf.d/00-core.zsh

# Editor
export EDITOR="nano"

# 24-bit color
export COLORTERM=truecolor
export TERM="xterm-256color"

# PATH additions (idempotent-safe order: local bin, cargo)
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"

# Shell options
setopt auto_cd auto_pushd pushd_ignore_dups

# Keybindings — emacs base; zsh-vi-mode plugin (loaded in .zshrc) layers vi on top
bindkey -e
