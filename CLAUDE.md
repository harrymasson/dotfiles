# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Chezmoi-managed personal dotfiles for macOS. Source files live in `home/` and map to `~/` after chezmoi applies them. See `AGENTS.md` for the full agent collaboration guide — this file is a focused summary for Claude Code.

## Commands

```bash
# Documentation site (requires: pip install mkdocs-material)
make docs          # serve at http://127.0.0.1:8000
make docs-build    # build static site

# Chezmoi workflow
chezmoi diff       # preview what will change in ~/
chezmoi apply      # apply source → home directory
chezmoi status     # see what's drifted
chezmoi edit ~/.zshrc   # edit a managed file via chezmoi
exec zsh           # reload shell to test changes
```

There are no test commands; verification is done by applying with `chezmoi apply` and testing in a new shell with `exec zsh`.

## File Naming (chezmoi conventions)

| Source prefix | Result |
|---|---|
| `dot_` | `.` (e.g. `dot_zshrc` → `~/.zshrc`) |
| `private_` | removes group/world permissions |
| `executable_` | makes file executable |
| `run_once_` | script runs once per content hash |
| `*.tmpl` | processed as a Go template |

## Architecture

```
home/                        # maps to ~/
├── dot_zshenv               # zsh stub: redirects to ~/.config/zsh/
├── dot_config/
│   ├── zsh/
│   │   ├── .zshenv          # minimal env vars, no external commands
│   │   ├── .zprofile        # login-only (brew, mise init)
│   │   ├── .zshrc           # interactive shell setup
│   │   ├── conf.d/          # numbered modules, loaded in order
│   │   │   ├── 00-core.zsh
│   │   │   ├── 10-history.zsh
│   │   │   ├── 20-aliases.zsh
│   │   │   └── ...
│   │   └── local/           # machine-specific, NOT in git
│   ├── git/                 # git config fragments
│   ├── nvim/                # LazyVim config
│   ├── private_karabiner/   # Karabiner-Elements (personal machine; update device list on new machines)
│   ├── ghostty/             # terminal config
│   ├── tmux/                # oh-my-tmux overrides
│   ├── mise/                # runtime version manager
│   └── starship.toml        # shell prompt
├── dot_gitconfig            # global gitconfig (template)
├── dot_vimrc                # vim backup config (fzf rtp only)
└── dot_tmux.conf.local      # oh-my-tmux customisations
docs/                        # MkDocs documentation site
reference/                   # read-only reference materials
Brewfile                     # Homebrew packages
```

**Zsh load order:** `zshenv` → `zprofile` (login) → `zshrc` → `conf.d/*.zsh` (numeric order) → `local/*.zsh` (untracked)

**New zsh modules:** create `home/dot_config/zsh/conf.d/NN-name.zsh` with a two-digit prefix for load order. Keep each module focused on one concern.

## Key Safety Rules

- **Work in source, not destination.** Edit files under `home/` (or via `chezmoi edit`), never directly in `~/`.
- **Never commit secrets.** SSH private keys, API tokens, work hostnames, and `local/*.zsh` files must never be committed.
- **Preview before applying.** Always run `chezmoi diff` before `chezmoi apply`.
- **Ask before deleting** any file. Prefer renaming to `.bak` over deletion.
- **Stop and ask** if you encounter what looks like a credential, are about to affect shell startup significantly, or a script wants `sudo`.

## Editing Documentation

The docs site is driven by `mkdocs.yml` — **the `nav:` block there is the source of truth for the sidebar**, not the filesystem. Adding, renaming, or moving a page requires updating `mkdocs.yml` or it won't appear in the nav.

Each section also has an `index.md` that lists its pages with a one-line description. Update it whenever you add or remove a page in that section.

**What goes where:**

| Section | Purpose |
|---|---|
| `docs/quick-reference/` | Workflow-focused how-to guides ("how do I do X day-to-day") |
| `docs/tools/` | Per-tool reference — how it's configured here, not a general manual |
| `docs/getting-started/` | Setup, install, onboarding |
| `docs/worklog/` | Historical record of changes and decisions — don't edit past entries |
| `docs/archive/` | Deprecated content kept for reference |

**Checklist when adding a new docs page:**
1. Create the file in the right section
2. Add it to `mkdocs.yml` under `nav:`
3. Add it to the section's `index.md` with a one-line description

## Machine-Specific Config

Three mechanisms (in order of preference):
1. **Templates** — use `.chezmoidata/machines/*.toml` data with `{{ if eq .machine "name" }}` in `.tmpl` files
2. **Local includes** — machine files go in `local/` dirs (untracked); main files `source` them
3. **Work overlay repo** — work config in a separate repo applied on top of personal
