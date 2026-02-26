#!/usr/bin/env bash
# test-czm-multi.sh
#
# Sandbox test for the chezmoi multi-context wrappers (czp/czw/cza/czx/czm).
# Creates a fully isolated experiment directory — never touches real ~/.
#
# Usage: bash /tmp/test-czm-multi.sh

set -euo pipefail

PERSONAL_REPO_URL="https://github.com/harrymasson/dotfiles.git"

# The wrapper lives in the chezmoi source tree; fall back to the local clone
# of this repo so the test works even before chezmoi apply has been run.
WRAPPER_SCRIPT="$HOME/.config/shell/chezmoi-multi.zsh"
if [ ! -f "$WRAPPER_SCRIPT" ]; then
  # Try to locate it via the local dotfiles clone (two directories up from here)
  DOTFILES_LOCAL="$(git -C "$(dirname "$0")" rev-parse --show-toplevel 2>/dev/null || true)"
  if [ -z "$DOTFILES_LOCAL" ] || [ ! -d "$DOTFILES_LOCAL" ]; then
    # Fall back: use the known local path where the repo lives
    DOTFILES_LOCAL="$HOME/code/dotfiles"
  fi
  WRAPPER_SCRIPT="$DOTFILES_LOCAL/home/dot_config/shell/chezmoi-multi.zsh"
fi

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
pass_count=0
fail_count=0

pass() { echo "  [PASS] $*"; (( pass_count += 1 )) || true; }
fail() { echo "  [FAIL] $*" >&2; (( fail_count += 1 )) || true; }

section() {
  echo ""
  echo "━━━ $* ━━━"
}

assert_file_exists() {
  local f="$1"
  if [ -f "$f" ]; then
    pass "file exists: ${f#"$EXPERIMENT_DIR/"}"
  else
    fail "expected file missing: ${f#"$EXPERIMENT_DIR/"}"
  fi
}

assert_cmd_succeeds() {
  local label="$1"; shift
  if "$@" >/dev/null 2>&1; then
    pass "$label"
  else
    fail "$label (expected success, got failure)"
  fi
}

assert_cmd_fails() {
  local label="$1"; shift
  if "$@" >/dev/null 2>&1; then
    fail "$label (expected failure, got success)"
  else
    pass "$label"
  fi
}

# ---------------------------------------------------------------------------
# Pre-flight
# ---------------------------------------------------------------------------
section "Pre-flight checks"

command -v chezmoi >/dev/null || { echo "FATAL: chezmoi not found"; exit 1; }
echo "  chezmoi: $(chezmoi --version 2>&1 | head -1)"

[ -f "$WRAPPER_SCRIPT" ] || { echo "FATAL: wrapper not found at $WRAPPER_SCRIPT"; exit 1; }
echo "  wrapper: $WRAPPER_SCRIPT"

# ---------------------------------------------------------------------------
# Create experiment directory
# ---------------------------------------------------------------------------
section "Setup"

EXPERIMENT_DIR="$(mktemp -d /tmp/czm-test.XXXXXX)"
echo "  EXPERIMENT_DIR: $EXPERIMENT_DIR"

mkdir -p \
  "$EXPERIMENT_DIR/personal-repo" \
  "$EXPERIMENT_DIR/work-src" \
  "$EXPERIMENT_DIR/fake-home" \
  "$EXPERIMENT_DIR/config/personal" \
  "$EXPERIMENT_DIR/config/work" \
  "$EXPERIMENT_DIR/cache/personal" \
  "$EXPERIMENT_DIR/cache/work" \
  "$EXPERIMENT_DIR/state"

# ---------------------------------------------------------------------------
# Clone personal dotfiles repo (shallow)
# ---------------------------------------------------------------------------
echo "  Cloning personal dotfiles (shallow)…"
git clone --depth=1 --quiet "$PERSONAL_REPO_URL" "$EXPERIMENT_DIR/personal-repo" 2>&1
echo "  Clone complete: $EXPERIMENT_DIR/personal-repo"
echo "  .chezmoiroot: $(cat "$EXPERIMENT_DIR/personal-repo/.chezmoiroot" 2>/dev/null || echo '(not found)')"

