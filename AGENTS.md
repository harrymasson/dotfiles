# Agent Collaboration Guide

## Purpose

This document provides steering and context for AI coding assistants (Claude Code, Cursor, Codex, etc.) working on this dotfiles repository. It defines conventions, safety rules, and common workflows to ensure productive and safe collaboration.

## Repository Overview

This is a **chezmoi-managed dotfiles repository** that consolidates configurations from multiple machines into a unified, well-documented system. The repository is designed to:

- Support multiple machines with different configurations
- Separate personal and work-specific settings
- Provide comprehensive, searchable documentation
- Enable AI-assisted maintenance and evolution

## Directory Structure

```
~/.local/share/chezmoi/          # Chezmoi source directory
├── README.md                    # User-facing overview
├── PLAN.md                      # Implementation plan and roadmap
├── AGENTS.md                    # This file
├── mkdocs.yml                   # Documentation site configuration
│
├── docs/                        # Human and agent documentation
│   ├── index.yaml              # Machine-readable navigation index
│   ├── overview.md
│   ├── inventory.md            # Complete list of managed files
│   ├── security.md             # Secrets and sensitive data rules
│   ├── agents.md               # Extended agent guide
│   ├── machines.md             # Machine-specific differences
│   ├── bootstrap.md            # Setup instructions
│   └── skills/                 # Task-specific runbooks
│       ├── _template/          # Template for new skills
│       ├── zsh/
│       ├── tmux/
│       └── ...
│
├── .chezmoidata/               # Machine-specific data
│   └── machines/               # Per-machine configuration data
│
├── scripts/                    # Automation and helpers
│   ├── bootstrap_macos.sh
│   ├── doctor.sh
│   └── ingest.sh
│
├── home/                       # Dotfiles source (maps to ~/)
│   ├── dot_zshenv
│   ├── dot_config/
│   │   ├── zsh/
│   │   │   ├── conf.d/        # Modular shell config
│   │   │   └── local/         # Machine-local (NOT in git)
│   │   ├── tmux/
│   │   └── ...
│   └── private_dot_ssh/
│
└── reference/                  # Reference materials (read-only)
    └── chat_transcripts/
```

## File Naming Conventions

Chezmoi uses special prefixes in source file names:

- `dot_` → becomes `.` (e.g., `dot_zshrc` → `~/.zshrc`)
- `private_` → removes group/world permissions
- `executable_` → makes file executable
- `run_once_` → script runs only once per content hash
- `*.tmpl` → template file (processed with chezmoi template engine)

## Critical Safety Rules

### 1. Never Delete Without Explicit Permission

**ALWAYS:**
- Ask before deleting any file
- Prefer renaming over deletion (e.g., `file.bak`)
- Keep backups of original configurations
- Document why something is being removed

**EXCEPTION:** You may clean up temporary files or obvious duplicates if clearly noted.

### 2. Secrets and Sensitive Data

**NEVER commit:**
- SSH private keys (public keys are OK)
- API tokens or credentials
- Work-specific hostnames or internal DNS names
- Email addresses in plain files (use templates)

**ALWAYS:**
- Use `.chezmoiignore` for sensitive files
- Put secrets in `local/` directories (not managed by git)
- Use chezmoi templates for machine-specific values
- Flag any potential secret exposure for user review

Files that should NEVER be in git:
- `~/.ssh/id_*` (private keys)
- `~/.aws/credentials`
- Any file containing passwords or tokens
- `~/.config/zsh/local/*.zsh` (machine-specific)
- `~/.ssh/config.local`

### 3. Work on Source State, Not Destination

**CORRECT workflow:**
```bash
cd $(chezmoi source-path)        # Work in source directory
chezmoi edit ~/.zshrc            # Edit via chezmoi
chezmoi diff                     # Preview changes
chezmoi apply                    # Apply to home directory
```

**INCORRECT workflow:**
```bash
vim ~/.zshrc                     # Don't edit destination directly
```

### 4. Verify Before Applying

Before running `chezmoi apply`:
1. Run `chezmoi diff` to see what will change
2. Review the diff for unexpected modifications
3. Check for potential secrets being added
4. Ensure file permissions are correct

After making changes:
1. Test in a new shell session
2. Run `scripts/doctor.sh` (when available)
3. Verify no functionality is broken

