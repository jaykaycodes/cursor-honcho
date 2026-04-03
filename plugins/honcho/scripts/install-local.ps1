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
Write-Host "Reload Cursor (Developer: Reload Window) to pick up changes."
