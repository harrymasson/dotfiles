# Sessions & Multitasking (Tmux)

The goal is persistent, named workspaces that survive terminal closes and disconnects, and let you context-switch between projects without losing your place. A session keeps running when you close the terminal or detach — you come back to exactly where you left off. Multiple sessions let you keep separate contexts live simultaneously and jump between them instantly.

**What's configured:** oh-my-tmux with `C-a` prefix, intuitive split bindings, mouse on, Catppuccin Mocha theme.

**Mental model:** sessions = projects · windows = tasks within a project · panes = views within a task

---

## Sessions

### Starting and attaching

```bash
ts               # fzf picker — fuzzy select from all existing sessions
ts <name>        # attach-or-create by name (same as `to`)
to <name>        # attach-or-create (alias; use ts if you don't know the name)
tds              # create/attach a session named after the current directory
tn <name>        # new session (errors if name already exists)
tl               # list all sessions
ta <name>        # attach to an existing session
tk <name>        # kill a named session
```

`ts` is the main entry point when opening a new terminal — it shows a live list of sessions with window counts and attached/detached state. `to`/`ts <name>` are idempotent: if the session exists you land in it; if not, it's created.

### Naming conventions

Keep session names short, lowercase, no spaces — use `-` for multi-word names:

```
dotfiles        work-api        web-app         scratch
```

Use `tds` for throwaway or exploratory sessions where the directory name is enough. Use explicit names (`to work-api`) for anything you'll return to across days.

### Inside tmux — session controls

| Key | Action |
|---|---|
| `C-a d` | Detach (session keeps running) |
| `C-a $` | Rename current session |
| `C-a s` | Session + window tree — navigate and jump anywhere |
| `C-a (` / `C-a )` | Previous / next session |
| `C-a L` | Switch to last (previously active) session |

`C-a s` is the main navigation tool once you have multiple sessions — shows a tree you can expand to see windows, then `Enter` to jump directly.

---

## Windows

| Key | Action |
|---|---|
| `C-a c` | New window |
| `C-a ,` | Rename current window |
| `C-a w` | Visual window picker (across all sessions) |
| `C-a n` / `C-a p` | Next / previous window |
| `C-a 0`–`9` | Jump to window by number |
| `C-a &` | Kill current window (confirms) |

Name windows after what they're running: `editor`, `server`, `logs`, `shell`. The status bar shows window names — good names make the bar useful.

---

## Panes (splits)

| Key | Action |
|---|---|
| `C-a \|` | Vertical split (side by side) |
| `C-a -` | Horizontal split (stacked) |
| `C-a arrow` | Move between panes |
| `C-a z` | Zoom pane to full screen / unzoom |
| `C-a x` | Kill current pane |
| `C-a {` / `C-a }` | Swap pane left / right |

Both split bindings preserve the current directory. Mouse is on — click to focus, drag borders to resize.

**Common layout:** one pane for your editor → `C-a -` for a terminal strip below → `C-a z` to zoom the editor when you need more space.

---

## Copy / paste

tmux has its own copy mode with vi-style selection. Yanked text goes to the macOS clipboard (`tmux_conf_copy_to_os_clipboard=true`), so `Cmd-v` works anywhere after copying.

### Enter / exit copy mode

| Key | Action |
|---|---|
| `C-a [` | Enter copy mode |
| `q` or `Escape` | Exit without copying |

### Navigate (vi keys)

`h/j/k/l`, `w/b`, `Ctrl-u/d`, `g` (top) / `G` (bottom)

### Select and copy

| Key | Action |
|---|---|
| `v` | Start visual selection |
| `V` | Select whole line |
| `Ctrl-v` | Rectangle/block select |
| `y` | Yank selection → clipboard, exit copy mode |
| `Enter` | Also copies and exits |

### Paste

| Key | Action |
|---|---|
| `C-a ]` | Paste from tmux buffer (within tmux) |
| `Cmd-v` | Paste from macOS clipboard (anywhere) |

---

## Cheat sheet

```
# Shell
ts               fzf session picker
ts <name>        attach-or-create by name
tl               list sessions
tk <name>        kill session

# Sessions
C-a d            detach
C-a s            session/window tree
C-a ( )          prev/next session
C-a L            last session
C-a $            rename session

# Windows
C-a c            new window
C-a ,            rename window
C-a w            window picker
C-a n / p        next/prev window
C-a 0-9          jump to window

# Panes
C-a |            vertical split
C-a -            horizontal split
C-a arrow        move between panes
C-a z            zoom/unzoom
C-a x            kill pane
```

---

## Session persistence

Sessions are automatically saved every 15 minutes by **tmux-continuum** and restored when tmux starts. Manual controls via **tmux-resurrect**:

| Key | Action |
|---|---|
| `C-a C-s` | Save current session state now |
| `C-a C-r` | Restore last saved state |

What's saved: windows, panes, layout, working directories, and running programs (where possible).

---

## Future improvements

- **tmux-sessionx** — fuzzy session switcher with previews; a richer alternative to `C-a s`.
- **tmux-fzf** — general fzf integration for windows, panes, and commands inside tmux.
