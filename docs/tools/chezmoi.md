# Chezmoi Reference

Practical command reference for day-to-day use. For repo structure and workflow, see [structure](../getting-started/structure.md).

## Verifying what chezmoi manages

```bash
# List all managed files
chezmoi managed

# Show source file for a given destination
chezmoi source-path ~/.gitconfig

# Check if a file is in sync (empty output = in sync)
chezmoi diff ~/.gitconfig

# Show sync status of all managed files
# M = modified (drift), A = added, D = deleted
chezmoi status
```

## Checking for drift

```bash
# See all pending changes
chezmoi diff

# See changes for a specific file
chezmoi diff ~/.config/git/ignore

# Preview an apply without making changes
chezmoi apply --dry-run
chezmoi apply --dry-run ~/.gitconfig
```

## Applying changes

```bash
# Apply everything
chezmoi apply

# Apply a single file (safe, incremental)
chezmoi apply ~/.gitconfig

# Apply a directory
chezmoi apply ~/.config/zsh/
```

## Editing source files

```bash
# Open the source file for a destination in $EDITOR
chezmoi edit ~/.gitconfig

# Edit and immediately apply
chezmoi edit --apply ~/.gitconfig
```

## Adding new files

```bash
# Import a live file into chezmoi management
chezmoi add ~/.config/newapp/config.yaml
# Creates: home/dot_config/newapp/config.yaml

# Add and make it a template
chezmoi add --template ~/.gitconfig
```

## Navigation

```bash
# Go to the chezmoi source directory
cd $(chezmoi source-path)

# Print the source directory path
chezmoi source-path

# Print where chezmoi would put a source file
chezmoi target-path home/dot_gitconfig
```

## Scripts

### Verifying scripts before applying

```bash
# Preview the rendered output of a template script
# (confirms template variables like Brewfile hash are substituted correctly)
chezmoi execute-template < home/run_onchange_after_install-brew-bundle.sh.tmpl

# Dry run — shows which scripts would run without executing them
chezmoi apply -n -v

# See what's already been recorded as run
chezmoi state dump
```

### Triggering re-runs

| Script type | Re-runs when… |
|---|---|
| `run_once_` | Content changes (edit the script) |
| `run_onchange_` | Content changes (edit script or its embedded hashes) |
| `run_` | Every `chezmoi apply` |

To force a specific script to re-run, either change something in its content (e.g. bump a comment) or reset all script state:

```bash
chezmoi state reset   # clears all run_once_ / run_onchange_ history
```

### Scripts in this repo

| Source file | When | Purpose |
|---|---|---|
| `run_once_after_install-oh-my-tmux.sh` | Once, after dotfiles | Clone oh-my-tmux to `~/.tmux/`, symlink `~/.tmux.conf` |
| `run_onchange_after_install-brew-bundle.sh.tmpl` | When Brewfile changes | `brew bundle install` from `Brewfile` |

The brew bundle script embeds a hash of `Brewfile` as a comment. When you add or remove packages in `Brewfile`, the hash changes, the script content changes, and chezmoi automatically re-runs it on the next `chezmoi apply`.

## Troubleshooting

```bash
# Health check — reports on config, tools, and issues
chezmoi doctor

# Show the computed config chezmoi is using
chezmoi dump-config

# Show what chezmoi knows about a specific file
chezmoi managed --include=files | grep gitconfig
```

## Source directory layout

```
~/.local/share/chezmoi/       # Repo root
├── .chezmoiroot              # Tells chezmoi to use home/ as source root
├── home/                     # Maps to ~/  ← chezmoi source root
│   ├── dot_gitconfig         → ~/.gitconfig
│   ├── dot_config/           → ~/.config/
│   └── private_dot_ssh/      → ~/.ssh/ (mode 0700)
├── docs/                     # Documentation (not managed by chezmoi)
└── reference/                # Reference configs (not managed by chezmoi)
```

Files outside `home/` are invisible to chezmoi — enforced by `.chezmoiroot`.
