# Install on a Work Machine

Work machines run two independent chezmoi contexts side-by-side: the personal dotfiles repo and a work overlay repo. Both write to `~/` with no overlapping ownership.

See [Chezmoi Multi-Context](../tools/chezmoi-multi-context.md) for how the wrapper commands work after setup.

## Prerequisites

1. Install [Homebrew](https://brew.sh):
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

2. Install chezmoi:
   ```bash
   brew install chezmoi
   ```

3. SSH or HTTPS access to the work dotfiles repo.

---

## Step 1 — Bootstrap personal dotfiles to the expected path

The multi-context wrappers expect the personal source at `~/.local/share/chezmoi-personal`. Pass `--source` so chezmoi clones there instead of the default location:

```bash
chezmoi init \
  --source "$HOME/.local/share/chezmoi-personal" \
  --apply \
  https://github.com/harrymasson/dotfiles.git
```

When prompted:

| Prompt | Value |
|---|---|
| `Machine type (personal/work)` | `work` |
| `Local username` | your macOS username |
| `Git name` | your full name |
| `Git email` | your **personal** email — work email goes in `~/.config/git/local` (step 4) |

Setting `machineType = work` causes the SSH config template to skip the personal `github.com` host block.

This apply installs the wrapper infrastructure alongside all other personal dotfiles:

- `~/.config/shell/chezmoi-multi.zsh` — the `czp`/`czw`/`cza`/`czx`/`czm` commands
- `~/.config/chezmoi-personal/chezmoi.toml` — `czp` config, already points at `~/.local/share/chezmoi-personal`
- `~/.config/chezmoi-work/chezmoi.toml` — `czw` config, already points at `~/.local/share/chezmoi-work`

---

## Step 2 — Clone the work repo

```bash
git clone <work-repo-url> "$HOME/.local/share/chezmoi-work"
```

`~/.local/share/chezmoi-work` is the default `CZW_SOURCE` — no additional config needed.

---

## Step 3 — Install Homebrew packages and tool versions

```bash
brew bundle --file="$(dirname "$(chezmoi source-path chezmoi-personal)")/Brewfile"
mise install
```

---

## Step 4 — Reload the shell

```bash
exec zsh
```

The `conf.d/42-chezmoi-multi.zsh` module sources the wrapper automatically. All `czp`/`czw`/`cza`/`czx`/`czm` commands are now live.

---

## Step 5 — Verify and apply

```bash
czm paths     # confirm all paths point to the right places
czm doctor    # validate both contexts and run overlap check
cza dry-run   # preview what will change before writing anything
cza apply     # apply personal then work
```

---

## What the work repo can manage

The personal repo deliberately leaves these zones open. Work owns them — personal never touches them.

### Designated zones

| Path | Purpose | How the hook is opened |
|---|---|---|
| `~/.config/git/local` | Work git config: email, signing key, corp proxy | `~/.gitconfig` ends with `[include] path = ~/.config/git/local` |
| `~/.config/zsh/local/before/*.zsh` | Early env: work credentials, proxy vars, PATH additions | `.zshrc` sources this glob **before** zinit and plugins load |
| `~/.config/zsh/local/*.zsh` | Work aliases, conf.d overrides, tool initialisation | `.zshrc` sources this glob after all `conf.d/` modules |
| `~/.config/zsh/local/after/*.zsh` | Extra zinit plugins, final overrides | `.zshrc` sources this glob **after** starship init |
| `~/.config/<work-tool>/` | Any config directory not owned by personal | Independent — no conflict possible |

### Example work repo source layout

```
work-src/
├── private_dot_ssh/
│   └── config.local                 # ~/.ssh/config.local — work SSH hosts and keys
├── dot_config/
│   ├── git/
│   │   └── local                    # ~/.config/git/local — work git config
│   └── zsh/
│       └── local/
│           ├── before/
│           │   └── 10-work-env.zsh  # work credentials, proxy, early PATH
│           ├── aliases.zsh          # work-specific aliases
│           └── after/
│               └── 10-work-plugins.zsh  # extra zinit plugins
```

### Example `~/.config/git/local`

```ini
[user]
    email = you@company.com

[credential]
    helper = /usr/local/bin/corp-credential-helper
```

---

## What the work repo must NOT manage

These are owned by the personal context. Adding any of them to the work source will trigger overlap detection and block `cza apply`.

| Off-limits for work | Personal source file |
|---|---|
| `~/.gitconfig` | `home/dot_gitconfig.tmpl` |
| `~/.ssh/config` | `home/private_dot_ssh/config.tmpl` |
| `~/.vimrc` | `home/dot_vimrc` |
| `~/.zshenv` | `home/dot_zshenv` |
| `~/.config/zsh/.zshrc`, `.zshenv`, `.zprofile` | `home/dot_config/zsh/` |
| `~/.config/zsh/conf.d/*.zsh` | `home/dot_config/zsh/conf.d/` |
| `~/.config/nvim/` | `home/dot_config/nvim/` |
| `~/.config/starship.toml` | `home/dot_config/starship.toml` |
| `~/.config/shell/chezmoi-multi.zsh` | `home/dot_config/shell/chezmoi-multi.zsh` |

---

## SSH hosts for work

When `machineType = work`, `~/.ssh/config` includes `~/.ssh/config.local` (silently ignored if absent). The work repo manages this file at source path `private_dot_ssh/config.local`.

For SSH agent setup (env vars, `ssh-add` calls), use `~/.config/zsh/local/before/10-work-ssh.zsh`.
