# TaskFlow Startup Scripts

## 🚀 Quick Start (Recommended)

The easiest way to run TaskFlow:

```powershell
.\quick_start.ps1
```

This will:
- Detect if an emulator is running
- Launch emulator if needed
- Run the app with mock data

---

## 📋 Complete Startup Script

For full control over the startup process:

```powershell
.\start_taskflow.ps1
```

### Options

**Run with backend server:**
```powershell
.\start_taskflow.ps1
```

**Skip backend (mock data only):**
```powershell
.\start_taskflow.ps1 -SkipBackend
```

**Run on Windows desktop:**
```powershell
.\start_taskflow.ps1 -Device windows
```

**Specify emulator:**
```powershell
.\start_taskflow.ps1 -EmulatorId "Pixel_5_API_35"
```

**Custom backend port:**
```powershell
.\start_taskflow.ps1 -BackendPort 4000
```

---

## 📱 Manual Steps

If you prefer to start components manually:

### 1. Start Emulator

```powershell
.\flutter_windows_3.24.5-stable\flutter\bin\flutter.bat emulators --launch Medium_Phone_API_36.0
```

Wait 30-60 seconds for emulator to fully boot.

### 2. Verify Device

```powershell
.\flutter_windows_3.24.5-stable\flutter\bin\flutter.bat devices
```

You should see `emulator-5554` or similar.

### 3. Run Flutter App

```powershell
.\flutter_windows_3.24.5-stable\flutter\bin\flutter.bat run -d emulator-5554
```

For Windows desktop:
```powershell
.\flutter_windows_3.24.5-stable\flutter\bin\flutter.bat run -d windows
```

### 4. (Optional) Start Backend

```powershell
cd backend
npm install  # First time only
node server.js
```

---

## ⚡ Troubleshooting

### Emulator Not Starting
- Open Android Studio → AVD Manager
- Verify emulator exists
- Try cold boot: Right-click → Cold Boot Now

### Build Errors
Clean and rebuild:
```powershell
.\flutter_windows_3.24.5-stable\flutter\bin\flutter.bat clean
.\flutter_windows_3.24.5-stable\flutter\bin\flutter.bat pub get
```

### Port Already in Use
Kill existing processes:
```powershell
# Find process on port 3000
netstat -ano | findstr :3000

# Kill by PID
taskkill /PID <PID> /F
```

### Google Drive Issues
If npm install fails on Google Drive, copy backend to local drive:
```powershell
Copy-Item -Recurse backend C:\temp\taskflow-backend
cd C:\temp\taskflow-backend
npm install
node server.js
```

---

## 📂 Other Scripts

- **`backend/start.ps1`** - Start only backend server
- **`scripts/start_emulator.ps1`** - Start only emulator
- **`scripts/run_stack.ps1`** - Advanced full stack startup

---

## 🎯 Recommended Workflow

**For Development:**
1. Use `quick_start.ps1` for fastest startup
2. App uses mock data by default
3. Hot reload works instantly (press `r` in terminal)

**For Backend Testing:**
1. Start backend separately: `cd backend; node server.js`
2. Run app: `quick_start.ps1`
3. Configure app to use backend API

**For Presentation/Demo:**
1. Use `start_taskflow.ps1` for complete startup
2. Emulator auto-launches
3. Everything ready in 60 seconds

---

## ⌨️ Flutter CLI Commands

Once the app is running, you can use these commands in the terminal:

- **`r`** - Hot reload (instant updates)
- **`R`** - Hot restart (full app restart)
- **`h`** - Show all commands
- **`q`** - Quit
- **`d`** - Detach (keeps app running)

---

## 📊 Expected Startup Times

| Action | Time | Notes |
|--------|------|-------|
| Emulator cold boot | 30-60s | First launch |
| Emulator warm start | 10-15s | Already created |
| Flutter first build | 2-3 min | Downloads dependencies |
| Flutter subsequent runs | 20-30s | Cached builds |
| Hot reload | <1s | During development |
| Backend startup | 2-3s | After npm install |

---

## 🔧 Configuration

### Change Backend URL

Edit `lib/core/services/api_service.dart`:
```dart
static const String baseUrl = 'http://localhost:3000';
```

### Change Mock Data

Edit files in `lib/core/data/`:
- `mock_data.dart` - Projects, tasks, users
- `mock_requests.dart` - Assignment requests
- `mock_notifications.dart` - Notifications

---

## 📖 Additional Resources

- **Main README:** `README.md`
- **Technical Report:** `docs/technical_report.md`
- **API Documentation:** `docs/api_config.md`
- **UI/UX Improvements:** `docs/ui_ux_polish_improvements.md`

---

**Need Help?**  
Check the main README.md or technical documentation in the `docs/` folder.
