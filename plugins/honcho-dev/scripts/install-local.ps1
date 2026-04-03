# Symlink + register Honcho Dev (uses register script from plugins/honcho).

$ErrorActionPreference = "Stop"

$PluginDir = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..\..")).Path
$RegisterPy = Join-Path $RepoRoot "plugins\honcho\scripts\register-for-cursor-agent.py"
$Target = Join-Path $env:USERPROFILE ".cursor\plugins\local\honcho-dev"

if (-not (Test-Path $RegisterPy)) {
    Write-Error "Missing $RegisterPy — use the full monorepo (plugins/honcho + plugins/honcho-dev)."
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

$py = Get-Command python3 -ErrorAction SilentlyContinue
if (-not $py) { $py = Get-Command python -ErrorAction SilentlyContinue }
if (-not $py) {
    Write-Error "python3 is required to register the plugin in ~/.claude/"
    exit 1
}
$targetResolved = (Resolve-Path $Target).Path
& $py.Source $RegisterPy honcho-dev $targetResolved
Write-Host ""
Write-Host "Quit Cursor fully and reopen."
