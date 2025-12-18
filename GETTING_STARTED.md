# TaskFlow - Complete Startup Documentation

## 📋 Table of Contents

1. [Quick Start (30 seconds)](#quick-start)
2. [Full Startup Process](#full-startup-process)
3. [Development Commands](#development-commands)
4. [Troubleshooting](#troubleshooting)
5. [Manual Startup](#manual-startup)

---

## 🚀 Quick Start

**The absolute fastest way to run TaskFlow:**

```powershell
.\quick_start.ps1
```

That's it! The script will:
- ✅ Detect available devices
- ✅ Launch emulator if needed
- ✅ Start the app with mock data

**Expected time:** 60 seconds (first time: 2-3 minutes for build)

---

## 📦 Full Startup Process

For complete control and optional backend:

### Option 1: Complete Startup (Recommended for Demos)

```powershell
.\start_taskflow.ps1
```

**What it does:**
1. ✅ Verifies Flutter SDK
2. ✅ Checks and launches Android emulator
3. ✅ Starts backend server (if available)
4. ✅ Launches Flutter app

**With options:**

```powershell
# Skip backend (mock data only)
.\start_taskflow.ps1 -SkipBackend

# Run on Windows desktop instead
.\start_taskflow.ps1 -Device windows

# Custom emulator
.\start_taskflow.ps1 -EmulatorId "Pixel_5_API_35"

# Custom backend port
.\start_taskflow.ps1 -BackendPort 4000
```

### Option 2: Development Helper Commands

```powershell
# Check what's available
.\dev.ps1 devices
.\dev.ps1 emulators

# Clean build (fixes many issues)
.\dev.ps1 clean

# Analyze code
.\dev.ps1 analyze

# Run tests
.\dev.ps1 test

# Format code
.\dev.ps1 format

# Check Flutter setup
.\dev.ps1 doctor

# See all commands
.\dev.ps1 help
```

---

## ⚡ Development Commands

### Common Workflows

**Start fresh development session:**
```powershell
.\dev.ps1 clean
.\quick_start.ps1
```

**Before committing code:**
```powershell
.\dev.ps1 format
.\dev.ps1 analyze
.\dev.ps1 test
```

**Check your setup:**
```powershell
.\dev.ps1 doctor
.\dev.ps1 devices
```

---

## 🔧 Troubleshooting

### Issue: Emulator won't start

**Solution 1: Check if it exists**
```powershell
.\dev.ps1 emulators
```
If missing, create one in Android Studio → AVD Manager.

**Solution 2: Cold boot**
- Open Android Studio → AVD Manager
- Right-click emulator → "Cold Boot Now"
- Wait 60 seconds, then run `.\quick_start.ps1`

**Solution 3: Use Windows desktop**
```powershell
.\start_taskflow.ps1 -Device windows
```

### Issue: Build fails

**Solution 1: Clean build**
```powershell
.\dev.ps1 clean
```
Then restart the app.

**Solution 2: Check Flutter setup**
```powershell
.\dev.ps1 doctor
```
Fix any issues reported with [✗] marks.

**Solution 3: Reinstall dependencies**
```powershell
cd "g:\My Drive\university\semester_7\human computer interaction\taskflow_app"
.\flutter_windows_3.24.5-stable\flutter\bin\flutter.bat pub get
```

### Issue: Port 3000 already in use

**Solution: Kill the process**
```powershell
# Find what's using port 3000
netstat -ano | findstr :3000

# Kill by PID (replace XXXX with actual PID)
taskkill /PID XXXX /F
```

Or skip backend entirely:
```powershell
.\start_taskflow.ps1 -SkipBackend
```

### Issue: "Gradle build failed"

**Solution 1: Clean and rebuild**
```powershell
.\dev.ps1 clean
.\quick_start.ps1
```

**Solution 2: Check Java version**
```powershell
java -version
```
Should be Java 17 or higher.

**Solution 3: Delete build folder**
```powershell
Remove-Item -Recurse -Force "android\app\build"
Remove-Item -Recurse -Force "build"
```

### Issue: Backend npm install fails on Google Drive

**Solution: Copy to local drive**
```powershell
Copy-Item -Recurse backend C:\temp\taskflow-backend
cd C:\temp\taskflow-backend
npm install
node server.js
```

Then in another terminal:
```powershell
.\quick_start.ps1
```

---

## 🔨 Manual Startup

If scripts don't work, here's the complete manual process:

### Step 1: Start Emulator

```powershell
cd "g:\My Drive\university\semester_7\human computer interaction\taskflow_app"
.\flutter_windows_3.24.5-stable\flutter\bin\flutter.bat emulators --launch Medium_Phone_API_36.0
```

**Wait 30-60 seconds** for emulator to fully boot.

### Step 2: Verify Device

```powershell
.\flutter_windows_3.24.5-stable\flutter\bin\flutter.bat devices
```

Expected output:
```
sdk gphone64 x86 64 (mobile) • emulator-5554 • android-x64    • Android 16 (API 36)
```

### Step 3: Run App

```powershell
.\flutter_windows_3.24.5-stable\flutter\bin\flutter.bat run -d emulator-5554
```

**First time:** Build takes 2-3 minutes  
**Subsequent runs:** 20-30 seconds

### Step 4: (Optional) Start Backend

Open **new terminal**:
```powershell
cd "g:\My Drive\university\semester_7\human computer interaction\taskflow_app\backend"
npm install  # First time only
node server.js
```

---

## ⌨️ Hot Reload Commands

Once the app is running, use these keyboard shortcuts:

| Key | Action | Description |
|-----|--------|-------------|
| `r` | Hot Reload | Instant updates (use this!) |
| `R` | Hot Restart | Full app restart |
| `h` | Help | Show all commands |
| `q` | Quit | Stop the app |
| `d` | Detach | Keep app running, exit terminal |
| `s` | Screenshot | Save screenshot to file |
| `w` | Widget Inspector | Debug UI layout |

**Pro Tip:** Use `r` for instant updates while developing!

---

## 📊 Performance Expectations

| Operation | First Time | Subsequent |
|-----------|------------|------------|
| Emulator boot | 60s | 15s (if suspended) |
| App build | 2-3 min | 20-30s |
| Hot reload | - | <1s ⚡ |
| Hot restart | - | 3-5s |
| Backend start | 2-3s | 1-2s |

---

## 🎯 Recommended Workflows

### For Quick Testing
```powershell
.\quick_start.ps1
# Press 'r' for hot reload during development
# Press 'q' to quit
```

### For Full Stack Development
**Terminal 1:**
```powershell
cd backend
node server.js
```

**Terminal 2:**
```powershell
.\quick_start.ps1
```

### For Demo/Presentation
```powershell
.\start_taskflow.ps1
```
Everything starts automatically!

---

## 📁 Available Scripts

| Script | Purpose | Use When |
|--------|---------|----------|
| `quick_start.ps1` | Fast app startup | Daily development |
| `start_taskflow.ps1` | Complete startup | Demos, presentations |
| `dev.ps1` | Development tools | Cleaning, testing, analyzing |
| `backend/start.ps1` | Backend only | Backend development |

---

## 🔗 Related Documentation

- **Main README:** [`README.md`](README.md)
- **Technical Report:** [`docs/technical_report.md`](docs/technical_report.md)
- **UI/UX Polish:** [`docs/ui_ux_polish_improvements.md`](docs/ui_ux_polish_improvements.md)
- **API Config:** [`docs/api_config.md`](docs/api_config.md)

---

## 💡 Tips & Tricks

### Speed Up Development

1. **Use hot reload** (`r` key) - Instant updates without rebuilding
2. **Keep emulator running** - Don't close it between sessions
3. **Use `flutter clean` sparingly** - Only when really needed
4. **Run on Windows** - Faster than emulator for UI work

### Save Time

1. **Create shortcuts:**
   ```powershell
   # Add to your PowerShell profile
   function Start-TaskFlow { .\quick_start.ps1 }
   Set-Alias -Name tf -Value Start-TaskFlow
   ```
   Then just type: `tf`

2. **Keep terminals open:**
   - Terminal 1: Backend (keeps running)
   - Terminal 2: Flutter app (for hot reload)

3. **Use VS Code integrated terminal:**
   - `Ctrl+`` to open
   - Hot reload works the same way

### Debug Effectively

1. **Check logs in real-time:**
   - App logs show in terminal
   - Backend logs show in backend terminal

2. **Use Flutter DevTools:**
   - Opens automatically with app
   - Inspect widgets, performance, network

3. **Quick error fixes:**
   ```powershell
   .\dev.ps1 clean    # First try this
   .\dev.ps1 analyze  # Then check for code issues
   ```

---

## ❓ Still Having Issues?

1. **Check Flutter setup:**
   ```powershell
   .\dev.ps1 doctor
   ```

2. **Verify file paths:**
   - Make sure you're in the project root
   - Check that `flutter_windows_3.24.5-stable` folder exists

3. **Try complete reset:**
   ```powershell
   .\dev.ps1 clean
   Remove-Item -Recurse -Force "build", ".dart_tool"
   .\flutter_windows_3.24.5-stable\flutter\bin\flutter.bat pub get
   .\quick_start.ps1
   ```

4. **Check documentation:**
   - Main README for project overview
   - Technical report for architecture details
   - Issue tracker (if available)

---

**Last Updated:** December 9, 2025  
**TaskFlow Version:** 1.0.0  
**Flutter Version:** 3.24.5
