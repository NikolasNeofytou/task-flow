<#
.SYNOPSIS
  Kills anything listening on the backend port, then starts the mock backend and the Flutter app.

.PARAMETER BackendPath
  Path to the mock backend folder (where package.json lives).

.PARAMETER BackendPort
  Port for the mock backend (default 4000).

.PARAMETER FlutterSdk
  Path to the Flutter SDK bin directory.

.PARAMETER UseMocks
  Whether to run Flutter with in-app mocks (skips backend calls).

.EXAMPLE
  ./scripts/run_stack.ps1

.EXAMPLE
  ./scripts/run_stack.ps1 -BackendPort 4001 -UseMocks:$false
#>
param(
  [string]$BackendPath = "C:\temp\taskflow-backend",
  [int]$BackendPort = 4000,
  [string]$FlutterSdk = "C:\Users\nikif\Desktop\flutter_windows_3.24.5-stable\flutter\bin",
  [bool]$UseMocks = $false
)

$ErrorActionPreference = 'Stop'

function Stop-Port {
  param([int]$Port)
  $listeners = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue
  if (-not $listeners) { return }
  $pids = $listeners | Select-Object -ExpandProperty OwningProcess -Unique
  foreach ($pid in $pids) {
    try {
      Write-Host "Killing process $pid on port $Port" -ForegroundColor Yellow
      Stop-Process -Id $pid -Force -ErrorAction SilentlyContinue
    } catch {}
  }
}

function Assert-Path {
  param([string]$Path, [string]$Message)
  if (-not (Test-Path $Path)) {
    throw $Message
  }
}

Assert-Path $FlutterSdk "Update -FlutterSdk to your Flutter bin folder (flutter.bat not found)."
Assert-Path $BackendPath "BackendPath '$BackendPath' not found."

$env:Path += ";$FlutterSdk"
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
  throw "flutter not found on PATH; verify FlutterSdk."
}

$backendUrl = "http://localhost:$BackendPort"
$projectRoot = Split-Path -Parent $PSScriptRoot

Write-Host "Stopping any listeners on $BackendPort..." -ForegroundColor Cyan
Stop-Port -Port $BackendPort

Write-Host "Starting mock backend at $backendUrl..." -ForegroundColor Cyan
$env:PORT = $BackendPort
$npmCmd = Get-Command npm -ErrorAction SilentlyContinue
if (-not $npmCmd) { throw "npm not found. Install Node.js or add npm to PATH." }
# Use cmd.exe to execute npm to avoid Win32 invocation issues with npm.ps1
$backendProc = Start-Process -FilePath "cmd.exe" -ArgumentList @("/c","npm","run","dev") -WorkingDirectory $BackendPath -NoNewWindow -PassThru
Write-Host "Backend PID: $($backendProc.Id)" -ForegroundColor Green

$useMocksFlag = if ($UseMocks) { "true" } else { "false" }
Write-Host "Launching Flutter app (USE_MOCKS=$useMocksFlag, API_BASE_URL=$backendUrl)..." -ForegroundColor Cyan
$flutterExe = Join-Path $FlutterSdk "flutter.bat"
if (-not (Test-Path $flutterExe)) { throw "flutter.bat not found at $FlutterSdk. Update -FlutterSdk." }
$flutterProc = Start-Process -FilePath $flutterExe -ArgumentList @(
    "run",
    "--dart-define=API_BASE_URL=$backendUrl",
    "--dart-define=USE_MOCKS=$useMocksFlag"
  ) -WorkingDirectory $projectRoot -NoNewWindow -PassThru
Write-Host "Flutter PID: $($flutterProc.Id)" -ForegroundColor Green

Write-Host "`nTo stop: Stop-Process -Id $($backendProc.Id), $($flutterProc.Id)" -ForegroundColor Yellow
