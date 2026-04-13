#!/usr/bin/env bash
set -euo pipefail

# Copies all text from the frontmost app (Cmd+A, Cmd+C) and ingests it
# into the current workstream's latest session using contextfun.
# Requires: Give Terminal/iTerm/Raycast Accessibility permission.

FORMAT=${FORMAT:-markdown}
SOURCE=${SOURCE:-auto}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --format) FORMAT="$2"; shift 2;;
    --source) SOURCE="$2"; shift 2;;
    *) echo "Unknown arg: $1"; exit 2;;
  esac
done

# Trigger copy in the frontmost app
osascript -e 'tell application "System Events" to keystroke "a" using {command down}'
osascript -e 'tell application "System Events" to keystroke "c" using {command down}'

# Ingest from clipboard
export CONTEXTFUN_DB="${CONTEXTFUN_DB:-$HOME/.contextfun/context.db}"
export PATH="$HOME/.contextfun/bin:$PATH"

pbpaste | python3 -m contextfun ingest --file - --format "$FORMAT" --source "$SOURCE"

echo "Copied frontmost app and ingested into CTX ($FORMAT, source=$SOURCE)."

