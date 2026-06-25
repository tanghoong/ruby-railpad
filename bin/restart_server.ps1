param(
    [int]$Port = 3000,
    [switch]$NoStart
)

$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $PSScriptRoot
$pidFile = Join-Path $projectRoot "tmp\pids\server.pid"

Set-Location $projectRoot

function Stop-ProcessIfRunning {
    param(
        [int]$ProcessId,
        [string]$Reason
    )

    if ($ProcessId -le 0) {
        return
    }

    $process = Get-Process -Id $ProcessId -ErrorAction SilentlyContinue
    if (-not $process) {
        return
    }

    Write-Host "Stopping PID $ProcessId ($Reason)..."
    Stop-Process -Id $ProcessId -Force
}

if (Test-Path $pidFile) {
    $pidValue = (Get-Content $pidFile | Select-Object -First 1).Trim()

    if ($pidValue -match '^\d+$') {
        Stop-ProcessIfRunning -ProcessId ([int]$pidValue) -Reason "from tmp/pids/server.pid"
    } else {
        Write-Host "Ignoring invalid PID file contents: $pidValue"
    }

    Remove-Item $pidFile -Force -ErrorAction SilentlyContinue
}

$listeners = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue |
    Select-Object -ExpandProperty OwningProcess -Unique

foreach ($listenerPid in $listeners) {
    Stop-ProcessIfRunning -ProcessId $listenerPid -Reason "listening on port $Port"
}

if ($NoStart) {
    Write-Host "Stopped existing Rails server processes. Skipping restart because -NoStart was provided."
    exit 0
}

if (-not (Get-Command bundle -ErrorAction SilentlyContinue)) {
    throw "Could not find 'bundle' on PATH. Open the terminal with Ruby/Bundler configured, then run the script again."
}

Write-Host "Starting Rails server on port $Port..."
& bundle exec rails server -p $Port