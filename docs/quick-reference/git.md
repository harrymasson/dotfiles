# Git Workflow

The goal is a fast, low-ceremony git workflow — stage and commit quickly for scripted flows, and use an interactive UI when you need to think (reviewing diffs, crafting commits, managing branches). This setup uses `lg` (lazygit) for anything interactive and a set of short aliases for everything else. Pull rebases by default; diffs go through `diff-so-fancy` for readable output.

---

## When to use lazygit vs aliases

**Use `lg` (lazygit) when:**
- Staging individual hunks rather than whole files
- Reviewing a diff carefully before committing
- Browsing commit history or comparing branches
- Interactive rebase
- Managing stashes

**Use aliases when:**
- You know exactly what you're doing and want one line
- Scripting or chaining commands
- Quick status checks or pushes mid-flow

---

## Starting with a repo

```bash
gcl <url>                    # git clone
gcl <url> <dir>              # clone into a specific directory

# Example
gcl git@github.com:user/repo.git
```

---

## Everyday flow

```bash
gst                          # status
gd                           # diff unstaged changes (diff-so-fancy output)
gd <file>                    # diff a specific file
gds                          # diff staged changes (what's about to be committed)
gaa                          # stage everything
ga <file>                    # stage a specific file
gcmsg "fix: thing"           # commit with message
gp                           # push
gl                           # pull (rebases by default)
```

`diff-so-fancy` makes diffs easier to read — changed words are highlighted inline rather than showing full line replacements. For side-by-side or word-level diffs, open `lg` and navigate to the file.

---

## Branching

```bash
gcb <name>      # create and switch to new branch
gco <branch>    # checkout existing branch
gswm            # switch to main
gb              # list local branches
gbD <name>      # force-delete a branch
```

---

## Log

```bash
glog            # oneline graph
glods           # graph with dates (good for seeing branch history)
glola           # graph, all branches
```

---

## Stashing

```bash
gsta            # stash (includes untracked: gstu)
gstp            # pop stash
gstl            # list stashes
```

For stash management beyond pop/list, `lg` → `s` is easier.

---

## WIP commits

Save in-progress work as a commit without leaving the branch:

```bash
gwip            # "wip" commit of everything staged+unstaged
gunwip          # undo the wip commit, restoring staged state
```

---

## Cleanup

```bash
gclean          # interactive clean of untracked files
gwipe           # hard reset + clean (destructive — loses all uncommitted work)
gpristine       # hard reset + clean including ignored files
```

---

## Lazygit (`lg`)

Open with `lg`. Key bindings:

| Key | Action |
|-----|--------|
| `space` | Stage / unstage file or hunk |
| `c` | Commit |
| `p` | Push |
| `P` | Pull |
| `b` | Branch menu |
| `s` | Stash |
| `e` | Open file in editor |
| `Enter` | Drill into a file to stage by hunk |
| `?` | Help |

---

## Gaps / future

- **git worktree** — `gwt*` aliases exist but no workflow is set up. Useful for reviewing a PR branch without disturbing your working tree.
- **delta** — installed alongside `diff-so-fancy`. Has inline word-diff and side-by-side mode; worth evaluating as a swap.
