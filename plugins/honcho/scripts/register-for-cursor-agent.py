#!/usr/bin/env python3
"""
Register a local plugin with Cursor's Claude-plugin bridge (~/.claude).
Symlinking into ~/.cursor/plugins/local/ alone is often not enough for hooks,
rules, and skills to load; Cursor also reads installed_plugins.json + settings.
"""
from __future__ import annotations

import json
import pathlib
import sys


def main() -> None:
    if len(sys.argv) != 3:
        print(
            "usage: register-for-cursor-agent.py <plugin-name> <install-path>",
            file=sys.stderr,
        )
        sys.exit(2)
    name, raw_path = sys.argv[1], sys.argv[2]
    install_path = pathlib.Path(raw_path).expanduser().resolve()
    manifest = install_path / ".cursor-plugin" / "plugin.json"
    if not manifest.is_file():
        print(f"error: missing {manifest}", file=sys.stderr)
        sys.exit(1)

    plugin_id = f"{name}@local"
    install_path_str = str(install_path)

    claude_plugins = pathlib.Path.home() / ".claude" / "plugins" / "installed_plugins.json"
    settings_path = pathlib.Path.home() / ".claude" / "settings.json"

    data: dict = {}
    if claude_plugins.exists():
        try:
            data = json.loads(claude_plugins.read_text(encoding="utf-8"))
        except json.JSONDecodeError:
            data = {}
    if "plugins" not in data:
        data["plugins"] = {}
    data.setdefault("version", 2)

    prev = data["plugins"].get(plugin_id, [])
    if not isinstance(prev, list):
        prev = []
    kept = [e for e in prev if not (isinstance(e, dict) and e.get("scope") == "user")]
    kept.insert(0, {"scope": "user", "installPath": install_path_str})
    data["plugins"][plugin_id] = kept

    claude_plugins.parent.mkdir(parents=True, exist_ok=True)
    claude_plugins.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")
    print(f"Registered {plugin_id} → {claude_plugins}")

    sdata: dict = {}
    if settings_path.exists():
        try:
            sdata = json.loads(settings_path.read_text(encoding="utf-8"))
        except json.JSONDecodeError:
            sdata = {}
    sdata.setdefault("enabledPlugins", {})[plugin_id] = True
    settings_path.parent.mkdir(parents=True, exist_ok=True)
    settings_path.write_text(json.dumps(sdata, indent=2) + "\n", encoding="utf-8")
    print(f"Enabled {plugin_id} in {settings_path}")


if __name__ == "__main__":
    main()
