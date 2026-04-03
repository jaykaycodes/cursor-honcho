---
name: honcho-setup
description: First-time Honcho configuration — set API key, validate connection, create config
---

# Honcho Setup

Walk the user through first-time Honcho configuration so persistent memory works in Cursor.

## Steps

### 1. Check current state

Check if `HONCHO_API_KEY` is set as an environment variable OR if `~/.honcho/config.json` already has an apiKey:

```bash
bun -e "
const fs = require('fs');
const path = require('path');
const configPath = path.join(require('os').homedir(), '.honcho', 'config.json');
const envKey = process.env.HONCHO_API_KEY;
let configKey = '';
try { configKey = JSON.parse(fs.readFileSync(configPath, 'utf-8')).apiKey || ''; } catch {}
console.log(envKey || configKey ? 'set' : 'not set');
"
```

If the output is `set`, skip to step 3 (validation). Otherwise continue.

### 2. Direct user to set their API key

Tell the user to get a free API key at https://app.honcho.dev, then set it as an environment variable.

Detect the platform and give the appropriate command:

**If Windows** (check with `bun -e "console.log(process.platform)"` if unsure):

> Set your API key in PowerShell:
> ```powershell
> setx HONCHO_API_KEY "your-key-here"
> ```
> Then fully quit and reopen Cursor and run the **honcho-setup** skill again.

**If macOS / Linux:**

> Add to your shell config (`~/.zshrc` or `~/.bashrc`):
> ```
> export HONCHO_API_KEY="your-key-here"
> ```
> Then fully quit and reopen Cursor and run the **honcho-setup** skill again.

IMPORTANT: Do NOT ask the user to paste their API key into the chat. Keys must be set via environment variable outside of Cursor.

Stop here and wait for the user to come back after restarting. Do not proceed to validation until they run **honcho-setup** again.

### 3. Validate the API key

Run the setup runner to validate the connection:

```bash
bun run "${CURSOR_PLUGIN_ROOT}/src/skills/setup-runner.ts"
```

If `CURSOR_PLUGIN_ROOT` is not set, use the absolute path to this plugin’s root directory (the folder that contains `mcp-server.ts` and `package.json`).

### 4. Confirm setup

Tell the user that Honcho is configured and memory will be active on their next agent session. Suggest they reload Cursor (**Developer: Reload Window**) or restart Cursor to see memory context load on startup.
