#!/usr/bin/env bash
set -euo pipefail

# Resolve repo root from this skill folder (…/skills/claude/ctx-list)
HERE="$(cd "$(dirname "$0")" && pwd -P)"
# Try to locate repo root by walking up until scripts/ctx_cmd.py is found
SEARCH="$HERE"
REPO=""
for _ in 1 2 3 4 5 6 7 8; do
  CAND="$(cd "$SEARCH/.." && pwd -P)"
  if [[ -f "$CAND/scripts/ctx_cmd.py" ]]; then
    REPO="$CAND"
    break
  fi
  SEARCH="$CAND"
done

if command -v ctx >/dev/null 2>&1; then
  INVOKE=(ctx)
elif [[ -n "$REPO" ]]; then
  INVOKE=(python3 "$REPO/scripts/ctx_cmd.py")
else
  echo "ContextFun not found: install globally (ctx) or clone repo with scripts/ctx_cmd.py" >&2
  exit 2
fi

subcmd="${1:-list}"
shift || true

if [[ "$subcmd" == "list" ]]; then
  "${INVOKE[@]}" list
else
  name="$subcmd${1:+ $*}"
  "${INVOKE[@]}" go "$name" --format markdown
fi
