#!/usr/bin/env bun
/**
 * Merge this plugin into ~/.claude (installed_plugins.json + enabledPlugins).
 * Invoked by install-local scripts; needs only Bun stdlib.
 */
import {
  existsSync,
  mkdirSync,
  readFileSync,
  realpathSync,
  writeFileSync,
} from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";

const [, , name, rawPath] = process.argv;
if (!name || !rawPath) {
  console.error("usage: register-with-claude.ts <plugin-name> <install-dir>");
  process.exit(2);
}

let installPath: string;
try {
  installPath = realpathSync(rawPath);
} catch {
  console.error(`error: cannot resolve ${rawPath}`);
  process.exit(1);
}

const manifest = join(installPath, ".cursor-plugin", "plugin.json");
if (!existsSync(manifest)) {
  console.error(`error: missing ${manifest}`);
  process.exit(1);
}

const pluginId = `${name}@local`;
const claudeDir = join(homedir(), ".claude");
const pluginsDir = join(claudeDir, "plugins");
const installedPath = join(pluginsDir, "installed_plugins.json");
const settingsPath = join(claudeDir, "settings.json");

function loadJson(path: string): Record<string, unknown> {
  if (!existsSync(path)) return {};
  try {
    return JSON.parse(readFileSync(path, "utf-8")) as Record<string, unknown>;
  } catch {
    return {};
  }
}

const data = loadJson(installedPath);
const plugins =
  typeof data.plugins === "object" && data.plugins !== null && !Array.isArray(data.plugins)
    ? (data.plugins as Record<string, unknown>)
    : {};
data.plugins = plugins;
if (data.version === undefined) data.version = 2;

const prev = plugins[pluginId];
const list = Array.isArray(prev) ? [...prev] : [];
const kept = list.filter(
  (e) =>
    !(
      typeof e === "object" &&
      e !== null &&
      (e as { scope?: string }).scope === "user"
    ),
);
kept.unshift({ scope: "user", installPath });
plugins[pluginId] = kept;

mkdirSync(pluginsDir, { recursive: true });
writeFileSync(installedPath, `${JSON.stringify(data, null, 2)}\n`, "utf-8");
console.log(`Registered ${pluginId} → ${installedPath}`);

const sdata = loadJson(settingsPath);
const enabled =
  typeof sdata.enabledPlugins === "object" &&
  sdata.enabledPlugins !== null &&
  !Array.isArray(sdata.enabledPlugins)
    ? { ...(sdata.enabledPlugins as Record<string, boolean>) }
    : {};
enabled[pluginId] = true;
sdata.enabledPlugins = enabled;

mkdirSync(claudeDir, { recursive: true });
writeFileSync(settingsPath, `${JSON.stringify(sdata, null, 2)}\n`, "utf-8");
console.log(`Enabled ${pluginId} in ${settingsPath}`);
