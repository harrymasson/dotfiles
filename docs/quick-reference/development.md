# Development

The goal is a consistent, low-friction environment for jumping between projects in different languages — without manually switching runtime versions or worrying about global tool pollution. mise handles runtime versions automatically based on project config. uv handles Python packages. npm handles Node packages. Docker wraps anything that needs more isolation.

**What's wired in:** mise (Node + Python version management), uv (Python packages + venvs), npm aliases, Docker Compose aliases, VS Code.

---

## Runtime versions with mise

mise activates automatically when you enter a directory that has a `.mise.toml`. No manual `use` needed mid-session.

### Where versions are defined

mise looks up the directory tree for config, in this order:

1. `.mise.toml` in the current directory
2. `.mise.toml` in each parent directory
3. Global `~/.config/mise/config.toml` (source: `home/dot_config/mise/config.toml`)

The global config sets the fallback — currently Node 22, Python 3.14. Project `.mise.toml` files override it for that directory tree.

### Check what's active

```bash
mise current            # show active versions in this directory
node --version          # confirm the binary version
python --version
```

`mise current` output shows the source of each version (global config vs a specific `.mise.toml`):
```
node    22.16.0  ~/.config/mise/config.toml
python  3.14.0   ~/projects/myapp/.mise.toml
```

### Confirm mise is intercepting the binary

```bash
which node              # should show a path under ~/.local/share/mise/shims/
which python
```

If `which node` shows `/usr/local/bin/node` or a brew path instead of a mise shims path, mise isn't active in that shell.

### Install global CLI tools

Global CLI tools are separate from runtime versions:

```bash
# Node global tools (installed into mise's node, not system node)
npm install -g typescript
npm install -g pnpm

# Python global CLI tools — use uv tool, not pip install -g
uv tool install ruff
uv tool install httpie
```

`uv tool install` is the pipx replacement — installs into an isolated env, exposes the binary globally.

---

## Starting a new project

### New Node project

```bash
cd ~/projects/new-thing
mise use node@22            # pins version, writes .mise.toml
npm init -y                 # or: pnpm init
git add .mise.toml          # commit so anyone with mise gets the same version
```

### New Python project

```bash
cd ~/projects/new-thing
mise use python@3.14        # pins version, writes .mise.toml
uv venv .venv               # create virtualenv using mise's Python
source .venv/bin/activate   # activate
uv pip install <package>    # add deps
git add .mise.toml          # commit runtime pin
# .venv stays in .gitignore
```

---

## Jumping into an existing project

```bash
gcl <repo-url>
cd <project>
mise install                # install the pinned runtime versions from .mise.toml
npm install                 # or: uv sync / uv pip install -r requirements.txt
```

mise handles the runtime; the language-specific tool handles packages.

---

## mise files vs language-specific files

| File | Owns | Always commit? |
|------|------|----------------|
| `.mise.toml` | Runtime version (node, python) | Yes |
| `package.json` | npm packages, scripts, metadata | Yes |
| `pyproject.toml` / `requirements.txt` | Python packages, project metadata | Yes |
| `.venv/` | Virtualenv | No (gitignore) |

The split: mise owns the *interpreter*, standard tooling owns everything else. Don't put package lists in `.mise.toml`.

For workspace-level commands that span multiple packages, use mise tasks (`[tasks]` in the root `.mise.toml`) — they're available anywhere in the directory tree:

```toml
# root .mise.toml
[tools]
node = "22"

[tasks.build]
run = "npm run build --workspaces"

[tasks.test]
run = "npm test --workspaces"
```

---

## Multi-package workspace pattern

```
my-workspace/
├── .mise.toml          # runtime version + workspace tasks (mise owns this)
├── package.json        # npm workspace config (lists workspaces)
├── packages/
│   ├── api/
│   │   └── package.json   # per-package deps + scripts
│   └── web/
│       └── package.json
```

- Root `.mise.toml` — runtime version only; workspace-wide mise tasks optional
- Root `package.json` — npm workspace definition
- Per-package `package.json` — package-specific deps and scripts
- Don't duplicate the node version in per-package files; let the root `.mise.toml` own it

Same pattern for Python with uv workspaces:

```
my-workspace/
├── .mise.toml          # python version
├── pyproject.toml      # uv workspace config
├── packages/
│   ├── core/
│   │   └── pyproject.toml
│   └── api/
│       └── pyproject.toml
```

---

## Node / npm aliases

```bash
npmrd       # npm run dev
npmrb       # npm run build
npmt        # npm test
npmst       # npm start
npmL0       # npm ls --depth=0 (top-level deps only)
npmE        # puts local node_modules/.bin on PATH (for running unlisted scripts)
```

---

## Python (uv)

```bash
uv venv .venv                       # create a venv
source .venv/bin/activate           # activate
uv pip install -r requirements.txt  # install from lockfile
uv pip install <package>            # add a package
uv sync                             # sync from pyproject.toml (if using uv projects)
```

---

## Docker / Compose

```bash
dcupd       # docker-compose up -d (detached)
dcupdb      # up -d --build (rebuild images first)
dcl         # logs
dclf        # follow logs
dcdn        # docker-compose down
dxcit <container> bash    # exec into a running container
```

---

## Editor

```bash
code .      # open VS Code in current directory
vscn        # new VS Code window
```

`$EDITOR` is set to `nano` for chezmoi edits. Change to `nvim` in `00-core.zsh` if you want LazyVim there instead.
