# Symlink honcho-dev only into Cursor local plugins.

$ErrorActionPreference = "Stop"

$PluginDir = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$Target = Join-Path $env:USERPROFILE ".cursor\plugins\local\honcho-dev"

New-Item -ItemType Directory -Force -Path (Split-Path $Target) | Out-Null
if (Test-Path $Target) { Remove-Item $Target -Recurse -Force }
New-Item -ItemType SymbolicLink -Path $Target -Target $PluginDir -Force | Out-Null

Write-Host "Linked honcho-dev only:"
Write-Host "  $PluginDir"
Write-Host "  -> $Target"
Write-Host ""
$manifest = Join-Path $Target ".cursor-plugin\plugin.json"
if (-not (Test-Path $manifest)) {
    Write-Warning "Expected $manifest (link may be broken)"
} else {
    Write-Host "OK: manifest present at $manifest"
}
Write-Host ""

Write-Host "Reload Cursor (Developer: Reload Window)."
