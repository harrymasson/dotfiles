# ~/.config/zsh/conf.d/40-python.zsh
# Purpose: Python tooling — uv completions.
# Source: chezmoi: home/dot_config/zsh/conf.d/40-python.zsh
# Notes: Python version management is handled by mise (41-mise.zsh).
#        uv is used for package/project management; pyenv has been retired.

# uv shell completions (only after compinit has run)
(( $+functions[compdef] )) && eval "$(uv generate-shell-completion zsh)"
