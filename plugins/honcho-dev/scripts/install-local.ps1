# Symlink + register Honcho Dev (runs plugins/honcho/scripts/register-with-claude.sh).

$ErrorActionPreference = "Stop"

$PluginDir = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..\..")).Path
$RegisterSh = Join-Path $RepoRoot "plugins\honcho\scripts\register-with-claude.sh"
$Target = Join-Path $env:USERPROFILE ".cursor\plugins\local\honcho-dev"

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

if (-not (Test-Path $RegisterSh)) {
    Write-Error "Missing $RegisterSh — use the full monorepo (plugins/honcho + plugins/honcho-dev)."
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

$bash = Find-Bash
if (-not $bash) {
    Write-Error "bash not found. Install Git for Windows or run ./scripts/install-local.sh from Git Bash."
    exit 1
}
$targetResolved = (Resolve-Path $Target).Path
& $bash $RegisterSh honcho-dev $targetResolved
Write-Host ""
Write-Host "Quit Cursor fully and reopen."