## Common Tasks

### Adding a New Configuration File

```bash
# From anywhere
chezmoi add ~/.config/newapp/config.yaml

# This creates home/dot_config/newapp/config.yaml
# in the chezmoi source directory
```

### Creating a Machine-Specific Template

```bash
# Edit with template syntax
chezmoi edit --apply ~/.gitconfig

# In the file, use:
{{- if eq .chezmoi.hostname "work-laptop" }}
[user]
    email = work@company.com
{{- else }}
[user]
    email = personal@gmail.com
{{- end }}
```

### Adding a New Zsh Module

1. Create file: `home/dot_config/zsh/conf.d/NN-name.zsh`
   - NN = two-digit prefix for load order
   - Name should be descriptive (e.g., `40-python.zsh`)

2. Add header comment:
```bash
# ~/.config/zsh/conf.d/NN-name.zsh
# Purpose: Brief description
# Source: chezmoi: home/dot_config/zsh/conf.d/NN-name.zsh
# Local overrides: ~/.config/zsh/local/name.zsh (if applicable)
```

3. Keep it focused on one concern
4. No secrets or machine-specific paths (use local/ for those)

### Adding or Editing Documentation

The sidebar is controlled by the `nav:` block in `mkdocs.yml` — **a new file will not appear in the nav unless it is added there**. The section `index.md` files are separate human-readable listings and must also be kept in sync.

**When adding a new page:**
1. Create the file in the correct section (see table below)
2. Add an entry to `mkdocs.yml` under the appropriate `nav:` section
3. Add a one-line entry to the section's `index.md`

**When renaming or moving a page:**
1. Rename/move the file
2. Update the path in `mkdocs.yml`
3. Update `index.md` in the affected section(s)
4. Update any cross-links in other docs files

**Section guide:**

| Path | Content type |
|---|---|
| `docs/quick-reference/` | Workflow how-tos — "how do I do X day-to-day" |
| `docs/tools/` | Per-tool reference — how the tool is configured in this repo |
| `docs/getting-started/` | Setup, install, onboarding |
| `docs/worklog/` | Historical change log — don't rewrite past entries |
| `docs/archive/` | Deprecated content kept for reference |

### Creating a New Skill

Copy the template:
```bash
cp -r docs/skills/_template docs/skills/newsystem
```

Fill in:
- `README.md` - What it is, boundaries, entrypoints
- `recipes.md` - Common tasks
- `verification.md` - How to test
- `troubleshooting.md` - Common issues
- `metadata.yaml` - Machine-readable metadata

## File Headers

Every major configuration file should have a header comment:

```bash
# ~/.config/zsh/conf.d/40-python.zsh
# Purpose: Python environment setup (mise, uv)
# Source: chezmoi: home/dot_config/zsh/conf.d/40-python.zsh
# Local overrides: ~/.config/zsh/local/python.zsh
# Notes: No credentials; uses mise for version management
```

This helps both humans and agents understand:
- What the file does
- Where to edit it (source path)
- Where machine-local overrides go
- Important constraints

## AI-Specific Guidance

### Navigation Strategy

1. **Start with the index**: Read `docs/index.yaml` to understand structure
2. **Check skills first**: Look in `docs/skills/` for relevant runbooks
3. **Use lexical search**: Prefer `rg` (ripgrep) over semantic search initially
4. **Follow entrypoints**: Trace from documented entrypoints, don't guess

### Information Gathering

**DO:**
- Read `docs/inventory.md` to understand what's managed
- Check `PLAN.md` for current phase and next steps
- Review relevant skill documentation before making changes
- Use `rg` to find all instances of a pattern

**DON'T:**
- Make assumptions about file locations
- Edit files without understanding the full system
- Skip reading documentation in favor of code exploration

### Making Changes

**Prefer:**
- Adding new files over modifying existing ones
- Creating new conf.d modules over editing .zshrc directly
- Using templates over hardcoding values
- Incremental changes with git commits

**Avoid:**
- Large refactors without approval
- Changing file structure without updating documentation
- Modifying .zshenv (keep it minimal)
- Adding heavy dependencies without discussion

### Testing Approach

After making changes:

