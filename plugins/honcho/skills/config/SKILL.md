---
name: honcho-config
description: Configure Honcho memory plugin settings interactively (uses get_config / set_config MCP tools)
---

# Honcho Configuration

Interactive configuration for the Honcho memory plugin **in Cursor**.

**UX (Cursor):** There is no Claude Code `AskUserQuestion` tool. Drive the flow in chat: ask **one question at a time**, offer **clear labeled options** as a short markdown list (users reply with the label or a short answer). Avoid huge walls of numbered lists; keep each step scannable.

## Step 1: Status Header

Call `get_config` to load the current state. The response includes a `card` field — a pre-rendered box-drawing card with perfect alignment.

**Output the `card` value exactly as-is inside a code fence.** Do not modify it, re-render it, or add any formatting. Just wrap it in triple backticks:

````
```
{card value here, verbatim}
```
````
- Do NOT show cache info, config paths, or raw JSON.
- Do NOT show warnings unless they indicate something is broken (skip env var shadowing warnings where the values match what's configured).
- If `configExists` is false, tell the user no config exists and offer to create one.

## Step 2: Menu

Ask: **What would you like to configure?** Offer these options (substitute `{resolved.*}` from `get_config`):

- **Peers** — your name and AI name (currently: `{resolved.peerName}` / `{resolved.aiPeer}`)
- **Session mapping** — how sessions are named (currently: `{resolved.sessionStrategy}`)
- **Workspace** — data space and cross-tool linking (currently: `{resolved.workspace}`)
- **Other** — advanced settings below

If they pick **Other**, ask which advanced area:

- **Host** — platform / local / custom URL (`{current.host}`)
- **Context refresh** — TTL, message threshold, dialectic settings
- **Message upload** — token limits, summarization

Always include current values in the description so the user can see what's set.

## Step 3: Handle Selection

### Peers

Ask which peer to change:

- **Your name** (currently: `{resolved.peerName}`)
- **AI name** (currently: `{resolved.aiPeer}`)

Then ask for the new value. Call `set_config` with `peerName` or `aiPeer`.

### Simple fields (Logging, etc.)

Ask for the new value (offer known options as bullets if applicable). Call `set_config` with the appropriate field. Show the result.

### Session mapping

Ask which strategy:

- **per-directory (recommended)** — `{peer}-{repo}` — one session per project
- **git-branch** — `{peer}-{repo}-{branch}` — session follows branch
- **chat-instance** — `chat-{id}` — fresh each launch

After strategy selection, ask about peer prefix:

- **Yes** — `{peerName}-{repoName}` (good for teams sharing a workspace)
- **No** — `{repoName}` only (cleaner for solo use)

### Workspace

Sub-menu:

- **Rename workspace** — change name (currently: `{resolved.workspace}`)
- **Link / unlink hosts** — share context across tools (`{resolved.linkedHosts || 'none'}`)

#### Workspace > Rename

Dangerous field — requires confirmation. First call `set_config` WITHOUT `confirm: true`. The tool will return a description of what will happen. Then ask explicitly: **Yes, switch** vs **Cancel**. If they confirm, call `set_config` again WITH `confirm: true`.

#### Workspace > Link / unlink hosts

Linking and global mode are one concept: if any hosts are linked, global mode is on (shared workspace, sessions, peers). If all hosts are unlinked, global mode is off.

Show **one action per message**: for each host from `get_config`'s `host.otherHosts`, offer **Link {hostKey}** or **Unlink {hostKey}** depending on current state. Do not multi-select in one step.

**If the user chose "Link {host}":**

Compute the new linked array: current `resolved.linkedHosts` + the new host.
Call `set_config` with `field: "linkedHosts"` and the new array.

If this is the first link (was previously empty), ask which **shared workspace name** to use — offer **{currentWorkspace} (recommended)** and each **{otherHostWorkspace}** from linked hosts.

Call `set_config` with `field: "workspace"`, `value: chosen`, `confirm: true`.
Call `set_config` with `field: "globalOverride"`, `value: true`, `confirm: true`.

If already linked to other hosts (just adding one more), skip the workspace prompt — the shared workspace is already set.

**If the user chose "Unlink {host}":**

Compute the new linked array: current `resolved.linkedHosts` minus that host.
Call `set_config` with `field: "linkedHosts"` and the new array.

If the new array is empty (no hosts linked), also disable global mode:
Call `set_config` with `field: "globalOverride"`, `value: false`.
Explain: "All hosts unlinked. Each host uses its own workspace and config."

If hosts remain linked, just confirm: "Unlinked {host}. Still linked to: {remaining}."

### Dangerous fields (Host)

Host changes require confirmation. First call `set_config` WITHOUT `confirm: true`. The tool will return a description of what will happen. Ask **Yes / Cancel** in chat, then call again WITH `confirm: true` if they confirm.

### Context refresh

Ask which setting to change:

- **TTL** — cache lifetime (currently `{contextRefresh.ttlSeconds}s`, default 300)
- **Message threshold** — refresh every N messages (currently `{contextRefresh.messageThreshold}`, default 30)
- **Skip dialectic** — skip `chat()` in prompt hook (`{contextRefresh.skipDialectic}`, default false)

Then ask for the new value and call `set_config`.

### Message upload

Ask which setting to change:

- **Max user tokens** — `{messageUpload.maxUserTokens || 'no limit'}`
- **Max assistant tokens** — `{messageUpload.maxAssistantTokens || 'no limit'}`
- **Summarize assistant** — `{messageUpload.summarizeAssistant}`

Then ask for the new value and call `set_config`.

## Step 4: Loop

After handling a selection, call `get_config` again to refresh state. Ask **Configure more** vs **Done**. If configure more, go back to Step 2. If done, show the final status header and exit.

## Guardrails

- Use conversational menus (labeled bullets), one decision per step when possible.
- Always show the result of `set_config` including any cache invalidation that occurred.
- If a warning about env var shadowing is returned, explain that the env var takes precedence at runtime.
- Never guess values — always ask the user.
- Include current values in option descriptions so the user sees what's set without expanding anything.
- If `get_config` returns `configExists: false`, guide the user to set HONCHO_API_KEY first.
