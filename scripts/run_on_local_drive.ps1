# Script to copy project to C: drive and run Flutter app
# This avoids Google Drive symlink issues

$ErrorActionPreference = "Stop"

# Configuration
$sourcePath = "g:\My Drive\university\semester_7\human computer interaction\taskflow_app"
$destPath = "C:\taskflow_app"
$flutterPath = "C:\Users\nikif\Desktop\flutter_windows_3.24.5-stable\flutter\bin\flutter.bat"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  TaskFlow - Run on Local Drive" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Flutter exists
if (-not (Test-Path $flutterPath)) {
    Write-Host "ERROR: Flutter not found at: $flutterPath" -ForegroundColor Red
    Write-Host "Please update the `$flutterPath variable in this script" -ForegroundColor Yellow
    exit 1
}

# Check if destination exists
if (Test-Path $destPath) {
    Write-Host "Found existing project at C:\taskflow_app" -ForegroundColor Yellow
    $response = Read-Host "Do you want to update it with latest changes? (y/n)"
    
    if ($response -eq "y") {
        Write-Host "Updating project..." -ForegroundColor Cyan
        
        # Copy only source files (exclude build folders)
        $excludeDirs = @("build", ".dart_tool", "windows\flutter\ephemeral", "android\build", "ios\build", "flutter_windows_3.24.5-stable")
        
        Write-Host "   Copying lib folder..." -ForegroundColor Gray
        Copy-Item -Path "$sourcePath\lib" -Destination "$destPath\lib" -Recurse -Force
        
        Write-Host "   Copying docs folder..." -ForegroundColor Gray
        Copy-Item -Path "$sourcePath\docs" -Destination "$destPath\docs" -Recurse -Force
        
        Write-Host "   Copying assets folder..." -ForegroundColor Gray
        if (Test-Path "$sourcePath\assets") {
            Copy-Item -Path "$sourcePath\assets" -Destination "$destPath\assets" -Recurse -Force
        }
        
        Write-Host "   Copying config files..." -ForegroundColor Gray
        Copy-Item -Path "$sourcePath\pubspec.yaml" -Destination "$destPath\pubspec.yaml" -Force
        Copy-Item -Path "$sourcePath\pubspec.lock" -Destination "$destPath\pubspec.lock" -Force
        Copy-Item -Path "$sourcePath\analysis_options.yaml" -Destination "$destPath\analysis_options.yaml" -Force
        Copy-Item -Path "$sourcePath\README.md" -Destination "$destPath\README.md" -Force
        Copy-Item -Path "$sourcePath\QUICKSTART.md" -Destination "$destPath\QUICKSTART.md" -Force
        
        Write-Host "Project updated!" -ForegroundColor Green
    } else {
        Write-Host "Using existing project" -ForegroundColor Cyan
    }
} else {
    Write-Host "Copying project to C:\taskflow_app..." -ForegroundColor Cyan
    Write-Host "   This may take a minute..." -ForegroundColor Gray
    
    # Create destination directory
    New-Item -ItemType Directory -Path $destPath -Force | Out-Null
    
    # Copy essential folders
    $folders = @("lib", "docs", "assets", "test", "android", "ios", "web", "windows")
    foreach ($folder in $folders) {
        if (Test-Path "$sourcePath\$folder") {
            Write-Host "   Copying $folder..." -ForegroundColor Gray
            Copy-Item -Path "$sourcePath\$folder" -Destination "$destPath\$folder" -Recurse -Force
        }
    }
    
    # Copy files
    $files = @("pubspec.yaml", "pubspec.lock", "analysis_options.yaml", ".gitignore", ".metadata", "README.md", "QUICKSTART.md")
    foreach ($file in $files) {
        if (Test-Path "$sourcePath\$file") {
            Copy-Item -Path "$sourcePath\$file" -Destination "$destPath\$file" -Force
        }
    }
    
    Write-Host "Project copied successfully!" -ForegroundColor Green
}

Write-Host ""
Write-Host "Running flutter pub get..." -ForegroundColor Cyan
cd $destPath
& $flutterPath pub get

Write-Host ""
Write-Host "Launching app on Windows..." -ForegroundColor Cyan
Write-Host ""

# Run the app
& $flutterPath run -d windows

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Done! Press any key to exit..." -ForegroundColor Cyan
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
