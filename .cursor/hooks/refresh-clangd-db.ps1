# Regenerates compile_commands.json after Source/ C++ edits, then restarts clangd.
# Called from .cursor/hooks.json (afterFileEdit). Fail open: never block the edit.

$ErrorActionPreference = 'Continue'
$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$Ubt = 'D:\Applications\UE_5.7\Engine\Binaries\DotNET\UnrealBuildTool\UnrealBuildTool.exe'
$UProject = Join-Path $ProjectRoot 'Warrior.uproject'
$LockFile = Join-Path $env:TEMP 'warrior-clangd-db.lock'

function Write-HookResult {
    '{}'
}

$raw = [Console]::In.ReadToEnd()
$path = ''
if ($raw) {
    try {
        $evt = $raw | ConvertFrom-Json
        foreach ($name in @('file_path', 'path', 'filePath', 'uri', 'file')) {
            if ($evt.PSObject.Properties[$name] -and $evt.$name) {
                $path = [string]$evt.$name
                break
            }
        }
    } catch {
        Write-HookResult
        exit 0
    }
}

$path = $path -replace '^file:///', '' -replace '/', '\'
if ($path -notmatch '\\Source\\.*\.(h|hpp|cpp|cs)$') {
    Write-HookResult
    exit 0
}

if (Test-Path $LockFile) {
    $age = (Get-Date) - (Get-Item $LockFile).LastWriteTime
    if ($age.TotalSeconds -lt 20) {
        Write-HookResult
        exit 0
    }
}

New-Item -ItemType File -Path $LockFile -Force | Out-Null

if (-not (Test-Path $Ubt)) {
    Write-HookResult
    exit 0
}

& $Ubt -mode=GenerateClangDatabase -project=$UProject WarriorEditor Win64 Development -OutputDir=$ProjectRoot | Out-Null
Get-Process -Name clangd -ErrorAction SilentlyContinue | Stop-Process -Force

Write-HookResult
exit 0
