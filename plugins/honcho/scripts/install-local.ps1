# Symlink this plugin into Cursor local plugins for development.
# Docs: https://cursor.com/docs/plugins.md — ~/.cursor/plugins/local/<name>
#
# Usage: powershell -ExecutionPolicy Bypass -File install-local.ps1
# Then reload Cursor (Developer: Reload Window).

$ErrorActionPreference = "Stop"

$PluginDir = (Resolve-Path "$PSScriptRoot\..").Path
$Target = Join-Path $env:USERPROFILE ".cursor\plugins\local\honcho"
$Parent = Split-Path $Target

New-Item -ItemType Directory -Force -Path $Parent | Out-Null
if (Test-Path $Target) {
    Remove-Item $Target -Recurse -Force
}
New-Item -ItemType Junction -Path $Target -Target $PluginDir | Out-Null

Write-Host "Linked:" -ForegroundColor Green
Write-Host "  $PluginDir"
Write-Host "  -> $Target"
Write-Host ""
$manifest = Join-Path $Target ".cursor-plugin\plugin.json"
if (-not (Test-Path $manifest)) {
    Write-Warning "Expected $manifest (junction may be broken)"
} else {
    Write-Host "OK: manifest present at $manifest"
}
Write-Host ""
Write-Host "Reload Cursor (Developer: Reload Window), or fully quit and reopen."
Write-Host "Note: local plugins do not show in the Marketplace list — check Settings > Rules and MCP for Honcho."
