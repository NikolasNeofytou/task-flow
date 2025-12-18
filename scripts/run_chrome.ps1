# Run TaskFlow App on Chrome
# This script launches the Flutter app in Chrome browser

Write-Host "Launching TaskFlow App on Chrome..." -ForegroundColor Green

# Try to find Flutter in PATH first
$flutterCmd = Get-Command flutter -ErrorAction SilentlyContinue

if ($flutterCmd) {
    $flutterPath = "flutter"
    Write-Host "[OK] Using Flutter from PATH" -ForegroundColor Cyan
} else {
    # Fallback to hardcoded path if Flutter not in PATH
    $flutterPath = "$env:USERPROFILE\Desktop\flutter_windows_3.38.5-stable\flutter\bin\flutter.bat"
    
    if (-not (Test-Path $flutterPath)) {
        Write-Host "[ERROR] Flutter not found in PATH or at: $flutterPath" -ForegroundColor Red
        Write-Host "Please add Flutter to your PATH or update the script with your Flutter path" -ForegroundColor Yellow
        exit 1
    }
    
    Write-Host "[OK] Flutter path: $flutterPath" -ForegroundColor Cyan
}

# Run the app on Chrome
& $flutterPath run -d chrome

if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Failed to launch app on Chrome" -ForegroundColor Red
    exit 1
}

Write-Host "[OK] App launched successfully on Chrome" -ForegroundColor Green
