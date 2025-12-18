<#
.SYNOPSIS
  Complete TaskFlow startup script - Emulator, Backend, and Flutter App

.DESCRIPTION
  This script handles the complete startup sequence for TaskFlow:
  1. Checks and starts Android emulator
  2. Starts the backend server (optional)
  3. Launches the Flutter application
  
.PARAMETER SkipBackend
  Skip backend server startup (use mock data only)

.PARAMETER EmulatorId
  Specific emulator ID to launch (default: Medium_Phone_API_36.0)

.PARAMETER BackendPort
  Port for backend server (default: 3000)

.PARAMETER Device
  Device to run on (default: emulator-5554, use 'windows' for desktop)

.EXAMPLE
  .\start_taskflow.ps1
  
.EXAMPLE
  .\start_taskflow.ps1 -SkipBackend
  
.EXAMPLE
  .\start_taskflow.ps1 -Device windows
#>

param(
  [switch]$SkipBackend = $false,
  [string]$EmulatorId = "Medium_Phone_API_36.0",
  [int]$BackendPort = 3000,
  [string]$Device = "emulator-5554"
)

$ErrorActionPreference = 'Continue'

# Colors for output
function Write-Step {
  param([string]$Message)
  Write-Host "`n$Message" -ForegroundColor Cyan
}

function Write-Success {
  param([string]$Message)
  Write-Host "✅ $Message" -ForegroundColor Green
}

function Write-Error {
  param([string]$Message)
  Write-Host "❌ $Message" -ForegroundColor Red
}

function Write-Warning {
  param([string]$Message)
  Write-Host "⚠️  $Message" -ForegroundColor Yellow
}

function Write-Info {
  param([string]$Message)
  Write-Host "ℹ️  $Message" -ForegroundColor Blue
}

# Get script directory
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$FlutterPath = Join-Path $ScriptRoot "flutter_windows_3.24.5-stable\flutter\bin\flutter.bat"
$BackendPath = Join-Path $ScriptRoot "backend"

Write-Host "═══════════════════════════════════════════════" -ForegroundColor Magenta
Write-Host "       🚀 TaskFlow Startup Script 🚀           " -ForegroundColor Magenta
Write-Host "═══════════════════════════════════════════════" -ForegroundColor Magenta

# Step 1: Verify Flutter SDK
Write-Step "Step 1: Verifying Flutter SDK..."
if (-not (Test-Path $FlutterPath)) {
  Write-Error "Flutter SDK not found at: $FlutterPath"
  exit 1
}
Write-Success "Flutter SDK found"

# Step 2: Check for emulator (if not using Windows)
if ($Device -ne "windows") {
  Write-Step "Step 2: Checking Android Emulator..."
  
  # List available emulators
  $emulatorList = & $FlutterPath emulators 2>&1 | Out-String
  
  if ($emulatorList -match $EmulatorId) {
    Write-Success "Emulator '$EmulatorId' found"
    
    # Check if emulator is already running
    $devices = & $FlutterPath devices 2>&1 | Out-String
    
    if ($devices -match "emulator-\d+") {
      Write-Success "Emulator already running"
    } else {
      Write-Info "Launching emulator '$EmulatorId'..."
      Write-Warning "This may take 30-60 seconds. Please wait..."
      
      # Launch emulator in background
      Start-Process -FilePath $FlutterPath -ArgumentList "emulators", "--launch", $EmulatorId -NoNewWindow
      
      # Wait for emulator to boot
      Write-Info "Waiting for emulator to boot..."
      $maxWait = 60
      $waited = 0
      $emulatorReady = $false
      
      while ($waited -lt $maxWait) {
        Start-Sleep -Seconds 2
        $waited += 2
        
        $devices = & $FlutterPath devices 2>&1 | Out-String
        if ($devices -match "emulator-\d+") {
          $emulatorReady = $true
          break
        }
        
        Write-Host "." -NoNewline
      }
      
      Write-Host ""
      
      if ($emulatorReady) {
        Write-Success "Emulator is ready!"
      } else {
        Write-Warning "Emulator may still be starting. Proceeding anyway..."
      }
    }
  } else {
    Write-Error "Emulator '$EmulatorId' not found"
    Write-Info "Available emulators:"
    Write-Host $emulatorList
    exit 1
  }
} else {
  Write-Step "Step 2: Using Windows desktop target"
  $Device = "windows"
}

# Step 3: Backend Server (Optional)
if (-not $SkipBackend) {
  Write-Step "Step 3: Checking Backend Server..."
  
  if (-not (Test-Path $BackendPath)) {
    Write-Warning "Backend folder not found. Skipping backend startup."
    Write-Info "App will use mock data instead."
  } else {
    # Check if backend is already running
    $backendRunning = Get-NetTCPConnection -LocalPort $BackendPort -State Listen -ErrorAction SilentlyContinue
    
    if ($backendRunning) {
      Write-Success "Backend server already running on port $BackendPort"
    } else {
      # Check for node_modules
      $nodeModulesPath = Join-Path $BackendPath "node_modules"
      if (-not (Test-Path $nodeModulesPath)) {
        Write-Warning "Backend dependencies not installed"
        Write-Info "Installing dependencies (this may take a minute)..."
        
        Push-Location $BackendPath
        try {
          npm install 2>&1 | Out-Null
          Write-Success "Dependencies installed"
        } catch {
          Write-Error "Failed to install dependencies: $_"
          Write-Warning "Continuing without backend..."
        }
        Pop-Location
      }
      
      # Start backend server
      if (Test-Path $nodeModulesPath) {
        Write-Info "Starting backend server on port $BackendPort..."
        
        $backendScript = Join-Path $BackendPath "server.js"
        $backendProc = Start-Process -FilePath "node" -ArgumentList $backendScript -WorkingDirectory $BackendPath -WindowStyle Hidden -PassThru
        
        Write-Success "Backend server started (PID: $($backendProc.Id))"
        Write-Info "Backend URL: http://localhost:$BackendPort"
        
        # Wait a moment for server to initialize
        Start-Sleep -Seconds 2
      }
    }
  }
} else {
  Write-Step "Step 3: Skipping backend server (using mock data)"
}

# Step 4: Launch Flutter App
Write-Step "Step 4: Launching Flutter App..."
Write-Info "Building and running on device: $Device"
Write-Warning "First build may take 2-3 minutes. Subsequent runs will be faster."
Write-Host ""

# List connected devices
Write-Info "Connected devices:"
& $FlutterPath devices

Write-Host ""
Write-Info "Starting Flutter app..."
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray

# Run Flutter
$flutterArgs = @("run", "-d", $Device)

& $FlutterPath @flutterArgs

# Cleanup message (shown when Flutter exits)
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Step "TaskFlow Shutdown"

if (-not $SkipBackend) {
  Write-Info "Backend server is still running in the background"
  Write-Info "To stop it, close the terminal or use Task Manager"
}

Write-Host "`n═══════════════════════════════════════════════" -ForegroundColor Magenta
Write-Host "         Thank you for using TaskFlow!          " -ForegroundColor Magenta
Write-Host "═══════════════════════════════════════════════" -ForegroundColor Magenta