# ---------------------------------------------------------------------------
# Create minimal work repo (plain directory, no .chezmoiroot needed)
# Files placed here map directly to CZ_DEST like regular chezmoi sources
# ---------------------------------------------------------------------------
echo "  Creating work source directory…"
# Work owns a unique work-only file (non-overlapping)
cat > "$EXPERIMENT_DIR/work-src/dot_gitconfig_work" <<'EOF'
# Work-specific git additions (managed by work context only)
[user]
  email = test@work.example.com
[core]
  autocrlf = false
EOF
echo "  Work source created: $EXPERIMENT_DIR/work-src"

# ---------------------------------------------------------------------------
# Wire up sandbox environment
# ---------------------------------------------------------------------------
section "Environment"

export CZ_DEST="$EXPERIMENT_DIR/fake-home"
export CZP_SOURCE="$EXPERIMENT_DIR/personal-repo"  # .chezmoiroot → home/ subdir
export CZW_SOURCE="$EXPERIMENT_DIR/work-src"
export CZP_CONFIG="$EXPERIMENT_DIR/config/personal/chezmoi.toml"
export CZW_CONFIG="$EXPERIMENT_DIR/config/work/chezmoi.toml"
export CZP_CACHE="$EXPERIMENT_DIR/cache/personal"
export CZW_CACHE="$EXPERIMENT_DIR/cache/work"
export CZP_STATE="$EXPERIMENT_DIR/state/personal-state.boltdb"
export CZW_STATE="$EXPERIMENT_DIR/state/work-state.boltdb"

# Use full managed-intersection for the overlap checks (more thorough than critical-list)
export CZA_OVERLAP_MODE="managed-intersection"
export CZA_DEBUG=0

# Personal config — supply all template data used by home/dot_gitconfig.tmpl
cat > "$CZP_CONFIG" <<EOF
sourceDir = "$CZP_SOURCE"
cacheDir  = "$CZP_CACHE"
persistentState = "$CZP_STATE"

[data]
  machineType = "personal"
  username    = "testuser"
  gitName     = "Test User"
  gitEmail    = "test@personal.example.com"
EOF

# Work config
cat > "$CZW_CONFIG" <<EOF
sourceDir = "$CZW_SOURCE"
cacheDir  = "$CZW_CACHE"
persistentState = "$CZW_STATE"
EOF

echo "  CZ_DEST    = $CZ_DEST"
echo "  CZP_SOURCE = $CZP_SOURCE  (uses .chezmoiroot → home/)"
echo "  CZW_SOURCE = $CZW_SOURCE  (root = source root, no .chezmoiroot)"
echo "  CZP_CONFIG = $CZP_CONFIG"
echo "  CZW_CONFIG = $CZW_CONFIG"

# ---------------------------------------------------------------------------
# Load wrapper functions into this shell
# ---------------------------------------------------------------------------
# shellcheck source=/dev/null
source "$WRAPPER_SCRIPT"

echo ""
echo "  czm paths output:"
czm paths | sed 's/^/    /'

# Baseline: what does each context think it manages?
echo ""
echo "  Personal managed files:"
czp managed 2>/dev/null | head -10 | sed 's/^/    /'
echo "  Work managed files:"
czw managed 2>/dev/null | head -10 | sed 's/^/    /'

# ============================================================================
section "TEST 1 — Happy path: no overlapping files"
# ============================================================================
# Personal: manages .gitconfig, .vimrc, .zshenv, conf.d/*, etc.
# Work:     manages .gitconfig_work only
# Expected: no overlap, apply succeeds, both files land in fake-home

echo ""
echo "  [1a] Overlap check should pass (managed-intersection mode)…"
assert_cmd_succeeds "cz-overlap-check reports clean" cz-overlap-check

echo "  [1b] cza apply (excluding scripts to avoid brew/mise/tmux installs)…"
assert_cmd_succeeds "cza apply --exclude scripts succeeds" \
  cza apply --exclude scripts

echo "  [1c] Personal-owned .gitconfig in fake-home…"
assert_file_exists "$EXPERIMENT_DIR/fake-home/.gitconfig"

echo "  [1d] Personal-owned .vimrc in fake-home…"
assert_file_exists "$EXPERIMENT_DIR/fake-home/.vimrc"

