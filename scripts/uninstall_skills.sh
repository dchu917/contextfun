#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd -P)
CODEX_DIR="${CODEX_SKILLS_DIR:-$HOME/.codex/skills}"
CLAUDE_DIR="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
SKILLS_ROOT="${CTX_SKILLS_ROOT:-$ROOT_DIR/skills}"

usage() {
  cat <<EOF
Usage: $0 [--skills-root <path>] [--codex-dir <path>] [--claude-dir <path>]

Remove linked ctx skills from the selected Codex/Claude skill directories,
but only when they point at the selected skills root.
EOF
}

resolve_path() {
  local path="$1"
  if [[ ! -e "$path" && ! -L "$path" ]]; then
    return 1
  fi
  local dir base
  dir=$(cd "$(dirname "$path")" && pwd -P)
  base=$(basename "$path")
  printf "%s/%s\n" "$dir" "$base"
}

remove_link_if_matches() {
  local dst="$1"
  local expected="$2"
  [[ -L "$dst" ]] || return 0

  local target resolved_dst resolved_expected
  target=$(readlink "$dst")
  case "$target" in
    /*) ;;
    *) target="$(cd "$(dirname "$dst")" && pwd -P)/$target" ;;
  esac

  resolved_dst=$(resolve_path "$target") || return 0
  resolved_expected=$(resolve_path "$expected") || return 0
  if [[ "$resolved_dst" == "$resolved_expected" ]]; then
    rm -f "$dst"
    echo "  - Removed $(basename "$dst")"
  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --skills-root) SKILLS_ROOT="$2"; shift 2 ;;
    --codex-dir) CODEX_DIR="$2"; shift 2 ;;
    --claude-dir) CLAUDE_DIR="$2"; shift 2 ;;
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

if [[ ! -d "$SKILLS_ROOT" ]]; then
  echo "Skills root not found: $SKILLS_ROOT" >&2
  exit 1
fi

echo "==> Removing linked skills from $SKILLS_ROOT"

if [[ -d "$CODEX_DIR" && -d "$SKILLS_ROOT/codex" ]]; then
  echo "[Codex] Target: $CODEX_DIR"
  for src in "$SKILLS_ROOT/codex"/*; do
    [[ -f "$src/SKILL.md" ]] || continue
    remove_link_if_matches "$CODEX_DIR/$(basename "$src")" "$src"
  done
fi

if [[ -d "$CLAUDE_DIR" && -d "$SKILLS_ROOT/claude" ]]; then
  echo "[Claude] Target: $CLAUDE_DIR"
  for src in "$SKILLS_ROOT/claude"/*; do
    [[ -f "$src/SKILL.md" ]] || continue
    remove_link_if_matches "$CLAUDE_DIR/$(basename "$src")" "$src"
  done
fi

echo "Done."
