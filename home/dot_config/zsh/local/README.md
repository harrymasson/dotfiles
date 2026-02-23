# ~/.config/zsh/local/

Machine-specific zsh config that is NOT committed to git.

## Load order

| Location | When sourced |
|---|---|
| `local/before/*.zsh` | Before zinit and plugins |
| `local/*.zsh` | After conf.d modules, before starship |
| `local/after/*.zsh` | After starship init |

## Common uses

- `before/` — env vars or PATH needed before plugins load, credential setup
- `*.zsh` — machine-specific aliases, overrides to conf.d settings
- `after/` — work overlay plugins (`zinit light …`), final overrides

## Naming convention

Files within each directory are sourced in glob order, so prefix with numbers if order matters:

```
local/
  before/
    10-work-env.zsh    # work credentials, early PATH
  paths.zsh            # extra PATH entries
  aliases.zsh          # machine-specific aliases
  after/
    10-work-plugins.zsh  # extra zinit plugins
```
