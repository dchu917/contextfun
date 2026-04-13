#!/usr/bin/env bash
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
SKILL_DIR="$(cd "$HERE/../../.." && pwd)"

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

