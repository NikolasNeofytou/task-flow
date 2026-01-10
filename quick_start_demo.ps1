# Quick Start TaskFlow Demo
# Simple script to launch both backend and frontend

Write-Host "🚀 Quick Starting TaskFlow..." -ForegroundColor Cyan

# Navigate to project root
cd $PSScriptRoot

# Start backend in background
Write-Host "🔧 Starting Backend..." -ForegroundColor Green
Start-Job -ScriptBlock { cd $args[0]; cd backend; node server.js } -ArgumentList $PWD

# Wait for backend to start
Start-Sleep -Seconds 3

# Start Flutter app
Write-Host "📱 Starting Flutter App..." -ForegroundColor Blue
Write-Host "🔗 App will open at: http://localhost:8080" -ForegroundColor Yellow
Write-Host "📊 Demo Login: demo@taskflow.com / demo123" -ForegroundColor Cyan
Write-Host ""

flutter run -d chrome --web-port 8080