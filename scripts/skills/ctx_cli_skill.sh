#!/usr/bin/env bash
set -euo pipefail

# Minimal chat-facing wrapper to support two commands inside chat:
#   /ctx list
#   /ctx <workstream name>
#
# Prints results to stdout (so the agent pastes it), no clipboard side-effects.

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
CTX_CMD="$ROOT_DIR/scripts/ctx_cmd.py"

# Prefer ctx on PATH if available
if command -v ctx >/dev/null 2>&1; then
  INVOKE=(ctx)
else
  INVOKE=(python3 "$CTX_CMD")
fi

subcmd="${1:-}"

if [[ -z "$subcmd" || "$subcmd" == "help" ]]; then
  cat <<EOF
Usage:
  /ctx list                # show available workstreams
  /ctx <workstream name>   # resume that workstream (markdown pack)
EOF
  exit 0
fi

if [[ "$subcmd" == "list" ]]; then
  "${INVOKE[@]}" list
  exit 0
fi

# Treat the entire arg string as the workstream name
name="$*"
"${INVOKE[@]}" go "$name" --format markdown

