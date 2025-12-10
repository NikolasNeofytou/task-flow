$ErrorActionPreference = 'Stop'

Push-Location $PSScriptRoot

if (-not (Test-Path node_modules)) {
  Write-Host "Installing dependencies..." -ForegroundColor Cyan
  npm install | Out-Null
}

Write-Host "Starting mock backend on http://localhost:4000" -ForegroundColor Green
npm run dev

Pop-Location
