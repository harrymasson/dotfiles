# Install on a New Machine

## Prerequisites

1. Install [Homebrew](https://brew.sh):
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

2. Install chezmoi:
   ```bash
   brew install chezmoi
   ```

## Bootstrap

```bash
chezmoi init --apply https://github.com/harrymasson/dotfiles.git
```

During init, chezmoi will prompt:

```
Machine type (personal/work) [personal]:
```

Answer `personal` or `work` — this controls which config blocks are included (e.g. the GitHub SSH entry is personal-only). The answer is stored in `~/.config/chezmoi/chezmoi.toml` and never prompted again.

## After applying

```bash
# Install all Homebrew packages
brew bundle --file="$(chezmoi source-path)/Brewfile"

# Install tool versions (Node, Python via mise)
mise install

# Open a new shell to pick up the new config
exec zsh
```

## Health check

```bash
chezmoi doctor
```

Reports any config issues, missing tools, or file drift.

## Machine-specific config

The `personal`/`work` answer from init drives template conditions throughout the dotfiles. To change it later:

```bash
chezmoi init   # re-runs the prompt, updates ~/.config/chezmoi/chezmoi.toml
chezmoi apply  # re-applies templates with the new value
```

Local overrides that are never committed go in `~/.config/zsh/local/*.zsh`.
