# Symlink + register Honcho with Cursor's agent (~/.claude + ~/.cursor/plugins/local).
# Requires Python 3 for registration (same as install-local.sh).

$ErrorActionPreference = "Stop"

$PluginDir = (Resolve-Path "$PSScriptRoot\..").Path
$Target = Join-Path $env:USERPROFILE ".cursor\plugins\local\honcho"
$Parent = Split-Path $Target
$RegisterPy = Join-Path $PSScriptRoot "register-for-cursor-agent.py"

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

$py = Get-Command python3 -ErrorAction SilentlyContinue
if (-not $py) { $py = Get-Command python -ErrorAction SilentlyContinue }
if (-not $py) {
    Write-Error "python3 is required to register the plugin in ~/.claude/"
    exit 1
}
$targetResolved = (Resolve-Path $Target).Path
& $py.Source $RegisterPy honcho $targetResolved
Write-Host ""
Write-Host "Quit Cursor fully and reopen. Check Settings > Rules and MCP."
Write-Host "Hooks run in the background; they usually do not appear as rows under Hooks settings."
