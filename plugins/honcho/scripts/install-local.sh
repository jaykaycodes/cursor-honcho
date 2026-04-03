#!/usr/bin/env bash
# Symlink the honcho plugin into Cursor local plugins.
# For SDK-only skills, use plugins/honcho-dev/scripts/install-local.sh
#
# After linking, run Developer: Reload Window (or restart Cursor).

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
if [[ ! -f "$TARGET/.cursor-plugin/plugin.json" ]]; then
  echo "warning: expected $TARGET/.cursor-plugin/plugin.json (symlink may be broken)" >&2
else
  echo "OK: manifest present at $TARGET/.cursor-plugin/plugin.json"
fi
echo ""
echo "Reload Cursor (Developer: Reload Window) to pick up changes."
