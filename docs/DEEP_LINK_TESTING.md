# Deep Link Testing Guide

## Quick Test Commands

### Android Testing (ADB)

Make sure your Android device/emulator is connected:
```bash
# Check connected devices
adb devices
```

#### Test Invite Link
```bash
adb shell am start -W -a android.intent.action.VIEW \
  -d "taskflow://invite/123/aBcDeFgHiJkLmNoPqRsTuVwXyZ012345"
```

#### Test Task Link
```bash
adb shell am start -W -a android.intent.action.VIEW \
  -d "taskflow://task/task-1"
```

#### Test Project Link
```bash
adb shell am start -W -a android.intent.action.VIEW \
  -d "taskflow://project/proj-1"
```

#### Test Notification Link
```bash
adb shell am start -W -a android.intent.action.VIEW \
  -d "taskflow://notification/not-1"
```

---

### iOS Testing (Simulator)

```bash
# Test invite link
xcrun simctl openurl booted "taskflow://invite/123/aBcDeFgHiJkLmNoPqRsTuVwXyZ012345"

# Test task link
xcrun simctl openurl booted "taskflow://task/task-1"

# Test project link
xcrun simctl openurl booted "taskflow://project/proj-1"

# Test notification link
xcrun simctl openurl booted "taskflow://notification/not-1"
```

---

## Manual Testing Checklist

### ✅ App State Testing

Test each link type in different app states:

- [ ] **App Closed** (not running)
  1. Force close app
  2. Trigger deep link
  3. Verify app opens to correct screen

- [ ] **App Background** (minimized)
  1. Open app then minimize
  2. Trigger deep link
  3. Verify app navigates to correct screen

- [ ] **App Foreground** (active)
  1. Have app open on any screen
  2. Trigger deep link
  3. Verify navigation occurs

---

### ✅ Invite Link Testing

**Valid Invite:**
1. Generate QR code in Project screen
2. Scan QR with another device
3. Verify InviteAcceptScreen opens
4. Accept invite
5. Verify navigation to project

**Invalid Scenarios:**
- [ ] Expired token (7+ days old)
- [ ] Already used token
- [ ] Invalid token format
- [ ] Non-existent project ID

---

### ✅ Task Link Testing

**Valid Task:**
```
taskflow://task/task-1
```
- [ ] Opens TaskDetailScreen
- [ ] Shows task information
- [ ] Can navigate back

**Invalid Task:**
```
taskflow://task/invalid-id
```
- [ ] Shows error message
- [ ] Doesn't crash app

---

### ✅ Project Link Testing

**Valid Project:**
```
taskflow://project/proj-1
```
- [ ] Opens ProjectDetailScreen
- [ ] Shows project tasks
- [ ] Can interact with project

**Invalid Project:**
```
taskflow://project/999
```
- [ ] Shows error or redirects
- [ ] Doesn't crash

---

### ✅ Notification Link Testing

**Valid Notification:**
```
taskflow://notification/not-1
```
- [ ] Opens NotificationDetailScreen
- [ ] Shows notification content
- [ ] Can navigate to related content

---

## Testing from Different Sources

### Browser
1. Create HTML file with link:
```html
<!DOCTYPE html>
<html>
<body>
  <h1>Test Deep Links</h1>
  <a href="taskflow://invite/123/aBcDeFgHiJkLmNoPqRsTuVwXyZ012345">
    Open Invite Link
  </a>
  <a href="taskflow://task/task-1">Open Task</a>
</body>
</html>
```
2. Open in mobile browser
3. Click links

### SMS/Messaging Apps
1. Send yourself a message with link:
   ```
   Join my project! taskflow://invite/123/abc...
   ```
2. Tap link in message app
3. Verify app opens

### QR Codes
1. Generate QR code for invite
2. Use camera app to scan
3. Tap notification to open link

### Email
1. Send email with deep link
2. Open email on device
3. Tap link

### Notes App
1. Create note with deep link
2. Tap link in notes

---

## Automated Testing Script

