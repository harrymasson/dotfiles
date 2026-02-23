# mise Reference

[mise](https://mise.jdx.dev/) is a polyglot runtime version manager replacing both nvm and pyenv. Near-zero shell startup cost (shims vs hooks).

Global config: `~/.config/mise/config.toml` (source: `home/dot_config/mise/config.toml`).

Current global versions: Node 22, Python 3.14.

## Common commands

```bash
# See what's active in the current directory
mise current

# List all installed versions
mise ls

# Install everything declared in config files
mise install
```

## Set global versions

```bash
mise use --global node@22
mise use --global python@3.14
```

## Per-project versions

```bash
cd ~/my-project
mise use node@20        # writes .mise.toml in this dir
mise use python@3.11
```

Creates a `.mise.toml` at the project root — commit it so anyone with mise gets the same versions.

## Python workflow (mise + uv)

mise manages the interpreter; [uv](https://github.com/astral-sh/uv) manages packages and virtualenvs:

```bash
mise use python@3.14          # pin interpreter
uv venv .venv                 # create venv using mise's Python
uv pip install -r requirements.txt
```

## Quick reference vs old tools

| Task | nvm/pyenv | mise |
|------|-----------|------|
| Use a version | `nvm use 22` | `mise use node@22` |
| Install a version | `nvm install 22` | `mise install node@22` |
| Set global default | `nvm alias default 22` | `mise use --global node@22` |
| List installed | `nvm list` | `mise ls node` |
| Per-project | `.nvmrc` / `.python-version` | `.mise.toml` |
| Shell startup cost | ~500ms | ~5ms |
