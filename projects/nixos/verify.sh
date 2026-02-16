#!/usr/bin/env bash
set -euo pipefail

FLAKE_URI="${FLAKE_URI:-.}"
NIX_FLAGS="${NIX_FLAGS:-}"

DO_FMT=1
DO_VM=0
DO_FIX=0
DO_FIX_DEADNIX=0

log()  { printf "\033[1;34m[verify]\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m[verify]\033[0m %s\n" "$*"; }
err()  { printf "\033[1;31m[verify]\033[0m %s\n" "$*"; }

need_cmd() { command -v "$1" >/dev/null 2>&1; }

run() {
  # shellcheck disable=SC2086
  eval "$*"
}

usage() {
  cat <<'EOF'
Usage:
  ./scripts/verify.sh [--fix] [--fix-deadnix] [--build-vm] [--no-fmt]

Env:
  FLAKE_URI="."   Flake URI (default ".")
  HOSTS="a b"     Space-separated hostnames (default auto-detect nixosConfigurations)
  SYSTEM="..."    Override system (default builtins.currentSystem)
  NIX_FLAGS="..." Extra flags for nix

Flags:
  --fix           Auto-fix where possible (format, statix, optionally deadnix with --fix-deadnix)
  --fix-deadnix   Allow deadnix to edit files (more aggressive)
  --build-vm      Also build VM derivations
  --no-fmt        Skip formatting stage
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --no-fmt) DO_FMT=0; shift ;;
    --build-vm) DO_VM=1; shift ;;
    --fix) DO_FIX=1; shift ;;
    --fix-deadnix) DO_FIX_DEADNIX=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) err "Unknown arg: $1"; exit 2 ;;
  esac
done

if ! need_cmd nix; then
  err "nix is required."
  exit 1
fi

SYSTEM="${SYSTEM:-$(nix eval --raw --impure --expr 'builtins.currentSystem')}"
log "flake: ${FLAKE_URI}"
log "system: ${SYSTEM}"
[[ "${DO_FIX}" -eq 1 ]] && log "mode: FIX (will modify files)" || log "mode: CHECK (no modifications)"

# Detect hosts if HOSTS not provided
if [[ -z "${HOSTS:-}" ]]; then
  log "Detecting nixosConfigurations hosts…"
  HOSTS="$(
    nix eval --raw \
      "${FLAKE_URI}#nixosConfigurations" \
      --apply 'x: builtins.concatStringsSep "\n" (builtins.attrNames x)' \
      ${NIX_FLAGS}
  )"
  if [[ -z "${HOSTS}" ]]; then
    err "No nixosConfigurations found in flake outputs."
    exit 1
  fi
fi

log "hosts:"
printf "%s\n" "${HOSTS}" | sed 's/^/  - /'

# Ensure we can diff if we're in check mode (for formatting & "fix caused changes" messaging)
HAVE_GIT=0
if need_cmd git; then HAVE_GIT=1; fi

# Helper: does flake provide formatter for SYSTEM?
flake_has_formatter() {
  nix eval --raw "${FLAKE_URI}#formatter.${SYSTEM}" ${NIX_FLAGS} >/dev/null 2>&1
}

# Helper: run alejandra either via nix fmt (preferred) or nix run fallback
run_formatter() {
  if flake_has_formatter; then
    run "nix fmt ${FLAKE_URI} ${NIX_FLAGS}"
    return 0
  fi
  if nix run ${NIX_FLAGS} nixpkgs#alejandra -- --version >/dev/null 2>&1; then
    run "nix run ${NIX_FLAGS} nixpkgs#alejandra -- -q ."
    return 0
  fi
  return 1
}

# --- Stage 0: formatting ---
if [[ "${DO_FMT}" -eq 1 ]]; then
  log "Stage 0: formatting"

  if [[ "${DO_FIX}" -eq 1 ]]; then
    if run_formatter; then
      log "Formatted."
    else
      warn "No formatter available (flake formatter.${SYSTEM} missing and alejandra not runnable); skipping."
    fi
  else
    # CHECK mode: fail if formatting would change files
    if [[ "${HAVE_GIT}" -eq 0 ]]; then
      warn "git not found; cannot strict-check formatting. Consider running with --fix to apply formatting."
    else
      if ! git-dotfiles diff --quiet -- .; then
        warn "Working tree has changes; formatting check may be noisy."
      fi
      if run_formatter; then
        if ! git-dotfiles diff --quiet -- .; then
          err "Formatting changes detected. Re-run with --fix or run: nix fmt"
          git-dotfiles --no-pager diff -- . || true
          exit 1
        fi
        log "Formatting OK."
      else
        warn "No formatter available; skipping formatting check."
      fi
    fi
  fi
