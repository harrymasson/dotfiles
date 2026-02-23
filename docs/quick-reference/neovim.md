# Neovim Workflow

Fast daily workflow for this LazyVim setup.

If you need config internals (where things are defined), see [Tools: Neovim](../tools/neovim.md).

## Start and open files

```bash
nvim                    # open Neovim
nvim .                  # open current project
nvim path/to/file       # open a specific file
```

## Learn the active keymaps quickly

- `<leader>` is the main prefix (Space in LazyVim defaults).
- Hit `<leader>` and pause to open which-key hints.
- `:Telescope keymaps` to fuzzy-search mappings.
- `:map` / `:nmap` to inspect currently loaded maps.

When unsure, start with which-key first instead of memorizing everything.

## Core IDE movement (the "don't get stuck" set)

If you only memorize a few keys, memorize these first:

| Action | Key |
|---|---|
| Toggle file explorer (Neo-tree) | `<leader>e` |
| Move focus to left/down/up/right window | `<C-h>` / `<C-j>` / `<C-k>` / `<C-l>` |
| Move from explorer back into code window | `<C-l>` (or whichever direction your code pane is in) |
| Previous/next buffer | `<S-h>` / `<S-l>` |
| Close current buffer | `<leader>bd` |
| Jump to definition / references | `gd` / `gr` |
| Go back / forward in jump list | `<C-o>` / `<C-i>` |
| Search across files (project grep) | `<leader>/` |
| Find files by name | `<leader><space>` |
| Toggle terminal | `<C-/>` |

This gives you an IDE-like movement model: files, symbols, jumps, buffers, and terminal.

## File and text navigation

- `<leader><space>` — find files (Telescope)
- `<leader>/` — live grep in project
- `gd` / `gr` — go to definition / references
- `gI` / `gy` — go to implementation / type definition (when LSP supports it)
- `]d` / `[d` — next / previous diagnostic
- `%` — jump matching pair

## File explorer (Neo-tree) workflow

- `<leader>e` — toggle explorer
- Use `j` / `k` to move, `l` or `<CR>` to open, `h` to collapse/go parent
- `a` add file/folder, `d` delete, `r` rename
- `s` open in horizontal split, `v` open in vertical split
- Once file is open, use `<C-h/j/k/l>` to move focus between explorer and editing windows

If you ever lose track of focus, tap `<C-l>` until you're back in the editor pane.

## Search and code intelligence

- `<leader>/` — project-wide text search
- `<leader><space>` — find files quickly by fuzzy name
- `*` / `#` — search current word forward/backward in the current file
- `n` / `N` — next/previous search match
- `gd` — jump to definition
- `gr` — show references
- `K` — hover docs/type info for symbol under cursor
- `<C-o>` — jump back after definition jumps

Typical loop:

1. Grep with `<leader>/`
2. Jump via `gd`
3. Read docs with `K`
4. Return with `<C-o>`

## Editing loop (recommended)

1. Find file with `<leader><space>`
2. Search symbol/text with `<leader>/` or `gr`
3. Make edits with normal-mode motions/operators
4. Format with `<leader>cf` (or `:Format` if configured)
5. Save with `:w`
6. Use `:wa` before running tests/build

## Window, tab, and buffer flow

- `<C-h/j/k/l>` — move between splits
- `<leader>bd` — delete current buffer
- `<S-h>` / `<S-l>` — previous/next buffer
- `<leader>wd` — close window
- `<leader>ww` — switch windows

Useful mental model:

- **Buffer** = open file in memory
- **Window** = viewport/split that displays a buffer

So, use `<S-h>/<S-l>` for file-to-file movement (buffers), and `<C-h/j/k/l>` for pane movement (windows).

## Terminal workflow

- `<C-/>` — toggle floating terminal
- In terminal mode, press `<C-/>` again to hide it
- Run quick commands (tests/lint/git) in the floating terminal, then jump back to code
- For longer-running tasks, use tmux panes and keep Neovim focused on editing

This is usually the fastest loop: edit in Neovim, execute in floating terminal, repeat.

(Use which-key to confirm exact labels in your current LazyVim version.)

## Plugin and tooling workflow

- `:Lazy` — plugin manager dashboard
- `:Lazy update` — pull updates
- `:Mason` — install/update LSP tooling
- `:checkhealth` — environment diagnostics

For plugin updates in this repo:

1. Run `:Lazy update`
2. Restart Neovim
3. Validate your normal workflow
4. Commit `lazy-lock.json` changes

## Obsidian workflow (configured)

Obsidian mappings are grouped under `<leader>o`:

- `<leader>oo` quick switch notes
- `<leader>os` search notes
- `<leader>on` new note
- `<leader>od` today's daily note
- `<leader>ob` backlinks

Visual mode helpers:

- `gl` link selected text
- `gL` link selection to a new note
- `ge` extract selection into new note

## Built-in help workflow (worth using daily)

- `:help {topic}` — open docs (`:help motion.txt`, `:help telescope`)
- `:h quickref` — compact Vim reference
- `:Tutor` — interactive basics
- `K` — context help/documentation on symbol under cursor (LSP/help)

A good habit: if you forget a command, use `:help` first, then add only high-value mappings to memory.
