#!/usr/bin/env bash
# Register ~/.cursor/plugins/local/<name> with Cursor via ~/.claude (installed_plugins + enabledPlugins).
set -euo pipefail
[[ $# -eq 2 ]] || { echo "usage: $0 <plugin-name> <install-dir>" >&2; exit 2; }

NAME="$1"
TARGET="$2"
if [[ ! -f "$TARGET/.cursor-plugin/plugin.json" ]]; then
  echo "error: missing $TARGET/.cursor-plugin/plugin.json" >&2
  exit 1
fi

export REG_NAME="$NAME"
export REG_PATH="$(cd "$TARGET" && pwd -P)"

command -v python3 >/dev/null 2>&1 || { echo "error: python3 required" >&2; exit 1; }

python3 <<'PY'
import json, os
from pathlib import Path

name = os.environ["REG_NAME"]
install_path = os.environ["REG_PATH"]
plugin_id = f"{name}@local"

claude_plugins = Path.home() / ".claude" / "plugins" / "installed_plugins.json"
settings_path = Path.home() / ".claude" / "settings.json"

data = {}
if claude_plugins.exists():
    try:
        data = json.loads(claude_plugins.read_text(encoding="utf-8"))
    except json.JSONDecodeError:
        pass
data.setdefault("plugins", {})
data.setdefault("version", 2)
prev = data["plugins"].get(plugin_id, [])
if not isinstance(prev, list):
    prev = []
kept = [e for e in prev if not (isinstance(e, dict) and e.get("scope") == "user")]
kept.insert(0, {"scope": "user", "installPath": install_path})
data["plugins"][plugin_id] = kept
claude_plugins.parent.mkdir(parents=True, exist_ok=True)
claude_plugins.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")
print(f"Registered {plugin_id} → {claude_plugins}")

sdata = {}
if settings_path.exists():
    try:
        sdata = json.loads(settings_path.read_text(encoding="utf-8"))
    except json.JSONDecodeError:
        pass
sdata.setdefault("enabledPlugins", {})[plugin_id] = True
settings_path.parent.mkdir(parents=True, exist_ok=True)
settings_path.write_text(json.dumps(sdata, indent=2) + "\n", encoding="utf-8")
print(f"Enabled {plugin_id} in {settings_path}")
PY
