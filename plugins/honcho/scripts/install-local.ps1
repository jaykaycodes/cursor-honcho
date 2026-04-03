# Symlink + register Honcho (~/.claude bridge). Uses bash + register-with-claude.sh (needs Git Bash on Windows).

$ErrorActionPreference = "Stop"

$PluginDir = (Resolve-Path "$PSScriptRoot\..").Path
$Target = Join-Path $env:USERPROFILE ".cursor\plugins\local\honcho"
$Parent = Split-Path $Target
$RegisterSh = Join-Path $PSScriptRoot "register-with-claude.sh"

function Find-Bash {
    $c = Get-Command bash -ErrorAction SilentlyContinue
    if ($c) { return $c.Source }
    foreach ($p in @(
            "$env:ProgramFiles\Git\bin\bash.exe",
            "${env:ProgramFiles(x86)}\Git\bin\bash.exe"
        )) {
        if (Test-Path $p) { return $p }
    }
    return $null
}

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

$bash = Find-Bash
if (-not $bash) {
    Write-Error "bash not found. Install Git for Windows or run ./scripts/install-local.sh from Git Bash."
    exit 1
}
$targetResolved = (Resolve-Path $Target).Path
& $bash $RegisterSh honcho $targetResolved
Write-Host ""
Write-Host "Quit Cursor fully and reopen. Check Settings > Rules and MCP."
