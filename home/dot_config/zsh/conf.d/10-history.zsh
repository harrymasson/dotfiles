# ~/.config/zsh/conf.d/10-history.zsh
# Purpose: Shell history configuration.
# Source: chezmoi: home/dot_config/zsh/conf.d/10-history.zsh

HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt inc_append_history share_history hist_ignore_dups hist_reduce_blanks
