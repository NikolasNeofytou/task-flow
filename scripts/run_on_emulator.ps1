# Run TaskFlow App on Android Emulator
# This script starts the emulator and launches the Flutter app on it

Write-Host "Starting Android Emulator and Flutter App..." -ForegroundColor Green
Write-Host ""

# Try to find Flutter in PATH first
$flutterCmd = Get-Command flutter -ErrorAction SilentlyContinue

if ($flutterCmd) {
    $flutterPath = "flutter"
} else {
    # Fallback to hardcoded path
    $flutterPath = "$env:USERPROFILE\Desktop\flutter_windows_3.38.5-stable\flutter\bin\flutter.bat"
    
    if (-not (Test-Path $flutterPath)) {
        Write-Host "[ERROR] Flutter not found in PATH or at hardcoded location" -ForegroundColor Red
        Write-Host "Please add Flutter to your PATH or update the script" -ForegroundColor Yellow
        exit 1
    }
}

# Try to find Android SDK paths
$androidHome = $env:ANDROID_HOME
if (-not $androidHome) {
    $androidHome = $env:ANDROID_SDK_ROOT
}
if (-not $androidHome) {
    # Common default location
    $androidHome = "$env:LOCALAPPDATA\Android\Sdk"
}

$emulatorPath = Join-Path $androidHome "emulator\emulator.exe"

# Default AVD name - users can modify this
$avdName = "Medium_Phone_API_36.0"

# Check if emulator exists
if (-not (Test-Path $emulatorPath)) {
    Write-Host "[ERROR] Emulator not found at: $emulatorPath" -ForegroundColor Red
    Write-Host "Please install Android SDK and set ANDROID_HOME environment variable" -ForegroundColor Yellow
    Write-Host "Or update the script with your Android SDK path" -ForegroundColor Yellow
    exit 1
}

Write-Host "[OK] Emulator path: $emulatorPath" -ForegroundColor Cyan
Write-Host "[OK] AVD: $avdName" -ForegroundColor Cyan
Write-Host "[OK] Flutter path: $flutterPath" -ForegroundColor Cyan
Write-Host ""

# Check if emulator is already running
Write-Host "Checking for running emulators..." -ForegroundColor Yellow
$runningEmulators = & $flutterPath devices | Select-String "emulator"

if ($runningEmulators) {
    Write-Host "[OK] Emulator is already running" -ForegroundColor Green
} else {
    Write-Host "Starting emulator: $avdName..." -ForegroundColor Yellow
    Write-Host "This may take 30-60 seconds..." -ForegroundColor Yellow
    Write-Host "Note: First boot may take 3-5 minutes" -ForegroundColor Yellow
    Write-Host ""
    
    # Start emulator in background
    Start-Process -FilePath $emulatorPath -ArgumentList "-avd", $avdName -WindowStyle Hidden
    
    Write-Host "Waiting for emulator to boot..." -ForegroundColor Yellow
    $maxWaitTime = 300 # 5 minutes
    $waitInterval = 5
    $elapsed = 0
    
    while ($elapsed -lt $maxWaitTime) {
        Start-Sleep -Seconds $waitInterval
        $elapsed += $waitInterval
        
        $devices = & $flutterPath devices | Select-String "emulator"
        if ($devices) {
            Write-Host "[OK] Emulator is ready!" -ForegroundColor Green
            break
        }
        
        Write-Host "  Waiting... ($elapsed/$maxWaitTime seconds)" -ForegroundColor Gray
    }
    
    if ($elapsed -ge $maxWaitTime) {
        Write-Host "[ERROR] Emulator failed to start within $maxWaitTime seconds" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "Launching Flutter app on emulator..." -ForegroundColor Green

# Run the app on emulator
& $flutterPath run

if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Failed to launch app on emulator" -ForegroundColor Red
    exit 1
}

Write-Host "[OK] App launched successfully on emulator" -ForegroundColor Green
