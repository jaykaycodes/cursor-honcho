#!/usr/bin/env bash
# Symlink honcho into ~/.cursor/plugins/local/ and register with ~/.claude/ so
# Cursor's agent actually loads hooks, rules, MCP, and skills (symlink alone is not enough).
# For SDK-only skills, use plugins/honcho-dev/scripts/install-local.sh
#
# After install: quit Cursor fully (Cmd+Q) and reopen, or Reload Window.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
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

"$SCRIPT_DIR/register-with-claude.sh" honcho "$TARGET"
echo ""
echo "Quit Cursor completely (Cmd+Q) and reopen, then check:"
echo "  Settings → Rules (Honcho / honcho-memory), Features → MCP (honcho)."
echo "  Hooks run in the background; there is usually no 'Honcho' row under Hooks settings."
echo "  If nothing loads: Settings → Features → enable third-party plugins/skills (wording varies by version)."
