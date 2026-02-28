# ~/.config/zsh/conf.d/20-aliases.zsh
# Purpose: Personal aliases.
# Source: chezmoi: home/dot_config/zsh/conf.d/20-aliases.zsh
# Local overrides: ~/.config/zsh/local/aliases.zsh

# Modern CLI replacements
alias ls='eza -l --group-directories-first'
alias ll='eza -la --group-directories-first'
alias cat='bat --paging=never'
alias grep='rg'

# Git
alias lg="lazygit"

# Tmux (override OMZP::tmux defaults)
alias ta='tmux attach -t'
alias tn='tmux new -s'
alias tl='tmux ls'
alias tk='tmux kill-session -t'

# Chezmoi
alias cz='chezmoi'

# Misc
alias node-async="node --experimental-repl-await"
alias cd-obs="cd '$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/obsidian-vault'"