```bash
# Preview what will change
chezmoi diff

# Apply changes
chezmoi apply

# Test in new shell
exec zsh

# Run health check (when available)
scripts/doctor.sh

# Check git status
git status

# If something breaks, revert
git checkout -- problematic-file
chezmoi apply
```

## Tool-Specific Notes

### For Claude Code

- Use the Task tool for exploratory work (Explore agent)
- Use TodoWrite to track multi-step changes
- Ask questions with AskUserQuestion when uncertain
- Respect .claude/settings.json permissions

### For Cursor

- Auto-run terminal commands is OFF for safety
- Use .cursorrules for project-specific guidance
- Always review terminal commands before executing
- Work in git branches for experimental changes

### For Codex

- This repo follows AGENTS.md conventions (layered by directory)
- Skills live in docs/skills/ (not .agents/skills/)
- Use read-only sandbox mode for exploration
- Escalate to workspace-write only when needed

## Common Patterns

### Zsh Configuration Loading Order

```
~/.zshenv (stub)
  → ~/.config/zsh/.zshenv (minimal env, no external commands)
    → ~/.config/zsh/.zprofile (login-only: brew, mise)
      → ~/.config/zsh/.zshrc (interactive: history, completion, prompt)
        → ~/.config/zsh/conf.d/*.zsh (in numerical order)
          → ~/.config/zsh/local/*.zsh (machine-specific, not in git)
```

### SSH Configuration

```
~/.ssh/config (managed)
  → Include ~/.ssh/config.local (not managed)
  → Include ~/.ssh/config.d/*.conf (managed)
```

### Git Configuration

```
~/.gitconfig (template)
  → [includeIf "gitdir:~/work/"]
      → ~/.config/git/work.inc (work overlay repo)
```

## Machine-Specific Handling

### Three Approaches (in order of preference)

1. **Templates with machine data**
   - Store facts in `.chezmoidata/machines/*.toml`
   - Use `{{ if eq .machine "laptop1" }}` in templates
   - Keep logic clear and documented

2. **Local includes**
   - Main file includes `local/` directory files
   - Local files are never committed
   - Document what should go in local

3. **Separate work overlay repository**
   - Personal repo stays clean
   - Work repo adds drop-in files
   - Applied in sequence: personal then work

## Workflow for Multi-Step Tasks

1. **Read PLAN.md** to understand current phase
2. **Update TodoWrite** with task breakdown
3. **Research** in docs/ and skills/ first
4. **Make changes** in chezmoi source
5. **Preview** with `chezmoi diff`
6. **Apply** with `chezmoi apply`
7. **Test** in new environment
8. **Commit** with clear message
9. **Update documentation** if structure changed
10. **Mark todo complete** and move to next task

## Questions and Uncertainties

When uncertain:

1. **Check documentation** first (docs/, PLAN.md, skills/)
2. **Search for precedent** using `rg`
3. **Ask the user** with specific options
4. **Propose a solution** with clear tradeoffs
5. **Document the decision** in appropriate docs

## Red Flags - Stop and Ask

Stop and ask the user if:

- You're about to delete multiple files
- You find what looks like a secret or credential
- A change would affect shell startup behavior significantly
- You're unsure which machine a config applies to
- Work and personal configurations might mix
- A script wants sudo or elevated permissions
- You need to install system packages

## Success Metrics

Good agent collaboration looks like:

- ✅ Changes are well-documented with clear commit messages
- ✅ No secrets accidentally committed
- ✅ Tests pass and shells start correctly
- ✅ Documentation stays synchronized with code
- ✅ User confirms before destructive operations
- ✅ Machine-specific logic is clear and maintainable

Poor agent collaboration looks like:

- ❌ Files deleted without asking
- ❌ Hardcoded values instead of templates
- ❌ Documentation out of sync
- ❌ Large unexplained refactors
- ❌ Secrets in git history
- ❌ Broken shell startup

## Additional Resources

- **Chezmoi docs**: https://www.chezmoi.io/
- **Project docs**: `mkdocs serve` (when set up)
- **Quick search**: `rg "pattern" docs/`
- **Skills**: `docs/skills/*/recipes.md`
- **Current plan**: `PLAN.md`

---

**Remember**: This repository represents a working development environment. Treat changes with the same care you would give to production code. When in doubt, ask first.

*This document is maintained collaboratively by humans and AI assistants. Updates should be committed with clear explanations.*
