# Test Deep Links on Android
# Run with: .\scripts\test-deeplinks.ps1

Write-Host "🔗 TaskFlow Deep Link Testing" -ForegroundColor Cyan
Write-Host "================================`n" -ForegroundColor Cyan

# Check for connected devices
$deviceId = adb devices | Select-String "device$" | ForEach-Object { $_.Line.Split()[0] } | Select-Object -First 1

if (-not $deviceId) {
    Write-Host "❌ No Android device connected!" -ForegroundColor Red
    Write-Host "Please connect an Android device or start an emulator." -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Device found: $deviceId`n" -ForegroundColor Green

# Test invite link
Write-Host "📨 Testing Invite Link..." -ForegroundColor Yellow
adb -s $deviceId shell am start -W -a android.intent.action.VIEW `
  -d "taskflow://invite/123/aBcDeFgHiJkLmNoPqRsTuVwXyZ012345" 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "   ✅ Invite link triggered" -ForegroundColor Green
} else {
    Write-Host "   ❌ Failed to trigger invite link" -ForegroundColor Red
}
Start-Sleep -Seconds 2

# Test task link
Write-Host "`n📋 Testing Task Link..." -ForegroundColor Yellow
adb -s $deviceId shell am start -W -a android.intent.action.VIEW `
  -d "taskflow://task/task-1" 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "   ✅ Task link triggered" -ForegroundColor Green
} else {
    Write-Host "   ❌ Failed to trigger task link" -ForegroundColor Red
}
Start-Sleep -Seconds 2

# Test project link
Write-Host "`n📁 Testing Project Link..." -ForegroundColor Yellow
adb -s $deviceId shell am start -W -a android.intent.action.VIEW `
  -d "taskflow://project/proj-1" 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "   ✅ Project link triggered" -ForegroundColor Green
} else {
    Write-Host "   ❌ Failed to trigger project link" -ForegroundColor Red
}
Start-Sleep -Seconds 2

# Test notification link
Write-Host "`n🔔 Testing Notification Link..." -ForegroundColor Yellow
adb -s $deviceId shell am start -W -a android.intent.action.VIEW `
  -d "taskflow://notification/not-1" 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "   ✅ Notification link triggered" -ForegroundColor Green
} else {
    Write-Host "   ❌ Failed to trigger notification link" -ForegroundColor Red
}

Write-Host "`n✅ All deep link tests completed!`n" -ForegroundColor Green
Write-Host "Check the app to verify navigation worked correctly." -ForegroundColor Cyan
