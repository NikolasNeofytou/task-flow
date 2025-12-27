#!/usr/bin/env pwsh
# Build Release Script for TaskFlow
# Builds production-ready APK and App Bundle for Android

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('development', 'staging', 'production')]
    [string]$Environment = 'production',
    
    [Parameter(Mandatory=$false)]
    [ValidateSet('apk', 'appbundle', 'both')]
    [string]$BuildType = 'both',
    
    [Parameter(Mandatory=$false)]
    [switch]$Obfuscate,
    
    [Parameter(Mandatory=$false)]
    [switch]$SplitPerAbi
)

$ErrorActionPreference = "Stop"

Write-Host "🚀 TaskFlow Release Build Script" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# Configuration
$dartDefines = @(
    "--dart-define=ENV=$Environment"
)

# Add feature flags based on environment
if ($Environment -eq 'production') {
    $dartDefines += "--dart-define=ENABLE_LOGGING=false"
    $dartDefines += "--dart-define=ENABLE_ANALYTICS=true"
    $dartDefines += "--dart-define=ENABLE_CRASH_REPORTING=true"
} elseif ($Environment -eq 'staging') {
    $dartDefines += "--dart-define=ENABLE_LOGGING=true"
    $dartDefines += "--dart-define=ENABLE_ANALYTICS=true"
    $dartDefines += "--dart-define=API_BASE_URL=https://staging-api.taskflow.app"
} else {
    $dartDefines += "--dart-define=ENABLE_LOGGING=true"
    $dartDefines += "--dart-define=ENABLE_ANALYTICS=false"
}

# Add obfuscation flags
$buildFlags = @()
if ($Obfuscate) {
    Write-Host "🔒 Obfuscation enabled" -ForegroundColor Yellow
    $buildFlags += "--obfuscate"
    $buildFlags += "--split-debug-info=build/debug-info"
}

Write-Host "📋 Build Configuration:" -ForegroundColor Green
Write-Host "   Environment: $Environment"
Write-Host "   Build Type: $BuildType"
Write-Host "   Obfuscate: $Obfuscate"
Write-Host "   Split Per ABI: $SplitPerAbi"
Write-Host ""

# Clean build
Write-Host "🧹 Cleaning previous builds..." -ForegroundColor Yellow
flutter clean | Out-Null
Write-Host "✓ Clean complete" -ForegroundColor Green
Write-Host ""

# Get dependencies
Write-Host "📦 Getting dependencies..." -ForegroundColor Yellow
flutter pub get | Out-Null
Write-Host "✓ Dependencies fetched" -ForegroundColor Green
Write-Host ""

# Build APK
if ($BuildType -eq 'apk' -or $BuildType -eq 'both') {
    Write-Host "🔨 Building release APK..." -ForegroundColor Cyan
    
    $apkArgs = @('build', 'apk', '--release') + $dartDefines + $buildFlags
    
    if ($SplitPerAbi) {
        $apkArgs += '--split-per-abi'
        Write-Host "   Splitting APK per ABI" -ForegroundColor Yellow
    }
    
    $apkBuild = & flutter $apkArgs 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ APK build successful!" -ForegroundColor Green
        
        # Find and display APK locations
        $apkPath = "build\app\outputs\flutter-apk\"
        if (Test-Path $apkPath) {
            Write-Host "📦 APK files:" -ForegroundColor Green
            Get-ChildItem -Path $apkPath -Filter "*.apk" | ForEach-Object {
                $size = [math]::Round($_.Length / 1MB, 2)
                Write-Host "   $($_.Name) ($size MB)" -ForegroundColor White
            }
        }
    } else {
        Write-Host "❌ APK build failed!" -ForegroundColor Red
        Write-Host $apkBuild -ForegroundColor Red
        exit 1
    }
    Write-Host ""
}

# Build App Bundle
if ($BuildType -eq 'appbundle' -or $BuildType -eq 'both') {
    Write-Host "🔨 Building release App Bundle..." -ForegroundColor Cyan
    
    $aabArgs = @('build', 'appbundle', '--release') + $dartDefines + $buildFlags
    
    $aabBuild = & flutter $aabArgs 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ App Bundle build successful!" -ForegroundColor Green
        
        # Find and display AAB location
        $aabPath = "build\app\outputs\bundle\release\app-release.aab"
        if (Test-Path $aabPath) {
            $size = [math]::Round((Get-Item $aabPath).Length / 1MB, 2)
            Write-Host "📦 App Bundle:" -ForegroundColor Green
            Write-Host "   app-release.aab ($size MB)" -ForegroundColor White
        }
    } else {
        Write-Host "❌ App Bundle build failed!" -ForegroundColor Red
        Write-Host $aabBuild -ForegroundColor Red
        exit 1
    }
    Write-Host ""
}

# Summary
Write-Host "================================" -ForegroundColor Cyan
Write-Host "✅ Build completed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "📍 Output locations:" -ForegroundColor Cyan

if ($BuildType -eq 'apk' -or $BuildType -eq 'both') {
    Write-Host "   APK: build\app\outputs\flutter-apk\" -ForegroundColor White
}

if ($BuildType -eq 'appbundle' -or $BuildType -eq 'both') {
    Write-Host "   AAB: build\app\outputs\bundle\release\" -ForegroundColor White
}

if ($Obfuscate) {
    Write-Host "   Debug Info: build\debug-info\" -ForegroundColor White
    Write-Host ""
    Write-Host "⚠️  Keep debug info for crash analysis!" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🎉 Ready to deploy to Google Play Store!" -ForegroundColor Green