else
  warn "Skipping formatting stage (--no-fmt)."
fi

# --- Stage 1: lint ---
log "Stage 1: lint"

# statix
if nix run ${NIX_FLAGS} nixpkgs#statix -- --version >/dev/null 2>&1; then
  if [[ "${DO_FIX}" -eq 1 ]]; then
    log "statix: fixing"
    run "nix run ${NIX_FLAGS} nixpkgs#statix -- fix ${FLAKE_URI}"
    log "statix: checking"
    run "nix run ${NIX_FLAGS} nixpkgs#statix -- check ${FLAKE_URI}"
  else
    log "statix: checking"
    run "nix run ${NIX_FLAGS} nixpkgs#statix -- check ${FLAKE_URI}"
  fi
else
  warn "statix not available; skipping."
fi

# deadnix
if nix run ${NIX_FLAGS} nixpkgs#deadnix -- --version >/dev/null 2>&1; then
  if [[ "${DO_FIX}" -eq 1 && "${DO_FIX_DEADNIX}" -eq 1 ]]; then
    log "deadnix: editing (aggressive) because --fix-deadnix was provided"
    # deadnix can edit in-place; flag name can vary by version.
    # Try common ones; if none work, fall back to check only.
    if nix run ${NIX_FLAGS} nixpkgs#deadnix -- --help 2>&1 | grep -q -- '--edit'; then
      run "nix run ${NIX_FLAGS} nixpkgs#deadnix -- --edit ${FLAKE_URI}"
    elif nix run ${NIX_FLAGS} nixpkgs#deadnix -- --help 2>&1 | grep -q -- '--rewrite'; then
      run "nix run ${NIX_FLAGS} nixpkgs#deadnix -- --rewrite ${FLAKE_URI}"
    else
      warn "deadnix edit flag not found; running check only."
    fi
  fi
  log "deadnix: checking"
  run "nix run ${NIX_FLAGS} nixpkgs#deadnix -- ${FLAKE_URI}"
else
  warn "deadnix not available; skipping."
fi

log "Lint OK."

# --- Stage 2: flake eval ---
log "Stage 2: nix flake check --no-build (evaluation)"
run "nix flake check ${FLAKE_URI} --no-build ${NIX_FLAGS}"
log "Flake eval OK."

# --- Stage 3: build NixOS toplevel ---
log "Stage 3: build nixosConfigurations.<host>.config.system.build.toplevel"
while IFS= read -r host; do
  [[ -z "${host}" ]] && continue
  log "Building host: ${host}"
  run "nix build ${FLAKE_URI}#nixosConfigurations.${host}.config.system.build.toplevel ${NIX_FLAGS}"
done <<< "${HOSTS}"
log "Host builds OK."

# --- Stage 4: optional VM builds ---
if [[ "${DO_VM}" -eq 1 ]]; then
  log "Stage 4: build VM derivations"
  while IFS= read -r host; do
    [[ -z "${host}" ]] && continue
    log "Building VM for host: ${host}"
    if nix build "${FLAKE_URI}#nixosConfigurations.${host}.config.system.build.vm" ${NIX_FLAGS}; then
      :
    else
      warn "system.build.vm failed for ${host}, trying vmWithBootLoader"
      run "nix build ${FLAKE_URI}#nixosConfigurations.${host}.config.system.build.vmWithBootLoader ${NIX_FLAGS}"
    fi
  done <<< "${HOSTS}"
  log "VM builds OK."
else
  log "Skipping VM build stage (pass --build-vm to enable)."
fi

# In FIX mode, it’s helpful to show if the fixer made changes.
if [[ "${DO_FIX}" -eq 1 && "${HAVE_GIT}" -eq 1 ]]; then
  if ! git-dotfiles diff --quiet -- .; then
    warn "Auto-fix made changes. Review with: git diff"
  else
    log "No changes were necessary."
  fi
fi

log "All stages passed ✅"

