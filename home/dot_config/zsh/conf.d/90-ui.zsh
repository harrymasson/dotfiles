# ~/.config/zsh/conf.d/90-ui.zsh
# Purpose: Terminal UI integrations — fzf, editor shell hooks.
# Source: chezmoi: home/dot_config/zsh/conf.d/90-ui.zsh
# Notes: Syntax highlighting (fast-syntax-highlighting) and prompt (starship)
#        are handled in .zshrc via zinit. This file loads after all plugins.

# fzf — fd-based commands for faster, gitignore-aware search
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'

# fzf — key bindings (brew) + completions (git-installed ~/.fzf.zsh)
if [[ -f "$(brew --prefix)/opt/fzf/shell/key-bindings.zsh" ]]; then
  source "$(brew --prefix)/opt/fzf/shell/key-bindings.zsh"
fi
[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh

# zoxide — smarter cd with frecency (replaces autojump)
(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"

# VS Code shell integration
[[ "$TERM_PROGRAM" == "vscode" ]] && . "$(code --locate-shell-integration-path zsh)"
