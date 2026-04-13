#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd -P)"

exec bash "$ROOT_DIR/scripts/quickstart.sh" "$@"
