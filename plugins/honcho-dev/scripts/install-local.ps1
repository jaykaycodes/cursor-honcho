# Symlink honcho-dev only into Cursor local plugins.
$PluginDir = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$Target = Join-Path $HOME ".cursor\plugins\local\honcho-dev"

if (-not (Test-Path $PluginDir)) {
    Write-Error "Could not resolve plugin directory"
    exit 1
}

New-Item -ItemType Directory -Force -Path (Split-Path $Target) | Out-Null
if (Test-Path $Target) { Remove-Item -Recurse -Force $Target }
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
Write-Host "Reload Cursor (Developer: Reload Window), or fully quit and reopen."
Write-Host "Note: local plugins do not show in the Marketplace list — check Rules / agent skills for Honcho Dev."
