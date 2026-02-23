# ~/.config/zsh/conf.d/45-tmux.zsh
# Purpose: Tmux aliases and helpers. Replaces OMZP::tmux (which required
#          tmux.extra.conf not present in zinit's snippet cache).
# Source: chezmoi: home/dot_config/zsh/conf.d/45-tmux.zsh
# Notes: Core aliases (ta, tn, tl, tk) live in 20-aliases.zsh.

(( $+commands[tmux] )) || return

# Aliases not covered in 20-aliases.zsh
alias tad='tmux attach -d -t'                    # attach detached
alias to='tmux new-session -A -s'                # attach-or-create named session
alias tksv='tmux kill-server'                    # kill the tmux server
alias tmuxconf='$EDITOR ~/.tmux.conf.local'      # open local oh-my-tmux config

# Fuzzy-pick an existing session with fzf, or fall back to creating one by name.
# Use this from outside tmux to attach to a session.
# Inside tmux, prefer C-a S (tmux-fzf direct session switcher).
function ts() {
  if [[ -n "$1" ]]; then
    tmux new-session -A -s "$1"
    return
  fi
  local session
  session=$(tmux list-sessions -F '#{session_name}: #{session_windows}w — #{?session_attached,attached,detached}' 2>/dev/null \
    | fzf --height=40% --reverse --prompt='session> ' --with-nth=1 \
    | cut -d: -f1)
  [[ -n "$session" ]] && tmux new-session -A -s "$session"
}

# Directory session: attach or create a session named after the current directory.
# Uses a short MD5 suffix to avoid collisions between dirs with the same basename.
function tds() {
  local dir=${PWD##*/}
  local md5
  md5=$(printf '%s' "$PWD" | md5 -q 2>/dev/null || printf '%s' "$PWD" | md5sum | cut -d' ' -f1)
  tmux new-session -A -s "${dir}-${md5:0:6}"
}
