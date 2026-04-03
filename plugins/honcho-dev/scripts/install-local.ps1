# Symlink + register Honcho Dev. Requires bun on PATH.

$ErrorActionPreference = "Stop"

$PluginDir = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..\..")).Path
$RegisterTs = Join-Path $RepoRoot "plugins\honcho\scripts\register-with-claude.ts"
$Target = Join-Path $env:USERPROFILE ".cursor\plugins\local\honcho-dev"

if (-not (Test-Path $RegisterTs)) {
    Write-Error "Missing $RegisterTs — use the full monorepo (plugins/honcho + plugins/honcho-dev)."
    exit 1
}

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

$bun = Get-Command bun -ErrorAction SilentlyContinue
if (-not $bun) {
    Write-Error "bun not found. Install from https://bun.sh and ensure it is on PATH."
    exit 1
}
$targetResolved = (Resolve-Path $Target).Path
& bun $RegisterTs honcho-dev $targetResolved
Write-Host ""
Write-Host "Quit Cursor fully and reopen."
