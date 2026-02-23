# Zsh Reference

Config source: `home/dot_config/zsh/`.

## Loading chain

```
~/.zshenv                        # ZDOTDIR stub only
~/.config/zsh/.zshenv            # PATH, env vars (runs for all shells)
~/.config/zsh/.zprofile          # brew shellenv (login shells only)
~/.config/zsh/.zshrc             # zinit + conf.d loader (interactive shells)
~/.config/zsh/conf.d/*.zsh       # modules loaded in numeric order
~/.config/zsh/local/*.zsh        # machine-specific overrides (not in git)
```

## Plugin manager: zinit

Zinit loads plugins and OMZ snippets without the full OMZ framework:

```bash
# Core plugins
zsh-users/zsh-autosuggestions    # inline suggestions as you type
zsh-users/zsh-completions        # extra completion definitions
jeffreytse/zsh-vi-mode           # vi keybindings (layered over emacs base)
zdharma-continuum/fast-syntax-highlighting

# OMZ plugin snippets
OMZP::git        # git aliases
OMZP::aliases    # general aliases
zoxide           # frecent directory jumping — init'd in conf.d/90-ui.zsh (replaces autojump)
OMZP::aws        # AWS profile switching
OMZP::docker     # docker completions
OMZP::npm        # npm aliases
OMZP::web-search # search from terminal
```

## Key aliases

```bash
# Modern CLI replacements
ls   → eza -l --group-directories-first
ll   → eza -la --group-directories-first
cat  → bat --paging=never
grep → rg

# Git
lg   → lazygit

# Tmux — see tmux.md for full list
ta, tn, tl, tk, to, tds
```

## Shell options

```bash
auto_cd          # type a directory name to cd into it
auto_pushd       # cd pushes to directory stack
pushd_ignore_dups
```

Vi mode is active (via `zsh-vi-mode`). Emacs bindings (`bindkey -e`) are set as base, then vi-mode layers on top.

## Profiling startup time

```bash
ZSH_PROFILE_STARTUP=1 zsh -i -c exit
```

Prints a breakdown of what's taking time. Use this after adding plugins or aliases.

## Agentic IDE mode

When `$TERM_PROGRAM == "kiro"`, the shell skips zinit, plugins, and starship — loading only `00-core`, `10-history`, `41-mise`, and local overrides. This prevents terminal output parsing issues in AI coding tools.

## Suppressing login messages

`~/.hushlogin` (empty file) suppresses the "last logged in" message shown at login. Managed in chezmoi as `home/empty_dot_hushlogin` — the `empty_` prefix is required because chezmoi treats a zero-byte source file without it as a deletion instruction.

## Machine-specific config

Drop files in `~/.config/zsh/local/` — they're sourced last and never committed. Typical use: work aliases, machine-specific paths, secrets.
