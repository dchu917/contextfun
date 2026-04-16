#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd -P)
TARGET_ROOT="$ROOT_DIR"
HOME_DIR="${HOME}"
PREFIX="${HOME_DIR}/.contextfun"
BIN_DIR="$PREFIX/bin"
CODEX_DIR="${CODEX_SKILLS_DIR:-$HOME_DIR/.codex/skills}"
CLAUDE_DIR="${CLAUDE_SKILLS_DIR:-$HOME_DIR/.claude/skills}"

DO_LOCAL=true
DO_GLOBAL=false
DO_AGENT_LOCAL=false

usage() {
  cat <<EOF
Usage: $0 [--global] [--agent-local] [--all] [--root <path>] [--codex-dir <path>] [--claude-dir <path>]

Without flags, removes the repo-backed local setup for this clone:
  - ./.contextfun
  - ./ctx.env
  - linked skills that point at this repo
  - ~/.contextfun/bin/ctx when it is the repo-backed shim for this clone

Flags:
  --global       Remove the shared ~/.contextfun install and linked self-contained skills.
  --agent-local  Remove ./ctx created by agent_setup_local_ctx.sh for the selected root.
  --all          Remove local setup, global install, and ./ctx agent-local runtime.
  --root <path>  Override the repo root to clean. Useful for tests or scripted cleanup.
  --codex-dir <path>
  --claude-dir <path>
EOF
}

resolve_existing_path() {
  local path="$1"
  [[ -e "$path" || -L "$path" ]] || return 1
  local dir base
  dir=$(cd "$(dirname "$path")" && pwd -P)
  base=$(basename "$path")
  printf "%s/%s\n" "$dir" "$base"
}

remove_exact_line() {
  local file="$1"
  local needle="$2"
  [[ -f "$file" ]] || return 0
  local tmp
  tmp=$(mktemp)
  grep -vxF "$needle" "$file" > "$tmp" || true
  if cmp -s "$file" "$tmp"; then
    rm -f "$tmp"
    return 0
  fi
  mv "$tmp" "$file"
}

remove_shell_exports_for_global() {
  local rc
  for rc in "$HOME_DIR/.zshrc" "$HOME_DIR/.bashrc" "$HOME_DIR/.profile"; do
    remove_exact_line "$rc" "export CONTEXTFUN_DB=\"$HOME_DIR/.contextfun/context.db\""
    remove_exact_line "$rc" "export PATH=\"$HOME_DIR/.contextfun/bin:\$PATH\""
  done
}

remove_repo_backed_shim_if_matching() {
  local shim="$BIN_DIR/ctx"
  [[ -f "$shim" ]] || return 0
  local shim_root resolved_shim_root resolved_target_root
  shim_root=$(awk -F'"' '/^ROOT_DIR=/{print $2; exit}' "$shim")
  resolved_shim_root=$(resolve_existing_path "$shim_root") || return 0
  resolved_target_root=$(resolve_existing_path "$TARGET_ROOT") || return 0
  if [[ "$resolved_shim_root" == "$resolved_target_root" ]] && grep -Fq 'scripts/ctx_cmd.py' "$shim"; then
    rm -f "$shim"
    echo "Removed repo-backed shim: $shim"
  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --global)
      DO_LOCAL=false
      DO_GLOBAL=true
      shift
      ;;
    --agent-local)
      DO_LOCAL=false
      DO_AGENT_LOCAL=true
      shift
      ;;
    --all)
      DO_LOCAL=true
      DO_GLOBAL=true
      DO_AGENT_LOCAL=true
      shift
      ;;
    --root)
      TARGET_ROOT=$(cd "$2" && pwd -P)
      shift 2
      ;;
    --codex-dir)
      CODEX_DIR="$2"
      shift 2
      ;;
    --claude-dir)
      CLAUDE_DIR="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown arg: $1" >&2
      exit 2
      ;;
  esac
done

if $DO_LOCAL; then
  echo "==> Removing repo-backed local setup from $TARGET_ROOT"
  rm -rf "$TARGET_ROOT/.contextfun" "$TARGET_ROOT/ctx.env"
  bash "$ROOT_DIR/scripts/uninstall_skills.sh" \
    --skills-root "$TARGET_ROOT/skills" \
    --codex-dir "$CODEX_DIR" \
    --claude-dir "$CLAUDE_DIR"
  remove_repo_backed_shim_if_matching
  echo "Local setup removed."
  echo "If you no longer need ~/.contextfun/bin on PATH, remove that line from your shell rc manually."
fi

if $DO_GLOBAL; then
  echo "==> Removing global install from $PREFIX"
  if [[ -d "$PREFIX/skills" ]]; then
    bash "$ROOT_DIR/scripts/uninstall_skills.sh" \
      --skills-root "$PREFIX/skills" \
      --codex-dir "$CODEX_DIR" \
      --claude-dir "$CLAUDE_DIR"
  fi
  rm -rf "$PREFIX"
  remove_shell_exports_for_global
  echo "Global install removed."
fi

if $DO_AGENT_LOCAL; then
  echo "==> Removing agent-local runtime from $TARGET_ROOT/ctx"
  rm -rf "$TARGET_ROOT/ctx"
  echo "Agent-local runtime removed. Open a new shell or run 'unset CONTEXTFUN_DB' if needed."
fi
