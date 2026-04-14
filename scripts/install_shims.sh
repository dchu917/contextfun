#!/usr/bin/env bash
set -euo pipefail

PREFIX="${HOME}/.contextfun"
BIN_DIR="$PREFIX/bin"
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd -P)"

mkdir -p "$BIN_DIR"

cat > "$BIN_DIR/ctx" <<'SH'
#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="__ROOT_DIR__"
exec python3 "$ROOT_DIR/scripts/ctx_cmd.py" "$@"
SH

for shim in "$BIN_DIR/ctx"; do
  perl -0pi -e 's|__ROOT_DIR__|'"$ROOT_DIR"'|g' "$shim"
done

chmod +x "$BIN_DIR/ctx"

rm -f \
  "$BIN_DIR/ctx-list" \
  "$BIN_DIR/ctx-search" \
  "$BIN_DIR/ctx-resume" \
  "$BIN_DIR/ctx-start" \
  "$BIN_DIR/ctx-delete" \
  "$BIN_DIR/ctx-branch" \
  "$BIN_DIR/ctx-web"

case ":${PATH}:" in
  *":${BIN_DIR}:"*) :;;
  *) echo "export PATH=\"$BIN_DIR:\$PATH\"" >> "$HOME/.zshrc";;
esac

echo "Installed repo-backed shim to $BIN_DIR: ctx"
echo "This calls the cloned repo at $ROOT_DIR when a global 'ctx' is not installed."
echo "If not already present, PATH was updated in ~/.zshrc. Open a new shell to pick up changes."
