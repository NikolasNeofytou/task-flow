#!/usr/bin/env pwsh
# Start Android Emulator and Run Flutter App
# Usage: .\scripts\start_emulator.ps1

Write-Host "Starting Android Emulator and Flutter App..." -ForegroundColor Cyan
Write-Host ""

# Configuration
$EmulatorPath = "$env:LOCALAPPDATA\Android\Sdk\emulator\emulator.exe"
$AVDName = "Medium_Phone_API_36.0"
$FlutterPath = "C:\Users\nikif\Desktop\flutter_windows_3.24.5-stable\flutter\bin\flutter.bat"
$AdbPath = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"

# Check if emulator exists
if (-not (Test-Path $EmulatorPath)) {
    Write-Host "Error: Android emulator not found at: $EmulatorPath" -ForegroundColor Red
    Write-Host "Please install Android SDK and emulator" -ForegroundColor Yellow
    exit 1
}

# Check if Flutter exists
if (-not (Test-Path $FlutterPath)) {
    Write-Host "Error: Flutter not found at: $FlutterPath" -ForegroundColor Red
    exit 1
}

Write-Host "[OK] Emulator path: $EmulatorPath" -ForegroundColor Green
Write-Host "[OK] AVD: $AVDName" -ForegroundColor Green
Write-Host "[OK] Flutter path: $FlutterPath" -ForegroundColor Green
Write-Host ""

# Check if emulator is already running
$EmulatorProcess = Get-Process -Name "qemu-system-x86_64" -ErrorAction SilentlyContinue
if ($EmulatorProcess) {
    Write-Host "[WARNING] Emulator is already running (PID: $($EmulatorProcess.Id))" -ForegroundColor Yellow
    Write-Host "Killing existing emulator to ensure clean restart..." -ForegroundColor Yellow
    
    # Kill the emulator process
    Stop-Process -Name "qemu-system-x86_64" -Force -ErrorAction SilentlyContinue
    Stop-Process -Name "emulator" -Force -ErrorAction SilentlyContinue
    
    # Kill ADB server to reset connection
    Write-Host "Resetting ADB server..." -ForegroundColor Cyan
    & $AdbPath kill-server 2>&1 | Out-Null
    Start-Sleep -Seconds 2
    & $AdbPath start-server 2>&1 | Out-Null
    
    Write-Host "[OK] Emulator stopped. Starting fresh instance..." -ForegroundColor Green
    Start-Sleep -Seconds 3
}

# Clean Flutter build cache for fresh install
Write-Host "Cleaning Flutter build cache..." -ForegroundColor Cyan
& $FlutterPath clean | Out-Null

Write-Host "Starting emulator: $AVDName..." -ForegroundColor Cyan
Write-Host "This may take 30-60 seconds..." -ForegroundColor Gray

# Start emulator in background
Start-Process -FilePath $EmulatorPath -ArgumentList "-avd", $AVDName -WindowStyle Normal

Write-Host "Waiting for emulator to boot..." -ForegroundColor Cyan
Write-Host "Note: First boot may take 3-5 minutes" -ForegroundColor Gray

# Wait for emulator to be ready (check every 5 seconds, max 5 minutes)
$MaxWaitSeconds = 300
$WaitedSeconds = 0
$DeviceReady = $false

while ($WaitedSeconds -lt $MaxWaitSeconds) {
    Start-Sleep -Seconds 5
    $WaitedSeconds += 5
    
    # Check if device is online and booted
    try {
        $AdbDevices = & $AdbPath devices 2>&1 | Out-String
        if ($AdbDevices -match "emulator-\d+\s+device") {
            # Double-check boot is complete
            $BootComplete = & $AdbPath shell getprop sys.boot_completed 2>&1
            if ($BootComplete -match "1") {
                $DeviceReady = $true
                break
            }
        }
    } catch {
        # ADB not ready yet, continue waiting
    }
    
    Write-Host "  Waiting... ($WaitedSeconds/$MaxWaitSeconds seconds)" -ForegroundColor Gray
}

if (-not $DeviceReady) {
    Write-Host "Error: Emulator failed to start within $MaxWaitSeconds seconds" -ForegroundColor Red
    Write-Host "You can try starting it manually from Android Studio" -ForegroundColor Yellow
    exit 1
}

Write-Host "[OK] Emulator is ready!" -ForegroundColor Green
Write-Host ""

# Uninstall old app version to force fresh install
Write-Host "Uninstalling old app version..." -ForegroundColor Cyan
$PackageName = "com.example.taskflow"
& $AdbPath uninstall $PackageName 2>&1 | Out-Null
Write-Host "[OK] Ready for fresh install" -ForegroundColor Green
Write-Host ""

# Run Flutter app with hot restart
Write-Host "Running Flutter app with fresh build..." -ForegroundColor Cyan
Write-Host ""

# Get the actual emulator device ID
$DeviceList = & $AdbPath devices | Select-String "emulator-\d+"
if ($DeviceList) {
    $DeviceId = $DeviceList.Matches[0].Value
    Write-Host "Using device: $DeviceId" -ForegroundColor Cyan
    & $FlutterPath run -d $DeviceId
} else {
    Write-Host "Warning: Could not detect emulator device ID, trying default..." -ForegroundColor Yellow
    & $FlutterPath run
}

Write-Host ""
Write-Host "Done!" -ForegroundColor Green
