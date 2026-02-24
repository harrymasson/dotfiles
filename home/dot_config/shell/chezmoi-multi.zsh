# ~/.config/shell/chezmoi-multi.zsh
# Purpose: Multi-context chezmoi wrappers for personal/work source repos.
# Source: chezmoi: home/dot_config/shell/chezmoi-multi.zsh
# Local overrides: ~/.config/zsh/local/chezmoi-multi.zsh

# -----------------------------
# Configurable paths (defaults)
# -----------------------------
: "${CZP_CONFIG:=$HOME/.config/chezmoi-personal/chezmoi.toml}"
: "${CZW_CONFIG:=$HOME/.config/chezmoi-work/chezmoi.toml}"

: "${CZP_SOURCE:=$HOME/.local/share/chezmoi-personal}"
: "${CZW_SOURCE:=$HOME/.local/share/chezmoi-work}"

: "${CZP_CACHE:=$HOME/.cache/chezmoi/personal}"
: "${CZW_CACHE:=$HOME/.cache/chezmoi/work}"

: "${CZP_STATE:=$HOME/.local/state/chezmoi/personal-state.boltdb}"
: "${CZW_STATE:=$HOME/.local/state/chezmoi/work-state.boltdb}"

: "${CZ_DEST:=$HOME}"

# cza behavior toggles
: "${CZA_VERIFY_AFTER_APPLY:=0}"       # 1 to run verify after apply
: "${CZA_OVERLAP_MODE:=critical-list}" # critical-list | managed-intersection
: "${CZA_DEBUG:=0}"                    # 1 for debug logging

# Optional critical targets list for overlap check (space-separated)
: "${CZA_CRITICAL_TARGETS:=$HOME/.gitconfig $HOME/.zshrc $HOME/.ssh/config $HOME/.gitconfig.work.local $HOME/.zshrc.work.local $HOME/.ssh/config.work.local}"

# -----------------------------
# Internal utilities
# -----------------------------
__czm_log() {
  [ "$CZA_DEBUG" = "1" ] && printf '[chezmoi-multi] %s\n' "$*" >&2
  return 0
}

__czm_err() {
  printf '[chezmoi-multi] ERROR: %s\n' "$*" >&2
}

__czm_require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    __czm_err "required command not found: $1"
    return 1
  }
}

__czm_ensure_dirs() {
  mkdir -p "$(dirname "$CZP_CACHE")" "$(dirname "$CZW_CACHE")" \
    "$(dirname "$CZP_STATE")" "$(dirname "$CZW_STATE")" \
    "$CZP_CACHE" "$CZW_CACHE"
}

__czm_validate_contexts() {
  __czm_require_cmd chezmoi || return 1

  [ -f "$CZP_CONFIG" ] || { __czm_err "missing personal config: $CZP_CONFIG"; return 1; }
  [ -f "$CZW_CONFIG" ] || { __czm_err "missing work config: $CZW_CONFIG"; return 1; }

  [ -d "$CZP_SOURCE" ] || { __czm_err "missing personal source dir: $CZP_SOURCE"; return 1; }
  [ -d "$CZW_SOURCE" ] || { __czm_err "missing work source dir: $CZW_SOURCE"; return 1; }

  __czm_ensure_dirs || return 1
}

# Build a chezmoi command with explicit paths.
# Usage: __czm_run_ctx p status
__czm_run_ctx() {
  local ctx="$1"
  shift || true

  case "$ctx" in
    p|personal)
      command chezmoi \
        --config "$CZP_CONFIG" \
        --source "$CZP_SOURCE" \
        --cache "$CZP_CACHE" \
        --persistent-state "$CZP_STATE" \
        --destination "$CZ_DEST" \
        "$@"
      ;;
    w|work)
      command chezmoi \
        --config "$CZW_CONFIG" \
        --source "$CZW_SOURCE" \
        --cache "$CZW_CACHE" \
        --persistent-state "$CZW_STATE" \
        --destination "$CZ_DEST" \
        "$@"
      ;;
    *)
      __czm_err "unknown context: $ctx"
      return 2
      ;;
  esac
}

# Public wrappers
czp() { __czm_run_ctx p "$@"; }
czw() { __czm_run_ctx w "$@"; }

# Default context command (personal by default)
cz() { czp "$@"; }

# -----------------------------
# Overlap detection
# -----------------------------

# Best-effort parser for `chezmoi managed` output.
# We normalize by taking the last whitespace-delimited field on each line.
__czm_managed_targets() {
  local ctx="$1"
  __czm_run_ctx "$ctx" managed 2>/dev/null | awk '
    NF == 0 { next }
    { print $NF }
  ' | sort -u
}

__czm_overlap_check_critical() {
  local failed=0
  local t

  # shellcheck disable=SC2086
  for t in $CZA_CRITICAL_TARGETS; do
    local p=1
    local w=1
    czp managed "$t" >/dev/null 2>&1 && p=0
    czw managed "$t" >/dev/null 2>&1 && w=0
    if [ $p -eq 0 ] && [ $w -eq 0 ]; then
      printf '[chezmoi-multi] OVERLAP: both contexts manage %s\n' "$t" >&2
      failed=1
    fi
  done

  return $failed
}

