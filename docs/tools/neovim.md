# Neovim (LazyVim) Reference

Neovim is configured with [LazyVim](https://www.lazyvim.org/) and plugin management is handled by [lazy.nvim](https://github.com/folke/lazy.nvim). Source path: `home/dot_config/nvim/`.

For day-to-day editor workflow, see [Quick Reference: Neovim](../quick-reference/neovim.md).

## Config layout

| Path | Purpose |
|---|---|
| `~/.config/nvim/init.lua` | Entry point (loads `config.lazy`) |
| `~/.config/nvim/lua/config/lazy.lua` | Bootstraps lazy.nvim, LazyVim, plugin import |
| `~/.config/nvim/lua/config/options.lua` | Editor options |
| `~/.config/nvim/lua/config/keymaps.lua` | Custom keymaps (in addition to LazyVim defaults) |
| `~/.config/nvim/lua/plugins/*.lua` | Plugin specs and overrides |
| `~/.config/nvim/lazy-lock.json` | Locked plugin commit versions |

## Startup model

- `init.lua` loads `config.lazy`.
- `config.lazy` bootstraps lazy.nvim if missing, then runs `require("lazy").setup(...)`.
- LazyVim is imported via `{ "LazyVim/LazyVim", import = "lazyvim.plugins" }`.
- Local plugins/overrides are loaded via `{ import = "plugins" }`.

This means your local plugin changes should generally go in `lua/plugins/*.lua`, not by editing LazyVim internals.

## Update and maintenance

Inside Neovim:

- `:Lazy` — open plugin manager UI
- `:Lazy update` — fetch plugin updates
- `:Lazy sync` — install/update/clean based on specs
- `:Lazy check` — check for updates
- `:Mason` — manage LSP/DAP/formatter binaries
- `:checkhealth` — run Neovim health checks

After confirming updates work, commit the updated `lazy-lock.json`.

## Key customizations in this repo

### Theme

- Colorscheme is set to `catppuccin` via `lua/plugins/colorscheme.lua`.

### Obsidian integration

`lua/plugins/obsidian.lua` enables `obsidian.nvim` for markdown files with:

- workspace: `~/Documents/vault-2025-07`
- telescope picker integration
- blink.cmp completion integration
- which-key group under `<leader>o`

Common mappings include:

- `<leader>oo` quick switch
- `<leader>os` search notes
- `<leader>on` new note
- `<leader>od` today
- `<leader>oO` open in Obsidian app

## Useful official docs

- LazyVim docs: <https://www.lazyvim.org/>
- LazyVim keymaps: <https://www.lazyvim.org/keymaps>
- lazy.nvim docs: <https://lazy.folke.io/>
- Neovim help quickstart: `:help quickref`

Tip: in Neovim, use `:help {topic}` and `K` over highlighted keywords to stay in-editor while learning.
