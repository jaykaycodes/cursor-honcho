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

Clone this repository, then symlink the plugin(s) into Cursor’s local plugins directory.

**Honcho** (memory, MCP, hooks):

```bash
cd plugins/honcho && bun install
./scripts/install-local.sh
```

Windows (PowerShell): `.\scripts\install-local.ps1`
Installs to `~/.cursor/plugins/local/honcho`.

**Honcho Dev** (skills only):

```bash
cd plugins/honcho-dev
./scripts/install-local.sh
```

Windows: `.\scripts\install-local.ps1`
Installs to `~/.cursor/plugins/local/honcho-dev`.

For both plugins, run both flows (two separate targets).

## Requirements

- [Bun](https://bun.sh) — required for the **Honcho** plugin (MCP server and hook runners).
- **Honcho memory**: `HONCHO_API_KEY` from [app.honcho.dev](https://app.honcho.dev).

**Honcho Dev** does not ship a Bun `package.json`; only **Honcho** needs `bun install` in its plugin directory.

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
