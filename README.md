# Honcho for Cursor

Persistent memory (**Honcho**) and Honcho SDK workflow skills (**Honcho Dev**) for [Cursor](https://cursor.com), ported from the upstream [Claude Code plugins](https://github.com/plastic-labs/claude-honcho) with Cursor-native hooks, MCP, and manifests.

| Plugin | Purpose |
| --- | --- |
| **Honcho** | Hooks, MCP server, skills (`honcho-setup`, …), rule `honcho-memory.mdc` |
| **Honcho Dev** | SDK integration and migration skills (no MCP/hooks) |

## Install from the Cursor Marketplace

1. Open the [Cursor Marketplace](https://cursor.com/marketplace) or the marketplace panel in Cursor.
2. Search for **Honcho** or **Honcho Dev** and install what you need (two plugins from one source).
3. Continue with [Requirements](#requirements) and [After you install](#after-you-install).

## Team marketplace

If your organization uses [Cursor Teams or Enterprise](https://cursor.com/docs/plugins.md#team-marketplaces), an admin can add this plugin bundle under **Dashboard → Settings → Plugins → Team Marketplaces → Import** using the public GitHub URL of this repository. Members then install **Honcho** and **Honcho Dev** from the team section of the marketplace panel (plugins can be required or optional per group).

## Install from source

Clone this repository, then run the install script for each plugin you want.

**Honcho** (memory, MCP, hooks):

```bash
cd plugins/honcho && bun install
./scripts/install-local.sh
```

Windows (PowerShell): `.\scripts\install-local.ps1`

**Honcho Dev** (skills only):

```bash
cd plugins/honcho-dev
./scripts/install-local.sh
```

Windows: `.\scripts\install-local.ps1`

For both plugins, run both flows (two separate targets).

### Hooks, rules, and what you see in Settings

- **Hooks** (session start, after edits, etc.) run **automatically** when the agent runs. They are **not** listed as a per-plugin checklist under **Settings → Hooks** the way a single global `hooks.json` might be. To debug hook I/O, use the **Output** panel and choose **Hooks** (see [Hooks](https://cursor.com/docs/hooks.md)).
- **Rules** from the plugin should appear under **Settings → Rules** (search for **Honcho** or `honcho-memory`). The bundled rule uses `alwaysApply: false`, so it may show as **Agent Decides** / on-request unless you change the mode.
- **MCP** — **Settings → Features → Model Context Protocol** → **honcho** server.
- **Third-party plugins** — if nothing loads after a full quit and reopen, open **Settings → Features** and enable anything like **Include third-party plugins, skills, and configs** (wording varies by Cursor version).

### Verify a local install

Marketplace **Browse** will not list local installs; that is normal.

After a **full quit** (Cmd+Q / Alt+F4) and reopen:

1. **On disk:** `~/.cursor/plugins/local/honcho/.cursor-plugin/plugin.json` (and/or `honcho-dev`).
2. **Honcho** — **Settings → Rules** and **MCP** as above.

If rules or MCP still do not show: update Cursor, confirm **Bun** is on the `PATH` for the app, and try the third-party toggle above.

## Requirements

- [Bun](https://bun.sh) — required for the **Honcho** plugin (MCP server and hook runners).
- **Honcho memory**: `HONCHO_API_KEY` from [app.honcho.dev](https://app.honcho.dev).

**Honcho Dev** has no `package.json`; you do not run `bun install` there. **Honcho** still needs `bun install` in `plugins/honcho` for dependencies.

## After you install

1. Run **Developer: Reload Window** (or restart Cursor).
2. For **Honcho** only: open the installed plugin folder (the one containing `mcp-server.ts` and `package.json`) and run `bun install` if the MCP server or hooks do not start.
3. Enable the **honcho** MCP server under **Settings → Features → Model Context Protocol** if it is off.
4. Use bundled skills as described in Cursor’s [Skills](https://cursor.com/docs/skills.md) documentation.

## Compared to Claude Code

| Area | Claude | Cursor |
| --- | --- | --- |
| Manifest | `.claude-plugin/plugin.json` | `.cursor-plugin/plugin.json` |
| Hooks | `SessionStart`, `UserPromptSubmit`, … | `sessionStart`, `beforeSubmitPrompt`, … |
| Plugin root in hooks | `${CLAUDE_PLUGIN_ROOT}` | `${CURSOR_PLUGIN_ROOT}` |
| MCP file | `mcp-servers.json` | `mcp.json` (`mcpServers`) |
| Default host | `claude_code` | `cursor` (`hosts.cursor` in `~/.honcho/config.json`) |

Shared runtime: Honcho SDK, `~/.honcho/config.json`, session strategies, and `linkedHosts`. Configuration details: [Claude Honcho README](https://github.com/plastic-labs/claude-honcho/blob/main/README.md).

## License

MIT — see [LICENSE](LICENSE).
