#!/usr/bin/env bash
# Symlink the honcho (memory) plugin into Cursor local plugins.
# Docs: https://cursor.com/docs/plugins.md — ~/.cursor/plugins/local/<name>
# For SDK-only skills, use plugins/honcho-dev/scripts/install-local.sh
#
# After linking, run **Developer: Reload Window** in Cursor (or restart Cursor).

set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TARGET="$HOME/.cursor/plugins/local/honcho"

if [[ ! -d "$PLUGIN_DIR" ]]; then
  echo "error: could not resolve plugin directory" >&2
  exit 1
fi

mkdir -p "$(dirname "$TARGET")"
rm -rf "$TARGET"
ln -sf "$PLUGIN_DIR" "$TARGET"

echo "Linked:"
echo "  $PLUGIN_DIR"
echo "  -> $TARGET"
echo ""
echo "Reload Cursor (Developer: Reload Window) to pick up changes."
