# TaskFlow Quick Reference

## 🚀 Getting Started in 2 Minutes

### 1. Run the App (Flutter)
```bash
cd taskflow_app
flutter pub get
flutter run
```

### 2. Start Backend (Optional - for real-time features)
```bash
cd taskflow_app/backend
npm install
npm start
```

---

## 📱 What You Get

### Immediately Available (No Backend Needed)
- ✅ Task management
- ✅ Project organization  
- ✅ Calendar view
- ✅ Profile with badges
- ✅ User status system

### With Backend Running
- 💬 Real-time chat
- 📞 Audio calling
- 🔔 Live notifications
- 👥 Team collaboration

---

## 🗂️ Key Files

| File | Purpose |
|------|---------|
| `lib/main.dart` | App entry point |
| `lib/app_router.dart` | Navigation setup |
| `lib/features/` | All app features |
| `lib/theme/tokens.dart` | Design system |
| `backend/server.js` | Backend server |
| `backend/README.md` | API documentation |

---

## 🔧 Common Commands

```bash
# Run app on specific device
flutter run -d <device-id>

# List devices
flutter devices

# Hot reload (while app running)
# Press 'r' in terminal

# Hot restart
# Press 'R' in terminal

# Run tests
flutter test

# Build APK
flutter build apk

# Build for iOS
flutter build ios
```

---

## 📚 Documentation

- 📖 [Full README](README.md) - Complete documentation
- 🔌 [Backend API](backend/README.md) - API endpoints & Socket.IO
- 📋 [Progress Tracking](docs/progress.md) - Development status
- 🎨 [Design Tokens](docs/design-tokens.md) - Theme system

---

## 🐛 Troubleshooting

### App won't start
```bash
flutter clean
flutter pub get
flutter run
```

### Backend issues (Google Drive path)
```bash
# Copy to local drive
Copy-Item -Recurse backend C:\taskflow-backend
cd C:\taskflow-backend
npm install
npm start
```

### Permission errors (Android)
Check `android/app/src/main/AndroidManifest.xml` has required permissions

---

## 💡 Development Tips

1. **Hot Reload** (`r`) - Quick UI updates
2. **Hot Restart** (`R`) - Full app restart
3. **DevTools** - Use Flutter DevTools for debugging
4. **State** - Check Riverpod providers in `lib/*/providers/`
5. **Themes** - Platform-adaptive (Fluent on Android, Glass on iOS)

---

## 🎯 Project Highlights

- **16,000+ lines** of Flutter code
- **Real-time** chat and audio calling
- **Cross-platform** (Android, iOS, Web)
- **Node.js backend** with Socket.IO
- **Full authentication** with JWT
- **Badge system** (Clash Royale-style)
- **Voice messages** in chat
- **File sharing** capabilities

---

Need help? Check the [main README](README.md) or [backend docs](backend/README.md)!
