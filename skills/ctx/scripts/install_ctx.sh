#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd -P)
SKILL_DIR=$(cd "$SCRIPT_DIR/.." && pwd -P)
REPO_ROOT=""
if REPO_ROOT=$(cd "$SKILL_DIR/../.." 2>/dev/null && pwd -P); then
  if [[ -f "$REPO_ROOT/scripts/install.sh" && -d "$REPO_ROOT/contextfun" ]]; then
    exec bash "$REPO_ROOT/scripts/install.sh" "$@"
  fi
fi

REPO_URL="https://github.com/dchu917/ctx"
DEFAULT_REF="v0.1.1"
CTX_REF="${CTX_VERSION:-$DEFAULT_REF}"
if [[ "$CTX_REF" == "main" ]]; then
  ARCHIVE_URL="$REPO_URL/archive/refs/heads/main.tar.gz"
else
  TAG_REF="${CTX_REF#refs/tags/}"
  ARCHIVE_URL="$REPO_URL/archive/refs/tags/$TAG_REF.tar.gz"
fi

PREFIX="${HOME}/.contextfun"
BIN_DIR="$PREFIX/bin"
LIB_DIR="$PREFIX/lib"
SKILLS_DIR="$PREFIX/skills"
DB_PATH="$PREFIX/context.db"

shell_quote() {
  printf '%q' "$1"
}

echo "Installing ctx to $PREFIX"
echo "Release ref: $CTX_REF"
mkdir -p "$BIN_DIR" "$LIB_DIR" "$SKILLS_DIR"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

echo "Downloading archive from $ARCHIVE_URL ..."
curl -fsSL "$ARCHIVE_URL" | tar xz -C "$TMPDIR"
SRC_DIR=$(find "$TMPDIR" -mindepth 1 -maxdepth 1 -type d | head -n1)

if [[ ! -d "$SRC_DIR/contextfun" ]]; then
  echo "Error: could not find package in archive." >&2
  exit 1
fi

echo "Copying files ..."
rsync -a "$SRC_DIR/contextfun/" "$LIB_DIR/contextfun/"
install -m 0755 "$SRC_DIR/scripts/ctx_cmd.py" "$BIN_DIR/ctx.py"
cat > "$BIN_DIR/ctx" <<'SH'
#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd -P)"
BIN_DIR="$SCRIPT_DIR"
PREFIX="$(cd "$BIN_DIR/.." && pwd -P)"
LIB_DIR="$PREFIX/lib"
export PYTHONPATH="$LIB_DIR${PYTHONPATH:+:$PYTHONPATH}"
exec python3 "$BIN_DIR/ctx.py" "$@"
SH
chmod +x "$BIN_DIR/ctx"
rsync -a "$SRC_DIR/skills/" "$SKILLS_DIR/"

rm -f \
  "$BIN_DIR/ctx.pyc" \
  "$BIN_DIR/ctx-list" \
  "$BIN_DIR/ctx-search" \
  "$BIN_DIR/ctx-resume" \
  "$BIN_DIR/ctx-start" \
  "$BIN_DIR/ctx-delete" \
  "$BIN_DIR/ctx-branch" \
  "$BIN_DIR/ctx-web"

if [[ "${CTX_INSTALL_SKILLS:-1}" != "0" ]]; then
  echo "Installing self-contained Claude/Codex skills ..."
  bash "$SRC_DIR/scripts/install_skills.sh" \
    --skills-root "$SKILLS_DIR" \
    --codex-dir "${CODEX_SKILLS_DIR:-$HOME/.codex/skills}" \
    --claude-dir "${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
fi

SHELL_RC=""
if [[ -n "${ZSH_VERSION:-}" ]]; then SHELL_RC="$HOME/.zshrc"; fi
if [[ -n "${BASH_VERSION:-}" ]]; then SHELL_RC="$HOME/.bashrc"; fi
if [[ -z "$SHELL_RC" ]]; then SHELL_RC="$HOME/.profile"; fi

echo "Writing environment to $SHELL_RC"
DB_PATH_SHELL=$(shell_quote "$DB_PATH")
BIN_DIR_SHELL=$(shell_quote "$BIN_DIR")
grep -Fq 'CONTEXTFUN_DB' "$SHELL_RC" 2>/dev/null || printf 'export CONTEXTFUN_DB=%s\n' "$DB_PATH_SHELL" >> "$SHELL_RC"
grep -Fq "$BIN_DIR" "$SHELL_RC" 2>/dev/null || printf 'export PATH=%s:"$PATH"\n' "$BIN_DIR_SHELL" >> "$SHELL_RC"

echo "Initializing database at $DB_PATH"
PYTHONPATH="$LIB_DIR" python3 -m contextfun --db "$DB_PATH" init >/dev/null || true

cat <<EOF

ctx installed.

Open a new shell or run:
  export CONTEXTFUN_DB=$DB_PATH_SHELL
  export PATH=$BIN_DIR_SHELL:"\$PATH"

Try:
  ctx
  ctx list
  ctx search my-query
  ctx start my-workstream
  ctx start my-workstream --pull
  ctx resume my-workstream
  ctx rename better-name --from my-workstream
  ctx delete my-workstream
  ctx branch from-workstream to-workstream
  ctx web --open

Notes:
  - This bootstrap installer uses the pinned release ref: $CTX_REF
  - Set CTX_VERSION=<tag> to install a different tagged release.
  - Set CTX_INSTALL_SKILLS=0 to skip installing Claude/Codex skills.
EOF
