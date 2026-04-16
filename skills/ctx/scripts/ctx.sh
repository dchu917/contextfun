#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd -P)
INSTALLER="$SCRIPT_DIR/install_ctx.sh"
TARGET_BIN="$HOME/.contextfun/bin/ctx"

if command -v ctx >/dev/null 2>&1; then
  exec ctx "$@"
fi

if [[ -x "$TARGET_BIN" ]]; then
  exec "$TARGET_BIN" "$@"
fi

if [[ "${1:-}" == "install" ]]; then
  shift
  bash "$INSTALLER"
  if [[ $# -eq 0 ]]; then
    exit 0
  fi
fi

echo "ctx is not installed. Bootstrapping the bundled installer first..." >&2
bash "$INSTALLER"

if command -v ctx >/dev/null 2>&1; then
  exec ctx "$@"
fi
if [[ -x "$TARGET_BIN" ]]; then
  exec "$TARGET_BIN" "$@"
fi

echo "ctx install completed, but the binary is still unavailable. Open a new shell and try again." >&2
exit 2
