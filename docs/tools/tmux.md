# Tmux Reference

Tmux is managed via [oh-my-tmux](https://github.com/gpakosz/.tmux) with a local override file at `~/.tmux.conf.local` (source: `home/dot_tmux.conf.local`).

For workflow — sessions, windows, panes, navigation — see [Sessions & Multitasking](../quick-reference/sessions.md).

## Custom key bindings

Prefix is `C-a` (changed from default `C-b`).

Bindings added or changed from oh-my-tmux defaults:

| Binding | Action |
|---------|--------|
| `C-a \|` | Split pane vertically (keeps current path) |
| `C-a -` | Split pane horizontally (keeps current path) |
| `C-a c` | New window (keeps current path) |
| `C-a e` | Edit `~/.tmux.conf.local` |
| `C-a r` | Reload config |
| `C-a S` | fzf session switcher (direct, no menu) |
| `C-a W` | fzf window switcher (direct, no menu) |
| `C-a F` | tmux-fzf full menu — new/rename/kill/panes/commands |

Mouse is enabled. Window auto-rename is disabled (`allow-rename off`).

When tmux captures mouse events, use `Shift` to pass the click through to the terminal. For link opening in terminals like Windows Terminal, use `Shift+Cmd/Ctrl+Click`.

## Shell aliases

From `conf.d/20-aliases.zsh` and `conf.d/45-tmux.zsh`:

| Alias | Description |
|-------|-------------|
| `ts` | fzf session picker — use this from outside tmux to attach. `ts <name>` attaches-or-creates by name |
| `to <name>` | Attach-or-create named session (no picker) |
| `tds` | Attach-or-create session named after current directory |
| `ta <name>` | Attach to an existing named session |
| `tn <name>` | New named session (errors if already exists) |
| `tl` | List all sessions |
| `tk <name>` | Kill a named session |
| `tad <name>` | Attach, detaching any other clients first |
| `tksv` | Kill the tmux server (all sessions) |
| `tmuxconf` | Open `~/.tmux.conf.local` in `$EDITOR` |

`ts` vs `C-a S`: `ts` is for attaching from a new terminal window (outside tmux). `C-a S` is for switching sessions from within an existing tmux session.

## Plugins (TPM)

Plugins are managed with [TPM](https://github.com/tmux-plugins/tpm), installed to `~/.tmux/plugins/tpm` by `run_once_after_install-tpm.sh`.

| Key | Action |
|-----|--------|
| `C-a I` | Install plugins listed in config |
| `C-a U` | Update all plugins |
| `C-a Alt-u` | Remove plugins no longer in config |

Installed plugins:

| Plugin | Key / trigger | Purpose |
|--------|---------------|---------|
| `tmux-yank` | `y` in copy mode | Robust yank to system clipboard |
| `tmux-resurrect` | `C-a C-s` / `C-a C-r` | Manual save and restore of sessions |
| `tmux-continuum` | automatic | Auto-saves every 15 min; restores on tmux start |
| `tmux-fzf` | `C-a F`, `C-a S`, `C-a W` | fzf picker for sessions, windows, panes, commands |

## Copy mode

Enter copy mode with `C-a [`. Uses vi keys.

| Key | Action |
|-----|--------|
| `v` | Start visual selection |
| `V` | Select whole line |
| `Ctrl-v` | Rectangle select |
| `y` | Yank to clipboard and exit |
| `q` / `Escape` | Exit without copying |

Yanked text goes to the macOS clipboard (`tmux_conf_copy_to_os_clipboard=true` + tmux-yank). Paste anywhere with `Cmd-v`, or within tmux with `C-a ]`.

## Clipboard & SSH

| Setting | Value | Effect |
|---------|-------|--------|
| `set-clipboard on` | on | OSC 52 passthrough — copy in remote tmux lands in local clipboard (requires Ghostty, which supports OSC 52) |
| `update-environment` | SSH vars | SSH agent socket stays fresh when reattaching to a long-lived session |

## Terminal / truecolor

```
default-terminal  tmux-256color
terminal-features *:RGB
```

Locks in truecolor for consistent Catppuccin rendering locally and over SSH. If colors look wrong on a remote host, the `tmux-256color` terminfo may be missing — see [Remote](../quick-reference/remote.md) for the fix.

## Theme

Catppuccin Mocha — dark blue/purple palette with Powerline separators. Requires a [Nerd Font](https://www.nerdfonts.com/) (configured: `Iosevka Nerd Font`).

Status bar: session name · uptime · prefix indicator · battery · time · date · username · hostname.

Visual selection highlight: Catppuccin blue (`#89b4fa`) on dark text — set via `mode-style`.

## Config files

| File | Purpose |
|------|---------|
| `~/.tmux.conf` | oh-my-tmux base (symlink to `~/.tmux/.tmux.conf`) |
| `~/.tmux.conf.local` | User overrides — edit this |
| `~/.tmux/plugins/` | TPM-managed plugins |

oh-my-tmux is installed by `run_once_after_install-oh-my-tmux.sh`. TPM is installed by `run_once_after_install-tpm.sh`. Both live in `~/.tmux/`.
