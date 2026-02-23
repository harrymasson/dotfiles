# Repository Structure

## Directory layout

```
~/.local/share/chezmoi/          # Chezmoi source directory
│
├── home/                        # Maps to ~/
│   ├── dot_zshenv               # ~/.zshenv (ZDOTDIR stub)
│   ├── dot_gitconfig            # ~/.gitconfig
│   ├── dot_tmux.conf.local      # ~/.tmux.conf.local (oh-my-tmux overrides)
│   └── dot_config/
│       ├── zsh/                 # ~/.config/zsh/
│       │   ├── dot_zshenv       # Universal env vars
│       │   ├── dot_zprofile     # Login shell (brew shellenv)
│       │   ├── dot_zshrc        # Interactive shell (zinit + conf.d loader)
│       │   ├── conf.d/          # Modular config loaded in order
│       │   └── local/           # Machine-specific overrides (not in git)
│       ├── tmux/
│       ├── mise/                # Global tool versions
│       ├── nvim/                # LazyVim config
│       ├── ghostty/             # Terminal + themes
│       └── starship.toml        # Prompt config
│
├── docs/                        # This documentation
├── Brewfile                     # Declarative package list
├── mkdocs.yml                   # Docs site config
└── .chezmoidata/machines/       # Per-machine variables (email, work flag, etc.)
```

## Chezmoi file naming

| Prefix | Effect | Example |
|--------|--------|---------|
| `dot_` | Becomes `.` | `dot_zshrc` → `~/.zshrc` |
| `private_` | Sets 0700 permissions | `private_dot_ssh` → `~/.ssh` |
| `executable_` | Sets +x | `executable_setup.sh` |
| `run_once_` | Runs once per content hash | `run_once_install-oh-my-tmux.sh` |
| `*.tmpl` | Processed as a Go template | `dot_gitconfig.tmpl` |

Files outside `home/` are invisible to chezmoi (enforced by `.chezmoiroot`).

## Zsh loading order

```
~/.zshenv                        # Stub: sets ZDOTDIR
  ↓
~/.config/zsh/.zshenv            # Universal env vars, PATH
  ↓
~/.config/zsh/.zprofile          # Login: brew shellenv
  ↓
~/.config/zsh/.zshrc             # Interactive: zinit + loads conf.d
  ↓
~/.config/zsh/conf.d/*.zsh       # Loaded in numeric order
  ↓
~/.config/zsh/local/*.zsh        # Machine-specific, not in git
```

## conf.d modules

| File | Purpose |
|------|---------|
| `00-core.zsh` | Editor, color, PATH, shell options |
| `10-history.zsh` | History settings |
| `20-aliases.zsh` | Command aliases |
| `40-python.zsh` | Python environment |
| `41-mise.zsh` | mise activation |
| `45-tmux.zsh` | Tmux aliases and helpers |
| `60-docker.zsh` | Docker placeholders |
| `90-ui.zsh` | Prompt and visual elements |

## Machine-specific handling

**Templates** — machine facts in `.chezmoidata/machines/<name>.toml`, used in `*.tmpl` files.

**Local includes** — `~/.config/zsh/local/*.zsh` for secrets/overrides that don't go in git.

**Work overlay** — a separate chezmoi repo applied on top for work-specific config.

## Security model

Never committed:
- SSH private keys (generated per-machine by `run_once_create-ssh-key.sh`)
- API tokens and credentials
- `local/` directory contents
- `~/.aws/credentials`

Safe to commit:
- SSH `config` (with `Include` for sensitive parts)
- Tool configurations (mise, tmux, starship, etc.)
- Shell scripts and aliases
