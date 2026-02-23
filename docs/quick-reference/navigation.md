# Navigation

The goal is to move around the filesystem and recall commands with as little friction as possible — without remembering exact paths or retyping long commands. The setup combines frecency-based directory jumping (zoxide), fuzzy search (fzf), inline shell suggestions, and modern `ls`/`cat` replacements that make output easier to scan.

---

## Listing files

`ls` is aliased to `eza` — coloured, grouped, with icons if the font supports it:

```bash
ls          # eza -l, grouped dirs first
ll          # eza -la (includes hidden)
lt          # sort by time (newest last)
lart        # sort by time (newest last, includes hidden)
ldot        # list only dotfiles
```

`cat` is aliased to `bat` — syntax-highlighted, no paging by default.

---

## Moving around

Type a directory name to `cd` into it — `auto_cd` is on. The directory stack is maintained automatically (`auto_pushd`):

```bash
dirs -v     # show directory stack with numbers
cd -2       # jump to stack entry 2
popd        # go back one
```

---

## Jumping to frecent directories

`z` uses [zoxide](https://github.com/ajeetdsouza/zoxide) — it learns from your navigation history and ranks by frecency (frequency + recency):

```bash
z proj          # jump to the highest-ranked directory matching "proj"
z proj work     # narrow with multiple terms
zi              # interactive fuzzy picker (uses fzf)
z -             # go back to previous directory
```

Zoxide builds its database automatically as you navigate. The more you visit a directory, the higher it ranks. Use `zi` when you want to browse matches before committing.

> **Future:** pass `--cmd cd` to `zoxide init zsh` so the regular `cd` command feeds the zoxide database, unifying the two. Currently `z` and `cd` are tracked separately.

---

## fzf shortcuts

These work anywhere in the terminal:

| Key | Action |
|-----|--------|
| `Ctrl+T` | Fuzzy-find a file and insert its path at the cursor |
| `Ctrl+R` | Fuzzy search command history |
| `Alt+C` | Fuzzy-find a directory and `cd` into it |
| `Tab` | Trigger fuzzy completion on a partial path |

fzf completion also works with commands: `kill <Tab>`, `ssh <Tab>`, `cd **<Tab>`.

> **Future:** set `FZF_DEFAULT_COMMAND` to `fd --type f --hidden --follow --exclude .git` so `Ctrl+T` uses fd instead of find — faster and respects `.gitignore`.

---

## Shell autocompletion

Two layers are active:

**Tab completion** — `zsh-completions` provides extra completion definitions for many CLI tools. Press `Tab` on any partial command, flag, or path to complete it. Press `Tab` again to cycle through options.

**Inline suggestions** — `zsh-autosuggestions` shows a greyed-out completion based on your history as you type. Accept the full suggestion with `→` (right arrow) or `End`. Accept the next word only with `Alt+→`.

---

## Command editing (vi mode)

`zsh-vi-mode` is active. After typing part of a command:

- **Normal mode**: press `Escape` to enter, then use `h`/`l` to move, `b`/`w` to jump words, `0`/`$` for line start/end, `dd` to clear the line
- **Back to insert**: `i`, `a`, or `A`
- The cursor changes shape to indicate mode (block = normal, bar = insert)

Standard emacs bindings (`Ctrl+A`, `Ctrl+E`, `Ctrl+W` etc.) also work in insert mode.

---

## Common places

```bash
cd-obs      # ~/Library/Mobile Documents/.../obsidian-vault
```

Add more in `~/.config/zsh/local/` — untracked, machine-specific shortcuts belong there.
