# Symlink + register Honcho (~/.claude bridge). Requires bun on PATH.

$ErrorActionPreference = "Stop"

$PluginDir = (Resolve-Path "$PSScriptRoot\..").Path
$Target = Join-Path $env:USERPROFILE ".cursor\plugins\local\honcho"
$Parent = Split-Path $Target
$RegisterTs = Join-Path $PSScriptRoot "register-with-claude.ts"

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

$bun = Get-Command bun -ErrorAction SilentlyContinue
if (-not $bun) {
    Write-Error "bun not found. Install from https://bun.sh and ensure it is on PATH."
    exit 1
}
$targetResolved = (Resolve-Path $Target).Path
& bun $RegisterTs honcho $targetResolved
Write-Host ""
Write-Host "Quit Cursor fully and reopen. Check Settings > Rules and MCP."
