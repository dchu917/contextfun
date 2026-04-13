#!/usr/bin/env bash
set -euo pipefail

# Resolve repo root from this skill folder (…/skills/claude/ctx-list)
HERE="$(cd "$(dirname "$0")" && pwd)"
SKILL_DIR="$(cd "$HERE/../../.." && pwd)"  # points at repo root

if command -v ctx >/dev/null 2>&1; then
  INVOKE=(ctx)
else
  INVOKE=(python3 "$SKILL_DIR/scripts/ctx_cmd.py")
fi

subcmd="${1:-list}"
shift || true

if [[ "$subcmd" == "list" ]]; then
  "${INVOKE[@]}" list
else
  name="$subcmd${1:+ $*}"
  "${INVOKE[@]}" go "$name" --format markdown
fi