### PowerShell (Windows)
```powershell
# test-deeplinks.ps1

$deviceId = adb devices | Select-String "device$" | ForEach-Object { $_.Line.Split()[0] }

if (-not $deviceId) {
    Write-Host "No Android device connected!"
    exit 1
}

Write-Host "Testing on device: $deviceId"

# Test invite link
Write-Host "`nTesting Invite Link..."
adb -s $deviceId shell am start -W -a android.intent.action.VIEW `
  -d "taskflow://invite/123/aBcDeFgHiJkLmNoPqRsTuVwXyZ012345"
Start-Sleep -Seconds 3

# Test task link
Write-Host "`nTesting Task Link..."
adb -s $deviceId shell am start -W -a android.intent.action.VIEW `
  -d "taskflow://task/task-1"
Start-Sleep -Seconds 3

# Test project link
Write-Host "`nTesting Project Link..."
adb -s $deviceId shell am start -W -a android.intent.action.VIEW `
  -d "taskflow://project/proj-1"
Start-Sleep -Seconds 3

# Test notification link
Write-Host "`nTesting Notification Link..."
adb -s $deviceId shell am start -W -a android.intent.action.VIEW `
  -d "taskflow://notification/not-1"

Write-Host "`nAll tests completed!"
```

### Bash (macOS/Linux)
```bash
#!/bin/bash
# test-deeplinks.sh

DEVICE=$(adb devices | grep "device$" | awk '{print $1}')

if [ -z "$DEVICE" ]; then
    echo "No Android device connected!"
    exit 1
fi

echo "Testing on device: $DEVICE"

# Test invite link
echo -e "\nTesting Invite Link..."
adb -s $DEVICE shell am start -W -a android.intent.action.VIEW \
  -d "taskflow://invite/123/aBcDeFgHiJkLmNoPqRsTuVwXyZ012345"
sleep 3

# Test task link
echo -e "\nTesting Task Link..."
adb -s $DEVICE shell am start -W -a android.intent.action.VIEW \
  -d "taskflow://task/task-1"
sleep 3

# Test project link
echo -e "\nTesting Project Link..."
adb -s $DEVICE shell am start -W -a android.intent.action.VIEW \
  -d "taskflow://project/proj-1"
sleep 3

# Test notification link
echo -e "\nTesting Notification Link..."
adb -s $DEVICE shell am start -W -a android.intent.action.VIEW \
  -d "taskflow://notification/not-1"

echo -e "\nAll tests completed!"
```

Run with:
```bash
# Windows
.\scripts\test-deeplinks.ps1

# Mac/Linux
chmod +x ./scripts/test-deeplinks.sh
./scripts/test-deeplinks.sh
```

---

## Debugging Deep Links

### Check Logs
```bash
# Android
adb logcat | grep -i "deep\|taskflow\|intent"

# Flutter
flutter logs | grep -i "deep\|link"
```

### Common Issues

**Link doesn't open app:**
- Check AndroidManifest.xml has intent-filter
- Verify scheme is "taskflow" (lowercase)
- Run `adb shell pm clear com.example.taskflow` to clear defaults

**App opens but doesn't navigate:**
- Check DeepLinkService is initialized in main.dart
- Verify _handleDeepLink is implemented
- Check router configuration

**Invalid link error:**
- Verify URL format matches expected pattern
- Check parsing logic in DeepLinkService
- Validate token length (32 chars for invites)

---

## Verification Checklist

After configuration, verify:

- [x] Android: Intent filter in AndroidManifest.xml
- [x] iOS: CFBundleURLTypes in Info.plist
- [x] iOS: Permission descriptions added
- [x] DeepLinkService initialized in main.dart
- [ ] Navigation handlers implemented
- [ ] Error handling for invalid links
- [ ] Analytics/logging for deep link opens (optional)

---

## Production Considerations

### Universal Links / App Links

For production, consider adding HTTPS support:

**Android (App Links):**
1. Host `.well-known/assetlinks.json` at your domain
2. Add HTTPS intent-filter in AndroidManifest.xml
3. Enable auto-verify

**iOS (Universal Links):**
1. Host `.well-known/apple-app-site-association`
2. Add associated domains in Info.plist
3. Enable Associated Domains capability in Xcode

This allows links like `https://taskflow.app/invite/123` to open the app directly without browser chooser.

---

## Test Results Template

```
Date: ___________
Tester: ___________
Device: ___________
OS Version: ___________

Invite Links:
[ ] Cold start - Pass/Fail
[ ] Background - Pass/Fail
[ ] Foreground - Pass/Fail
[ ] Invalid token - Pass/Fail

Task Links:
[ ] Cold start - Pass/Fail
[ ] Background - Pass/Fail
[ ] Foreground - Pass/Fail

Project Links:
[ ] Cold start - Pass/Fail
[ ] Background - Pass/Fail
[ ] Foreground - Pass/Fail

Notification Links:
[ ] Cold start - Pass/Fail
[ ] Background - Pass/Fail
[ ] Foreground - Pass/Fail

Issues Found:
_________________________________
_________________________________

Notes:
_________________________________
_________________________________
```
