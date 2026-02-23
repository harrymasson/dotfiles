# Git Reference

Config source: `home/dot_gitconfig` and `home/dot_config/git/ignore`.

## Global config

| Setting | Value |
|---------|-------|
| Default branch | `main` |
| Pull strategy | `rebase` (not merge) |
| Diff pager | `diff-so-fancy` |
| LFS | enabled |

Work email is set via `~/.config/git/local` (not committed — include it in local overrides).

## Common commands

```bash
# Fuzzy interactive UI
lg                       # lazygit (alias)

# Status and diff
git status
git diff                 # pretty output via diff-so-fancy

# Stage and commit
git add <file>
git commit -m "message"

# Sync
git pull                 # rebases by default
git push
```

## Lazygit

`lg` opens [lazygit](https://github.com/jesseduffield/lazygit) — a terminal UI for git.

Key bindings inside lazygit:
- `space` — stage/unstage
- `c` — commit
- `p` — push
- `P` — pull
- `?` — help

## Global gitignore

`~/.config/git/ignore` (source: `home/dot_config/git/ignore`) — patterns applied to all repos.

Common entries: `.DS_Store`, `*.swp`, `.env`, IDE directories.

## Shell aliases

From `OMZP::git` (loaded via zinit):

| Alias | Command |
|-------|---------|
| `g` | `git` |
| `ga` | `git add` |
| `gc` | `git commit` |
| `gco` | `git checkout` |
| `gd` | `git diff` |
| `gl` | `git pull` |
| `gp` | `git push` |
| `gst` | `git status` |
| `glg` | `git log --graph` |

Full list: `alias | grep "^g"` or see the [OMZ git plugin](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/git).
