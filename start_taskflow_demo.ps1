#!/usr/bin/env pwsh

# TaskFlow Demo Startup Script
# This script automatically starts the backend, frontend, and opens the app

Write-Host "🚀 Starting TaskFlow Demo Application..." -ForegroundColor Cyan
Write-Host "=" * 50 -ForegroundColor Gray

# Kill any existing processes
Write-Host "🧹 Cleaning up existing processes..." -ForegroundColor Yellow
Stop-Process -Name node -Force -ErrorAction SilentlyContinue
Stop-Process -Name chrome -Force -ErrorAction SilentlyContinue

Start-Sleep -Seconds 2

# Start Backend Server
Write-Host "🔧 Starting Backend Server..." -ForegroundColor Green
Start-Process powershell -ArgumentList "-Command", "cd '$PSScriptRoot\backend'; node server.js" -WindowStyle Minimized

# Wait for backend to start
Write-Host "⏳ Waiting for backend to initialize..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# Test if backend is running
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000" -Method GET -TimeoutSec 5 -ErrorAction Stop
    Write-Host "✅ Backend server is running on port 3000" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Backend might still be starting..." -ForegroundColor Yellow
}

# Start Flutter App
Write-Host "📱 Starting Flutter Application..." -ForegroundColor Blue
cd $PSScriptRoot
Start-Process powershell -ArgumentList "-Command", "flutter run -d chrome --web-port 8080" -WindowStyle Minimized

# Wait for Flutter to compile and start
Write-Host "⏳ Waiting for Flutter app to compile and start..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

# Open browser to the app
$appUrl = "http://localhost:8080"
Write-Host "🌐 Opening browser to: $appUrl" -ForegroundColor Magenta
Start-Process $appUrl

Write-Host ""
Write-Host "🎉 TaskFlow Demo is starting!" -ForegroundColor Green
Write-Host "📊 Demo Credentials:" -ForegroundColor Cyan
Write-Host "   Email: demo@taskflow.com" -ForegroundColor White
Write-Host "   Password: demo123" -ForegroundColor White
Write-Host ""
Write-Host "🔗 Application URL: $appUrl" -ForegroundColor Cyan
Write-Host "🔧 Backend API: http://localhost:3000" -ForegroundColor Cyan
Write-Host ""
Write-Host "Press Ctrl+C to stop all services" -ForegroundColor Yellow
Write-Host "=" * 50 -ForegroundColor Gray

# Keep script running and monitor
try {
    while ($true) {
        Start-Sleep -Seconds 30
        # Check if processes are still running
        $backendRunning = Get-Process -Name node -ErrorAction SilentlyContinue
        if (-not $backendRunning) {
            Write-Host "⚠️  Backend process stopped unexpectedly" -ForegroundColor Red
            break
        }
    }
} catch {
    Write-Host "🛑 Stopping TaskFlow Demo..." -ForegroundColor Red
}

# Cleanup on exit
Write-Host "🧹 Cleaning up processes..." -ForegroundColor Yellow
Stop-Process -Name node -Force -ErrorAction SilentlyContinue
Write-Host "✅ TaskFlow Demo stopped" -ForegroundColor Green