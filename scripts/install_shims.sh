#!/usr/bin/env bash
set -euo pipefail

PREFIX="${HOME}/.contextfun"
BIN_DIR="$PREFIX/bin"
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd -P)"

shell_quote() {
  printf '%q' "$1"
}

mkdir -p "$BIN_DIR"

ROOT_DIR_SHELL=$(shell_quote "$ROOT_DIR")
cat > "$BIN_DIR/ctx" <<EOF
#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR=$ROOT_DIR_SHELL
exec python3 "\$ROOT_DIR/scripts/ctx_cmd.py" "\$@"
EOF

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
  *)
    BIN_DIR_SHELL=$(shell_quote "$BIN_DIR")
    printf 'export PATH=%s:"$PATH"\n' "$BIN_DIR_SHELL" >> "$HOME/.zshrc"
    ;;
esac

echo "Installed repo-backed shim to $BIN_DIR: ctx"
echo "This calls the cloned repo at $ROOT_DIR when a global 'ctx' is not installed."
echo "If not already present, PATH was updated in ~/.zshrc. Open a new shell to pick up changes."
