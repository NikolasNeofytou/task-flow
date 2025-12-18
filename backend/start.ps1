# PowerShell script to start the backend server

Write-Host "🚀 Starting TaskFlow Backend Server..." -ForegroundColor Cyan

# Navigate to backend directory
$BackendPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $BackendPath

# Check if .env exists
if (-not (Test-Path ".env")) {
    Write-Host "⚠️  .env file not found. Creating from .env.example..." -ForegroundColor Yellow
    Copy-Item ".env.example" ".env"
    Write-Host "✅ .env file created. Please edit with your configuration if needed." -ForegroundColor Green
}

# Check if node_modules exists
if (-not (Test-Path "node_modules")) {
    Write-Host "📦 Dependencies not found. Please run:" -ForegroundColor Yellow
    Write-Host "   npm install" -ForegroundColor White
    Write-Host ""
    Write-Host "Note: If npm install fails due to Google Drive issues," -ForegroundColor Yellow
    Write-Host "copy the backend folder to a local directory (e.g., C:\taskflow-backend)" -ForegroundColor Yellow
    Write-Host "and run npm install there instead." -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

# Start the server
Write-Host "▶️  Starting server on http://localhost:3000..." -ForegroundColor Green
Write-Host ""
node server.js
