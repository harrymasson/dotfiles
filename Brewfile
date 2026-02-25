# Brewfile — dotfile dependencies
# Packages required for these dotfiles to work correctly.
# This is NOT an exhaustive machine inventory — see reference/other_configs/
# for full brew lists per machine.
#
# Usage:
#   brew bundle          # install everything
#   brew bundle check    # verify all installed
#   brew bundle cleanup  # remove anything not listed (use with caution)
#
# Machine status (as of 2026-02):
#   macbook air  — all installed
#   mac mini     — needs: bat, eza, starship, font-iosevka-nerd-font

# ---------------------------------------------------------------------------
# Dotfile management
# ---------------------------------------------------------------------------

brew "chezmoi"        # manages this repo
brew "git"            # foundational vcs
brew "git-lfs"        # required by dot_gitconfig.tmpl filter config
brew "git-delta"      # diff displays (replaces diff-so-fancy)

# ---------------------------------------------------------------------------
# Shell
# ---------------------------------------------------------------------------

brew "starship"       # prompt — replaces p10k (dot_zshrc: eval starship init)
brew "fzf"            # fuzzy finder — key bindings sourced in dot_zshrc
brew "fd"             # fzf default/alt-c commands in conf.d/90-ui.zsh
brew "zoxide"         # directory jumping — init in conf.d/90-ui.zsh (replaces autojump)

# ---------------------------------------------------------------------------
# Editor
# ---------------------------------------------------------------------------

brew "neovim"         # dot_config/nvim/ (LazyVim config)
brew "vim"            # fallback editor (Vim license)

# ---------------------------------------------------------------------------
# CLI replacements (aliased in conf.d/20-aliases.zsh)
# ---------------------------------------------------------------------------

brew "eza"            # ls/ll aliases
brew "bat"            # cat alias (--paging=never)
brew "ripgrep"        # grep alias (rg)
brew "lazygit"        # lg alias
brew "diff-so-fancy"  # git pager — required by dot_gitconfig.tmpl core.pager

# ---------------------------------------------------------------------------
# CLI utilities
# ---------------------------------------------------------------------------

brew "jq"             # JSON processor
brew "dust"           # du replacement — visual disk usage (Apache-2.0)
brew "trash"          # safe rm — moves to Trash instead of deleting
brew "tlrc"           # tldr pages — community man page summaries
brew "has"            # checks if CLI tools are installed
brew "noti"           # send notification when a command finishes
brew "zsh-completions" # extra tab-completion definitions (MIT/Apache/BSD/ISC)

# ---------------------------------------------------------------------------
# Terminal multiplexer (aliases in conf.d/45-tmux.zsh)
# ---------------------------------------------------------------------------

brew "tmux"

# ---------------------------------------------------------------------------
# Containers
# ---------------------------------------------------------------------------

brew "docker-compose"  # Docker Compose (Apache-2.0)

# ---------------------------------------------------------------------------
# Language / runtime version managers
# ---------------------------------------------------------------------------

brew "mise"           # Python + Node version manager — replaces pyenv + nvm
brew "uv"             # Python package manager

# ---------------------------------------------------------------------------
# Terminal & fonts (casks)
# ---------------------------------------------------------------------------

cask "ghostty"
cask "font-iosevka-nerd-font"   # ghostty font-family setting

# ---------------------------------------------------------------------------
# Input customisation (casks)
# ---------------------------------------------------------------------------

cask "karabiner-elements"   # dot_config/private_karabiner/ config in dotfiles
