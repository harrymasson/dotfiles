# Getting Started

Set up on a new machine, understand how the repo is organised, and browse what's tracked.

- [Install on a new machine](install.md) — step-by-step bootstrap from scratch
- [Repo structure](structure.md) — how source files map to `~/`, chezmoi conventions, machine-specific config

## Security

Secrets are never committed. SSH private keys are generated per-machine. Work-specific config lives in a separate overlay repo. See the [security model](structure.md#security-model) for details.
