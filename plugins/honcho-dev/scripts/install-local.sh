#!/usr/bin/env bash
# Symlink honcho-dev into ~/.cursor/plugins/local/ and register with Cursor (see honcho install-local.sh).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
REGISTER_TS="$REPO_ROOT/plugins/honcho/scripts/register-cursor-plugin.ts"
TARGET="$HOME/.cursor/plugins/local/honcho-dev"

if [[ ! -d "$PLUGIN_DIR" ]]; then
  echo "error: could not resolve plugin directory" >&2
  exit 1
fi
if [[ ! -f "$REGISTER_TS" ]]; then
  echo "error: missing $REGISTER_TS (expected monorepo layout: plugins/honcho + plugins/honcho-dev)" >&2
  exit 1
fi

mkdir -p "$(dirname "$TARGET")"
rm -rf "$TARGET"
ln -sf "$PLUGIN_DIR" "$TARGET"

echo "Linked honcho-dev only:"
echo "  $PLUGIN_DIR"
echo "  -> $TARGET"
echo ""
if [[ ! -f "$TARGET/.cursor-plugin/plugin.json" ]]; then
  echo "warning: expected $TARGET/.cursor-plugin/plugin.json (symlink may be broken)" >&2
else
  echo "OK: manifest present at $TARGET/.cursor-plugin/plugin.json"
fi
echo ""

if ! command -v bun >/dev/null 2>&1; then
  echo "error: bun is required (https://bun.sh)" >&2
  exit 1
fi
bun "$REGISTER_TS" honcho-dev "$TARGET"
echo ""
echo "Quit Cursor completely (Cmd+Q) and reopen."
echo "If skills do not appear: Settings → Features → third-party plugins/skills (wording varies)."
