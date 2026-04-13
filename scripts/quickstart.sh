#!/usr/bin/env bash
set -euo pipefail

# ContextFun Quickstart (run after cloning this repo)
# - Initializes a local DB in ./.contextfun
# - Creates a project env file with handy aliases
# - Shows how to add the /ctx skill to Codex/Claude Code

usage() {
  cat <<EOF
Usage: $0 [--global]

Without flags, sets up a project-local ContextFun store under ./.contextfun and writes ./ctx.env.
Use --global to install a shared CLI into ~/.contextfun (requires PATH update; see output).
EOF
}

ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)
DB_LOCAL="$ROOT_DIR/.contextfun/context.db"

GLOBAL=false
if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  usage; exit 0
fi
if [[ "${1:-}" == "--global" ]]; then
  GLOBAL=true
fi

echo "==> ContextFun Quickstart"

if $GLOBAL; then
  echo "[1/3] Installing global CLI to ~/.contextfun (ctx on PATH)"
  bash "$ROOT_DIR/scripts/install.sh"
  echo "[2/3] Verifying installation"
  if command -v ctx >/dev/null 2>&1; then
    echo "  - Found 'ctx' in PATH"
  else
    echo "  - 'ctx' not yet in PATH. Open a new shell or add: export PATH=\"$HOME/.contextfun/bin:\$PATH\""
  fi
  echo "[3/3] Initializing global DB at \"$HOME/.contextfun/context.db\""
  PYTHONPATH="$HOME/.contextfun/lib" python3 -m contextfun --db "$HOME/.contextfun/context.db" init >/dev/null || true
  echo "\nDone. You can now run: ctx list"
else
  echo "[1/4] Initializing project-local DB at $DB_LOCAL"
  mkdir -p "$(dirname "$DB_LOCAL")"
  python3 -m contextfun --db "$DB_LOCAL" init >/dev/null || true

  ENV_FILE="$ROOT_DIR/ctx.env"
  echo "[2/4] Writing project env to $ENV_FILE"
  cat > "$ENV_FILE" <<EOF
# ContextFun project environment
export CONTEXTFUN_DB="$DB_LOCAL"
alias ctx-local='python3 "$ROOT_DIR/scripts/ctx_cmd.py"'
EOF

  echo "[3/4] Smoke test (list workstreams)"
  # shellcheck disable=SC1090
  source "$ENV_FILE"
  python3 "$ROOT_DIR/scripts/ctx_cmd.py" list || true

  echo "[4/4] Next steps"
  cat <<'NEXT'
- Activate this project env in new shells: source ./ctx.env
- Resume or start via local shim:
  - Resume: python3 scripts/skills/ctx_resume_skill.py --name "my-stream"
  - Start:  python3 scripts/skills/ctx_start_skill.py --name "my-stream" --agent codex

To use this inside Codex or Claude Code chats as "/ctx resume" or "/ctx start",
add a skill/expansion that runs the scripts above and pastes the status line:
- Espanso: map "/ctx resume" to run ctx_resume_skill.py; "/ctx start" to ctx_start_skill.py
- Keyboard Maestro: create macros that execute the scripts, pipe to pbcopy, then Cmd+V
- Raycast: Script Commands that run the scripts, pipe to pbcopy, then paste via AppleScript

Tip: For a global setup across projects, rerun this script with --global and use 'ctx'.
NEXT
fi

echo "\nQuickstart complete."

