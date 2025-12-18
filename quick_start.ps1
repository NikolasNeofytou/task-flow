# Quick start - Just run the app with mock data
Write-Host "🚀 Quick Starting TaskFlow..." -ForegroundColor Cyan

$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$FlutterPath = Join-Path $ScriptRoot "flutter_windows_3.24.5-stable\flutter\bin\flutter.bat"

# Check for running emulator
$devices = & $FlutterPath devices 2>&1 | Out-String

if ($devices -match "emulator-5554") {
    Write-Host "✅ Emulator found" -ForegroundColor Green
    $device = "emulator-5554"
} elseif ($devices -match "windows") {
    Write-Host "ℹ️  Using Windows desktop" -ForegroundColor Blue
    $device = "windows"
} else {
    Write-Host "❌ No device found. Starting emulator..." -ForegroundColor Yellow
    & $FlutterPath emulators --launch Medium_Phone_API_36.0
    Write-Host "⏳ Waiting 30 seconds for emulator..." -ForegroundColor Yellow
    Start-Sleep -Seconds 30
    $device = "emulator-5554"
}

Write-Host "▶️  Running TaskFlow on $device..." -ForegroundColor Green
& $FlutterPath run -d $device
