#!/usr/bin/env bash
# Symlink honcho-dev only into Cursor local plugins (skills-only plugin).
# Docs: https://cursor.com/docs/plugins.md — ~/.cursor/plugins/local/<name>

set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TARGET="$HOME/.cursor/plugins/local/honcho-dev"

if [[ ! -d "$PLUGIN_DIR" ]]; then
  echo "error: could not resolve plugin directory" >&2
  exit 1
fi

mkdir -p "$(dirname "$TARGET")"
rm -rf "$TARGET"
ln -sf "$PLUGIN_DIR" "$TARGET"

echo "Linked honcho-dev only:"
echo "  $PLUGIN_DIR"
echo "  -> $TARGET"
echo ""
echo "Reload Cursor (Developer: Reload Window)."
