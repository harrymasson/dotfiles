# ~/.config/zsh/conf.d/41-mise.zsh
# Purpose: Runtime version management via mise (replaces nvm + pyenv).
# Source: chezmoi: home/dot_config/zsh/conf.d/41-mise.zsh
# Notes: mise activates shims lazily — no meaningful startup cost.
#        Global tool versions live in ~/.config/mise/config.toml.
#        Per-project versions live in .mise.toml at the project root.

if (( $+commands[mise] )); then
  eval "$(mise activate zsh)"
fi