echo "  [1e] Work-owned .gitconfig_work in fake-home…"
assert_file_exists "$EXPERIMENT_DIR/fake-home/.gitconfig_work"

echo "  [1f] czx which — .gitconfig owned by personal…"
which_result="$(czx which "$EXPERIMENT_DIR/fake-home/.gitconfig" 2>/dev/null || true)"
if [ "$which_result" = "personal" ]; then
  pass "czx which .gitconfig → personal"
else
  fail "czx which .gitconfig → expected 'personal', got '${which_result:-<empty>}'"
fi

echo "  [1g] czx which — .gitconfig_work owned by work…"
which_result="$(czx which "$EXPERIMENT_DIR/fake-home/.gitconfig_work" 2>/dev/null || true)"
if [ "$which_result" = "work" ]; then
  pass "czx which .gitconfig_work → work"
else
  fail "czx which .gitconfig_work → expected 'work', got '${which_result:-<empty>}'"
fi

echo "  [1h] czm doctor passes…"
assert_cmd_succeeds "czm doctor passes" czm doctor

# ============================================================================
section "TEST 2 — Edge case: overlapping file in both contexts"
# ============================================================================
# Introduce an overlap: add dot_vimrc to work-src
# Personal already manages .vimrc via home/dot_vimrc
# Expected: overlap detected, cza apply blocked, czx which reports "both"

echo ""
echo "  [Setup] Planting dot_vimrc in work-src (intentional overlap with personal)…"
cat > "$EXPERIMENT_DIR/work-src/dot_vimrc" <<'EOF'
" Work-side vimrc stub (intentionally overlapping with personal — test only)
set nocompatible
EOF
echo "  dot_vimrc planted."

echo ""
echo "  [2a] cz-overlap-check should detect .vimrc conflict…"
if cz-overlap-check 2>/dev/null; then
  fail "cz-overlap-check should have reported overlap but returned success"
else
  pass "cz-overlap-check correctly detected overlap"
fi

echo "  [2b] cza apply should be blocked (overlap guard triggers)…"
if cza apply --exclude scripts 2>/dev/null; then
  fail "cza apply should have been blocked by overlap but succeeded"
else
  pass "cza apply correctly blocked before any writes"
fi

echo "  [2c] czx which .vimrc should report 'both'…"
which_result="$(czx which "$EXPERIMENT_DIR/fake-home/.vimrc" 2>/dev/null || true)"
if [ "$which_result" = "both" ]; then
  pass "czx which .vimrc → both"
else
  fail "czx which .vimrc → expected 'both', got '${which_result:-<empty>}'"
fi

# ============================================================================
section "TEST 3 — Recovery: removing overlap restores apply"
# ============================================================================

echo ""
echo "  [Setup] Removing dot_vimrc from work-src (fixing the overlap)…"
rm "$EXPERIMENT_DIR/work-src/dot_vimrc"
echo "  dot_vimrc removed."

echo "  [3a] cz-overlap-check should pass again…"
assert_cmd_succeeds "cz-overlap-check clean after removal" cz-overlap-check

echo "  [3b] cza apply should succeed again…"
assert_cmd_succeeds "cza apply succeeds after overlap removed" \
  cza apply --exclude scripts

echo "  [3c] .vimrc still owned by personal only…"
which_result="$(czx which "$EXPERIMENT_DIR/fake-home/.vimrc" 2>/dev/null || true)"
if [ "$which_result" = "personal" ]; then
  pass "czx which .vimrc → personal (after work overlap removed)"
else
  fail "czx which .vimrc → expected 'personal', got '${which_result:-<empty>}'"
fi

# ============================================================================
section "Summary"
# ============================================================================
echo ""
echo "  Tests passed: $pass_count"
echo "  Tests failed: $fail_count"
echo ""
echo "  Experiment dir (inspect manually):"
echo "    $EXPERIMENT_DIR"
echo ""
echo "  fake-home contents:"
find "$EXPERIMENT_DIR/fake-home" -not -type d | sort | sed "s|$EXPERIMENT_DIR/fake-home/||" | sed 's/^/    /'
echo ""
echo "  To clean up:"
echo "    rm -rf $EXPERIMENT_DIR"

if [ "$fail_count" -gt 0 ]; then
  exit 1
fi
