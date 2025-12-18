# TaskFlow Development Helper Script
# Common commands for development workflow

param(
    [Parameter(Position=0)]
    [ValidateSet('build', 'clean', 'test', 'analyze', 'format', 'devices', 'emulators', 'doctor', 'help')]
    [string]$Command = 'help'
)

$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$FlutterPath = Join-Path $ScriptRoot "flutter_windows_3.24.5-stable\flutter\bin\flutter.bat"

function Show-Help {
    Write-Host "═══════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "    TaskFlow Development Helper Commands       " -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Usage: .\dev.ps1 <command>" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Commands:" -ForegroundColor Green
    Write-Host "  build      - Build the app (checks for errors)" -ForegroundColor White
    Write-Host "  clean      - Clean build cache (fixes many issues)" -ForegroundColor White
    Write-Host "  test       - Run all tests" -ForegroundColor White
    Write-Host "  analyze    - Analyze code for issues" -ForegroundColor White
    Write-Host "  format     - Format all Dart files" -ForegroundColor White
    Write-Host "  devices    - List connected devices" -ForegroundColor White
    Write-Host "  emulators  - List available emulators" -ForegroundColor White
    Write-Host "  doctor     - Check Flutter installation" -ForegroundColor White
    Write-Host "  help       - Show this help message" -ForegroundColor White
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor Green
    Write-Host "  .\dev.ps1 clean" -ForegroundColor Gray
    Write-Host "  .\dev.ps1 devices" -ForegroundColor Gray
    Write-Host "  .\dev.ps1 analyze" -ForegroundColor Gray
    Write-Host ""
}

switch ($Command) {
    'build' {
        Write-Host "🔨 Building TaskFlow..." -ForegroundColor Cyan
        & $FlutterPath build apk --debug
    }
    'clean' {
        Write-Host "🧹 Cleaning build cache..." -ForegroundColor Cyan
        & $FlutterPath clean
        Write-Host "✅ Clean complete. Run app to rebuild." -ForegroundColor Green
    }
    'test' {
        Write-Host "🧪 Running tests..." -ForegroundColor Cyan
        & $FlutterPath test
    }
    'analyze' {
        Write-Host "🔍 Analyzing code..." -ForegroundColor Cyan
        & $FlutterPath analyze
    }
    'format' {
        Write-Host "✨ Formatting code..." -ForegroundColor Cyan
        & $FlutterPath format lib/ test/
        Write-Host "✅ Code formatted" -ForegroundColor Green
    }
    'devices' {
        Write-Host "📱 Connected devices:" -ForegroundColor Cyan
        & $FlutterPath devices
    }
    'emulators' {
        Write-Host "📱 Available emulators:" -ForegroundColor Cyan
        & $FlutterPath emulators
    }
    'doctor' {
        Write-Host "🏥 Checking Flutter installation..." -ForegroundColor Cyan
        & $FlutterPath doctor -v
    }
    'help' {
        Show-Help
    }
    default {
        Write-Host "❌ Unknown command: $Command" -ForegroundColor Red
        Show-Help
    }
}
