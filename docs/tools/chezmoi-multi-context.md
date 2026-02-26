# Chezmoi Multi-Context Workflow

This repo includes a shell wrapper that runs **two independent chezmoi contexts** against the same destination home directory:

- `czp` = personal context
- `czw` = work context
- `cz` = default alias to `czp`
- `cza` = orchestrator for both contexts
- `czx` = smart helper commands (`edit`, `which`)
- `czm` = diagnostics (`paths`, `doctor`)

## Why this exists

The goal is to keep personal and work source repos fully isolated while preserving normal chezmoi usage:

- `czp add ~/.zshrc`
- `czw add ~/.gitconfig.work.local`
- `cza apply` (apply personal then work)

Each context uses its own config, source dir, cache, and persistent state database.

## Wrapper location and loading

- Wrapper file: `home/dot_config/shell/chezmoi-multi.zsh` → `~/.config/shell/chezmoi-multi.zsh`
- Loader module: `home/dot_config/zsh/conf.d/42-chezmoi-multi.zsh`

Zsh loads the wrapper automatically via the normal `conf.d` chain.

## Context isolation model

The wrappers call `command chezmoi` with explicit path flags for each context:

- `--config`
- `--source`
- `--cache`
- `--persistent-state`
- `--destination`

Both contexts share `CZ_DEST` (default `$HOME`) and are otherwise isolated.

## Environment variables

All paths and behavior toggles are configurable:

- `CZP_CONFIG`, `CZW_CONFIG`
- `CZP_SOURCE`, `CZW_SOURCE`
- `CZP_CACHE`, `CZW_CACHE`
- `CZP_STATE`, `CZW_STATE`
- `CZ_DEST`
- `CZA_VERIFY_AFTER_APPLY` (`0` or `1`)
- `CZA_OVERLAP_MODE` (`critical-list` or `managed-intersection`)
- `CZA_CRITICAL_TARGETS` (space-separated path list)
- `CZA_DEBUG` (`0` or `1`)

Use `czm paths` to print effective values.

## Overlap protection

Ownership overlap is blocked before multi-context apply/verify flows.

### Modes

1. `critical-list` (default):
   checks explicit critical targets from `CZA_CRITICAL_TARGETS`.
2. `managed-intersection`:
   compares the managed target lists from both contexts.

Run manually:

```bash
cz-overlap-check
```

If overlaps are detected, `cza apply` fails fast and prints conflicting paths.

## Ownership rules

Use strict non-overlapping ownership.

### Personal context owns base files

Examples:

- `~/.gitconfig`
- `~/.zshrc`
- `~/.ssh/config`

These can include optional work fragments.

### Work context owns only work fragments

Examples:

- `~/.gitconfig.work.local`
- `~/.zshrc.work.local`
- `~/.ssh/config.local`
- work-only files under `~/.config/company/`

### Forbidden overlap examples

- both contexts managing `~/.gitconfig`
- both contexts managing `~/.zshrc`
- both contexts managing `~/.ssh/config`

## Command reference

### Single-context wrappers

```bash
czp status
czp diff
czp apply
czp edit ~/.gitconfig

czw status
czw diff
czw apply
czw edit ~/.gitconfig.work.local
```

### Combined orchestrator (`cza`)

```bash
cza apply      # overlap check + apply personal then work
cza dry-run    # apply -n -v for personal then work
cza diff       # show personal then work diffs
cza status     # show personal then work status
cza verify     # overlap check + verify personal then work
```

### Smart helper (`czx`)

```bash
czx which ~/.gitconfig
czx edit ~/.gitconfig.work.local
```

`czx edit <target>` routes to `czp edit --apply` or `czw edit --apply` when exactly one context manages the target, and errors on overlap or unknown ownership.

### Diagnostics (`czm`)

```bash
czm paths
czm doctor
```

`czm doctor` verifies command availability, required paths, and overlap checks.


## Testing safely without touching your real config

You can test the wrappers in a fully isolated sandbox by overriding the wrapper environment variables before sourcing the script.

### Why this is safe

The wrapper always calls `chezmoi` with explicit context-specific paths for config, source, cache, persistent state, and destination. That means you can redirect all effects to temporary directories.

### Sandbox smoke test flow

```bash
# 1) Create a temporary test lab
TMP_CZ="$(mktemp -d)"
mkdir -p "$TMP_CZ"/{dest,personal-src,work-src,personal-config,work-config,.cache/chezmoi/{personal,work},.local/state/chezmoi}

# 2) Point wrapper vars at sandbox paths
export CZ_DEST="$TMP_CZ/dest"
export CZP_SOURCE="$TMP_CZ/personal-src"
export CZW_SOURCE="$TMP_CZ/work-src"
export CZP_CONFIG="$TMP_CZ/personal-config/chezmoi.toml"
export CZW_CONFIG="$TMP_CZ/work-config/chezmoi.toml"
export CZP_CACHE="$TMP_CZ/.cache/chezmoi/personal"
export CZW_CACHE="$TMP_CZ/.cache/chezmoi/work"
export CZP_STATE="$TMP_CZ/.local/state/chezmoi/personal-state.boltdb"
export CZW_STATE="$TMP_CZ/.local/state/chezmoi/work-state.boltdb"

# 3) Create minimal config files for both contexts
cat >"$CZP_CONFIG" <<EOF
sourceDir = "$CZP_SOURCE"
cacheDir = "$CZP_CACHE"
persistentState = "$CZP_STATE"
EOF

cat >"$CZW_CONFIG" <<EOF
sourceDir = "$CZW_SOURCE"
cacheDir = "$CZW_CACHE"
persistentState = "$CZW_STATE"
EOF

# 4) Load wrapper functions
source ~/.config/shell/chezmoi-multi.zsh

# 5) Verify active paths are sandboxed
czm paths
czm doctor

# 6) Use non-destructive checks first
cza dry-run
cza status
cza diff
```

### Overlap check test (intentional failure)

To verify overlap protection, intentionally create the same managed destination in both contexts and run:

```bash
cz-overlap-check
cza apply
```

Expected result: overlap is reported and apply fails before any writes to destination.

### Confidence ladder before real usage

1. `czm paths` confirms you are targeting sandbox paths.
2. `czm doctor` passes.
3. `cza dry-run` shows expected actions.
4. `cza status` and `cza diff` look correct.
5. Only then run `cza apply` against real paths.

## Recommended rollout

1. Start with `CZA_OVERLAP_MODE=critical-list`.
2. Keep strict ownership of base files in personal context.
3. Use `cza dry-run` and `cza status` before `cza apply`.
4. Move to `managed-intersection` once both contexts are stable.


## Future improvements

- Add `czm sandbox-init` to create a temporary sandbox and print export commands automatically.
- Add `czm selftest` to seed minimal personal/work test cases and assert expected results (including overlap failure cases).
- Add a lightweight CI shell test harness that stubs `chezmoi` output to validate routing and overlap logic without requiring a full chezmoi install.
- Add optional `cza` preflight checks for required directories and clearer remediation messages when config/source paths are missing.
- Add a concise copy/paste smoke-test block to onboarding docs so first-time setup validation is standardized.
