# TaskFlow Services Startup Script
# Starts backend and frontend services with process management

Write-Host "Starting TaskFlow Services..." -ForegroundColor Green

# Kill existing processes
Write-Host "Cleaning up existing processes..." -ForegroundColor Yellow
$existingDart = Get-Process -Name "dart" -ErrorAction SilentlyContinue
$existingNode = Get-Process -Name "node" -ErrorAction SilentlyContinue

if ($existingDart) {
    Stop-Process -Name "dart" -Force
    Write-Host "Stopped existing Dart processes" -ForegroundColor Yellow
}

if ($existingNode) {
    Stop-Process -Name "node" -Force
    Write-Host "Stopped existing Node processes" -ForegroundColor Yellow
}

# Wait for cleanup
Start-Sleep -Seconds 2

# Start backend service
Write-Host "Starting Node.js backend..." -ForegroundColor Cyan
Set-Location "backend"
$backendJob = Start-Job -ScriptBlock {
    Set-Location $using:PWD
    node server.js
}
Set-Location ".."

# Wait for backend to initialize
Start-Sleep -Seconds 5

# Start Flutter frontend
Write-Host "Starting Flutter frontend..." -ForegroundColor Magenta
$frontendJob = Start-Job -ScriptBlock {
    Set-Location $using:PWD
    flutter run -d chrome --web-port 8082
}

# Wait for services to start
Write-Host "Waiting for services to initialize..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Check job status
Write-Host "" 
Write-Host "Service Status:" -ForegroundColor Green
Write-Host "Backend Job State: " -NoNewline
$backendState = (Get-Job -Id $backendJob.Id).State
Write-Host $backendState -ForegroundColor $(if($backendState -eq "Running") {"Green"} else {"Red"})

Write-Host "Frontend Job State: " -NoNewline
$frontendState = (Get-Job -Id $frontendJob.Id).State
Write-Host $frontendState -ForegroundColor $(if($frontendState -eq "Running") {"Green"} else {"Red"})

# Display URLs
Write-Host "" 
Write-Host "Service URLs:" -ForegroundColor Green
Write-Host "Backend:  http://localhost:3000" -ForegroundColor Cyan
Write-Host "Frontend: http://localhost:8082" -ForegroundColor Cyan

# Test backend connectivity
Write-Host "" 
Write-Host "Testing backend connectivity..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000/api/status" -TimeoutSec 10 -ErrorAction Stop
    Write-Host "Backend is responsive (Status: $($response.StatusCode))" -ForegroundColor Green
}
catch {
    Write-Host "Backend not responding yet, may still be starting..." -ForegroundColor Red
}

# Launch browser
Write-Host "" 
Write-Host "Opening browser..." -ForegroundColor Cyan
Start-Process "http://localhost:8082"

Write-Host "" 
Write-Host "Services started! Check the browser window." -ForegroundColor Green
Write-Host "Press Ctrl+C to stop services or close this window." -ForegroundColor Yellow

# Keep script running to monitor jobs
try {
    while ($true) {
        Start-Sleep -Seconds 30
        $backend = Get-Job -Id $backendJob.Id
        $frontend = Get-Job -Id $frontendJob.Id
        
        if ($backend.State -ne "Running" -or $frontend.State -ne "Running") {
            Write-Host "Service failure detected!" -ForegroundColor Red
            Write-Host "Backend: $($backend.State), Frontend: $($frontend.State)" -ForegroundColor Red
            break
        }
    }
}
finally {
    Write-Host "" 
    Write-Host "Cleaning up jobs..." -ForegroundColor Yellow
    Remove-Job $backendJob -Force -ErrorAction SilentlyContinue
    Remove-Job $frontendJob -Force -ErrorAction SilentlyContinue
}