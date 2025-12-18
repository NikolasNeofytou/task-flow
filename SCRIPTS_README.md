# 🚀 TaskFlow Startup Scripts - Summary

## Created Scripts

All scripts are now ready in the project root:

### 1. `quick_start.ps1` ⭐ **RECOMMENDED**
**The fastest way to run TaskFlow!**

```powershell
.\quick_start.ps1
```

- ✅ Auto-detects available devices
- ✅ Launches emulator if needed  
- ✅ Runs app with mock data
- ⚡ ~60 seconds to running app

**Use this for:** Daily development, quick testing

---

### 2. `start_taskflow.ps1` 🎯 **FULL CONTROL**
**Complete startup with all options**

```powershell
.\start_taskflow.ps1 [options]
```

**Options:**
- `-SkipBackend` - Don't start backend server
- `-Device windows` - Run on Windows desktop
- `-EmulatorId "name"` - Specify emulator
- `-BackendPort 4000` - Custom backend port

**Features:**
- ✅ Verifies Flutter SDK
- ✅ Manages emulator lifecycle
- ✅ Optionally starts backend
- ✅ Comprehensive error checking
- ✅ Color-coded status messages

**Use this for:** Presentations, demos, full stack development

---

### 3. `dev.ps1` 🛠️ **DEVELOPMENT TOOLS**
**Common development commands**

```powershell
.\dev.ps1 <command>
```

**Available commands:**
- `devices` - List connected devices
- `emulators` - List available emulators
- `clean` - Clean build cache
- `analyze` - Check code quality
- `format` - Format all files
- `test` - Run tests
- `build` - Build the app
- `doctor` - Check Flutter setup
- `help` - Show all commands

**Use this for:** Troubleshooting, code quality, build management

---

## 📖 Documentation Created

### 1. `STARTUP_GUIDE.md`
Comprehensive guide covering:
- Quick start instructions
- Manual startup steps
- All script options
- Troubleshooting section
- Configuration details

### 2. `GETTING_STARTED.md`
Complete developer guide with:
- Step-by-step tutorials
- Common workflows
- Performance expectations
- Tips & tricks
- Hot reload commands
- Debugging strategies

---

## 🎯 Quick Reference

### First Time Setup

```powershell
# 1. Navigate to project
cd "g:\My Drive\university\semester_7\human computer interaction\taskflow_app"

# 2. Check Flutter is working
.\dev.ps1 doctor

# 3. See available devices
.\dev.ps1 devices

# 4. Launch the app!
.\quick_start.ps1
```

### Daily Development Workflow

```powershell
# Morning: Start fresh
.\dev.ps1 clean
.\quick_start.ps1

# During development: Use hot reload
# Just press 'r' in terminal for instant updates

# Before committing:
.\dev.ps1 format
.\dev.ps1 analyze
```

### For Presentations

```powershell
# Single command does everything
.\start_taskflow.ps1

# Everything starts automatically:
# ✓ Emulator launches
# ✓ Backend starts (optional)
# ✓ App builds and runs
```

---

## 🐛 Common Issues & Solutions

### "Emulator not found"
```powershell
# Check available emulators
.\dev.ps1 emulators

# Or use Windows desktop
.\start_taskflow.ps1 -Device windows
```

### "Build failed"
```powershell
# Clean and retry
.\dev.ps1 clean
.\quick_start.ps1
```

### "Port already in use"
```powershell
# Skip backend
.\start_taskflow.ps1 -SkipBackend
```

### Any other issue
```powershell
# Check Flutter setup
.\dev.ps1 doctor

# Read detailed guide
# See GETTING_STARTED.md
```

---

## ⌨️ Hot Reload (During Development)

Once app is running, use these keys:

| Key | Action |
|-----|--------|
| `r` | Hot Reload (instant updates) ⚡ |
| `R` | Hot Restart (full restart) |
| `q` | Quit |
| `h` | Help |

**Pro Tip:** Press `r` after saving files for instant updates!

---

## 📊 Startup Times

| Method | First Time | Subsequent |
|--------|------------|------------|
| `quick_start.ps1` | 2-3 min | 30-60s |
| `start_taskflow.ps1` | 2-3 min | 30-60s |
| Hot reload | - | <1s ⚡ |
| Manual steps | 3-4 min | 1-2 min |

*First time is slower due to Gradle build and dependency downloads*

---

## 🎓 Learning Path

1. **Start here:** `.\quick_start.ps1`
2. **Try options:** `.\start_taskflow.ps1 -Device windows`
3. **Explore tools:** `.\dev.ps1 help`
4. **Read docs:** `GETTING_STARTED.md`
5. **Deep dive:** `docs/technical_report.md`

---

## 📁 File Locations

```
taskflow_app/
├── quick_start.ps1              ⭐ Daily use
├── start_taskflow.ps1           🎯 Full control
├── dev.ps1                      🛠️ Dev tools
├── STARTUP_GUIDE.md             📖 Quick ref
├── GETTING_STARTED.md           📖 Complete guide
├── README.md                    📖 Project overview
└── docs/
    ├── technical_report.md      📖 Architecture
    └── ui_ux_polish_improvements.md
```

---

## ✅ Success Indicators

**App is running correctly when you see:**
- ✅ Projects screen with colorful project cards
- ✅ Bottom navigation with 5 tabs
- ✅ "Projects overview" header at top
- ✅ No error messages in terminal

**Terminal shows:**
```
Flutter run key commands.
r Hot reload.
R Hot restart.
h List all available interactive commands.
q Quit (terminate the application on the device).
```

---

## 🆘 Need Help?

1. **Quick fixes:**
   - Run `.\dev.ps1 clean`
   - Restart emulator
   - Check `.\dev.ps1 doctor`

2. **Read documentation:**
   - `GETTING_STARTED.md` - Complete guide
   - `STARTUP_GUIDE.md` - Quick reference
   - `README.md` - Project overview

3. **Check specific docs:**
   - `docs/technical_report.md` - Architecture
   - `docs/api_config.md` - Backend API
   - `docs/ui_ux_polish_improvements.md` - UI features

---

## 🎉 Ready to Go!

**Everything is set up! Just run:**

```powershell
.\quick_start.ps1
```

**Then start developing with hot reload (`r` key)!**

---

**Created:** December 9, 2025  
**TaskFlow Version:** 1.0.0  
**Flutter SDK:** 3.24.5