__czm_overlap_check_managed_intersection() {
  local tmp1
  local tmp2
  local overlaps

  tmp1="$(mktemp "${TMPDIR:-/tmp}/czp-managed.XXXXXX")" || return 1
  tmp2="$(mktemp "${TMPDIR:-/tmp}/czw-managed.XXXXXX")" || {
    rm -f "$tmp1"
    return 1
  }

  __czm_managed_targets p >"$tmp1" || {
    rm -f "$tmp1" "$tmp2"
    return 1
  }

  __czm_managed_targets w >"$tmp2" || {
    rm -f "$tmp1" "$tmp2"
    return 1
  }

  overlaps="$(comm -12 "$tmp1" "$tmp2" || true)"
  rm -f "$tmp1" "$tmp2"

  if [ -n "$overlaps" ]; then
    printf '[chezmoi-multi] OVERLAP: managed targets in both contexts:\n' >&2
    printf '%s\n' "$overlaps" | sed 's/^/  - /' >&2
    return 1
  fi

  return 0
}

cz-overlap-check() {
  __czm_validate_contexts || return 1
  case "$CZA_OVERLAP_MODE" in
    critical-list) __czm_overlap_check_critical ;;
    managed-intersection) __czm_overlap_check_managed_intersection ;;
    *)
      __czm_err "unknown CZA_OVERLAP_MODE: $CZA_OVERLAP_MODE"
      return 2
      ;;
  esac
}

# -----------------------------
# Smart helper namespace: czx
# -----------------------------
czx() {
  local sub="${1:-}"
  shift || true

  case "$sub" in
    edit)
      local target="${1:-}"
      local p=1
      local w=1

      if [ -z "$target" ]; then
        __czm_err "usage: czx edit <target>"
        return 2
      fi

      czp managed "$target" >/dev/null 2>&1 && p=0
      czw managed "$target" >/dev/null 2>&1 && w=0

      if [ $p -eq 0 ] && [ $w -ne 0 ]; then
        __czm_log "routing edit to personal: $target"
        shift || true
        czp edit --apply "$target" "$@"
      elif [ $w -eq 0 ] && [ $p -ne 0 ]; then
        __czm_log "routing edit to work: $target"
        shift || true
        czw edit --apply "$target" "$@"
      elif [ $p -eq 0 ] && [ $w -eq 0 ]; then
        __czm_err "overlap detected: both contexts manage $target"
        return 1
      else
        __czm_err "neither context manages $target"
        printf 'Use one of:\n  czp add %s\n  czw add %s\n' "$target" "$target" >&2
        return 1
      fi
      ;;
    which)
      local target="${1:-}"
      local p=1
      local w=1

      if [ -z "$target" ]; then
        __czm_err "usage: czx which <target>"
        return 2
      fi

      czp managed "$target" >/dev/null 2>&1 && p=0
      czw managed "$target" >/dev/null 2>&1 && w=0

      if [ $p -eq 0 ] && [ $w -eq 0 ]; then
        echo "both"
      elif [ $p -eq 0 ]; then
        echo "personal"
      elif [ $w -eq 0 ]; then
        echo "work"
      else
        echo "none"
      fi
      ;;
    *)
      __czm_err "usage: czx <edit|which> ..."
      return 2
      ;;
  esac
}

# -----------------------------
# Meta helper namespace: czm
# -----------------------------
czm() {
  local sub="${1:-}"
  shift || true

  case "$sub" in
    paths)
      cat <<EOF2
CZP_CONFIG=$CZP_CONFIG
CZW_CONFIG=$CZW_CONFIG
CZP_SOURCE=$CZP_SOURCE
CZW_SOURCE=$CZW_SOURCE
CZP_CACHE=$CZP_CACHE
CZW_CACHE=$CZW_CACHE
CZP_STATE=$CZP_STATE
CZW_STATE=$CZW_STATE
CZ_DEST=$CZ_DEST
CZA_OVERLAP_MODE=$CZA_OVERLAP_MODE
CZA_VERIFY_AFTER_APPLY=$CZA_VERIFY_AFTER_APPLY
EOF2
      ;;
    doctor)
      __czm_validate_contexts || return 1
      echo "chezmoi: $(command -v chezmoi)"
      echo "contexts: OK"
      echo "running overlap check..."
      cz-overlap-check
      ;;
    *)
      __czm_err "usage: czm <paths|doctor>"
      return 2
      ;;
  esac
}

# -----------------------------
# Apply both / orchestrator: cza
# -----------------------------
cza() {
  local sub="${1:-apply}"
  if [ $# -gt 0 ]; then
    shift
  fi

  __czm_validate_contexts || return 1

  case "$sub" in
    apply)
      cz-overlap-check || return 1
      __czm_log "applying personal context"
      czp apply "$@" || return $?
      __czm_log "applying work context"
      czw apply "$@" || return $?
      if [ "$CZA_VERIFY_AFTER_APPLY" = "1" ]; then
        __czm_log "verifying personal + work contexts"
        czp verify || return $?
        czw verify || return $?
      fi
      ;;
    dry-run)
      cz-overlap-check || return 1
      czp apply -n -v "$@" || return $?
      czw apply -n -v "$@" || return $?
      ;;
    diff)
      echo "== personal =="
      czp diff "$@" || return $?
      echo
      echo "== work =="
      czw diff "$@" || return $?
      ;;
    status)
      echo "== personal =="
      czp status "$@" || return $?
      echo
      echo "== work =="
      czw status "$@" || return $?
      ;;
    verify)
      cz-overlap-check || return 1
      czp verify "$@" || return $?
      czw verify "$@" || return $?
      ;;
    cd)
      __czm_err "cza cd is ambiguous; use czp cd or czw cd"
      return 2
      ;;
    *)
      __czm_err "usage: cza [apply|dry-run|diff|status|verify] [chezmoi args...]"
      return 2
      ;;
  esac
}
