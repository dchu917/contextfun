#!/usr/bin/env bash
set -euo pipefail

# Generates a pack for the given workstream and pastes it into the frontmost app.
# Usage: mac_paste_pack.sh "Workstream Name" [--format markdown|text] [--focus decision,todo] [--brief]

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <workstream-name> [--format markdown|text] [--focus types] [--brief]" >&2
  exit 2
fi

NAME="$1"; shift
FORMAT=markdown
FOCUS=""
BRIEF=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --format) FORMAT="$2"; shift 2;;
    --focus) FOCUS="$2"; shift 2;;
    --brief) BRIEF="--brief"; shift 1;;
    *) echo "Unknown arg: $1" >&2; exit 2;;
  esac
done

export CONTEXTFUN_DB="${CONTEXTFUN_DB:-$HOME/.contextfun/context.db}"
export PATH="$HOME/.contextfun/bin:$PATH"

# Ensure workstream, set current, and get pack
PACK=$(python3 scripts/ctx_cmd.py go "$NAME" --format "$FORMAT" ${FOCUS:+--focus "$FOCUS"} ${BRIEF:+--brief})

printf "%s" "$PACK" | pbcopy

# Paste into frontmost app
osascript -e 'tell application "System Events" to keystroke "v" using {command down}'

echo "Pasted pack for '$NAME' into frontmost app."

