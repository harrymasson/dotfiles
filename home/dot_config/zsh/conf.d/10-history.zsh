# ~/.config/zsh/conf.d/10-history.zsh
# Purpose: Shell history configuration.
# Source: chezmoi: home/dot_config/zsh/conf.d/10-history.zsh

HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt inc_append_history share_history hist_ignore_dups hist_reduce_blanks

# Prefix-based history search
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

_bind_history_keys() {
  bindkey '^[[A' up-line-or-beginning-search   # Up arrow
  bindkey '^[[B' down-line-or-beginning-search # Down arrow
  bindkey '^[OA' up-line-or-beginning-search   # Up arrow (xterm alt sequence)
  bindkey '^[OB' down-line-or-beginning-search # Down arrow (xterm alt sequence)
}

# zsh-vi-mode resets all bindings post-init; append to its hook array.
# If zvm isn't loaded, this is a no-op array append (harmless).
zvm_after_init_commands+=(_bind_history_keys)
