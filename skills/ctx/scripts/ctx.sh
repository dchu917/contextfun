#!/usr/bin/env bash
set -euo pipefail

if command -v ctx >/dev/null 2>&1; then
  exec ctx "$@"
fi

echo "ctx is not installed. Run ./setup.sh in the repo or use the global installer from https://github.com/dchu917/ctx." >&2
exit 2
