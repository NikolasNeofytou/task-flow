# TaskFlow - Team Collaboration App

[![Flutter](https://img.shields.io/badge/Flutter-3.24.5-02569B?logo=flutter)](https://flutter.dev)
[![Node.js](https://img.shields.io/badge/Node.js-16+-339933?logo=node.js)](https://nodejs.org)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

A comprehensive Flutter application for team task management with real-time collaboration features, built as part of the Human-Computer Interaction course.

---

## 🚀 Quick Start

**New to TaskFlow? Start here:**

```powershell
# Fastest way to run (Windows)
.\quick_start.ps1
```

This will automatically:
- ✅ Detect or start the Android emulator
- ✅ Launch the app with mock data
- ✅ Get you running in ~60 seconds

**For complete setup instructions, see:** [`GETTING_STARTED.md`](GETTING_STARTED.md)

---

## 📖 Documentation

| Document | Description |
|----------|-------------|
| [GETTING_STARTED.md](GETTING_STARTED.md) | Complete setup guide for new developers |
| [CONTRIBUTING.md](CONTRIBUTING.md) | How to contribute to the project |
| [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md) | Detailed codebase organization |
| [STARTUP_GUIDE.md](STARTUP_GUIDE.md) | Quick reference for startup scripts |
| [SCRIPTS_README.md](SCRIPTS_README.md) | Comprehensive script documentation |
| [CHANGELOG.md](CHANGELOG.md) | Version history and changes |
| [docs/technical_report.md](docs/technical_report.md) | Complete technical documentation (8000+ words) |

---

## 🎯 Features

### Core Features
- ✅ **Task Management**: Create, assign, and track tasks
- ✅ **Project Organization**: Organize work by projects
- ✅ **Calendar View**: Visual schedule and deadline tracking
- ✅ **Team Collaboration**: Share work with team members
- ✅ **Notifications**: Stay updated on task changes

### Real-Time Features
- 💬 **Live Chat**: Instant messaging by project
- 🎤 **Voice Messages**: Record and send voice notes
- 📞 **Audio Calls**: Group audio calling
- 📎 **File Sharing**: Share documents and images
- 🔗 **Task References**: Link tasks in chat

### User Features
- 👤 **User Profiles**: Customizable profiles with photos
- 🏆 **Badge System**: Clash Royale-style achievements
- 🟢 **User Status**: Discord-style availability (Online/Away/DND/Offline)
- 🎨 **Cross-Platform Themes**: Fluent UI (Android), Glass UI (iOS)

## 🏗️ Architecture

### Frontend (Flutter)
- **State Management**: Riverpod
- **Routing**: go_router with deep linking
- **Storage**: flutter_secure_storage
- **Themes**: Platform-adaptive design system
- **Animations**: Custom transitions and effects

### Backend (Node.js)
- **Framework**: Express.js
- **Real-time**: Socket.IO
- **Auth**: JWT tokens
- **Security**: Helmet, CORS, rate limiting
- **Storage**: In-memory (easily replaceable with DB)

## 📁 Project Structure

```
taskflow_app/
├── lib/                          # Flutter app source
│   ├── main.dart                 # App entry point
│   ├── app_router.dart           # Navigation configuration
│   ├── core/                     # Core utilities
│   ├── features/                 # Feature modules
│   │   ├── calendar/             # Schedule view
│   │   ├── chat/                 # Chat & audio calls
│   │   ├── profile/              # User profiles & badges
│   │   ├── projects/             # Project management
│   │   └── ...
│   ├── theme/                    # Design system & tokens
│   └── design_system/            # Reusable widgets
├── backend/                      # Node.js server
│   ├── server.js                 # Express server
│   ├── routes/                   # API endpoints
│   ├── socket/                   # WebSocket handlers
│   └── README.md                 # Backend documentation
├── android/                      # Android platform files
├── ios/                          # iOS platform files
├── web/                          # Web platform files
├── test/                         # Unit & widget tests
├── docs/                         # Documentation
└── scripts/                      # Helper scripts
```

## 🚀 Quick Start

### Prerequisites
- Flutter SDK 3.24.5+
- Node.js 16+ (for backend)
- Android Studio / Xcode (for mobile)

### 1. Install Flutter Dependencies

```bash
flutter pub get
```

### 2. Setup Backend

```bash
cd backend
npm install

# Create .env file
cp .env.example .env

# Edit .env and set:
# PORT=3000
# JWT_SECRET=your_secret_key_here

npm start
```

Backend will run on `http://localhost:3000`

### 3. Run the App

#### Android
```bash
flutter run -d <device-id>
```

#### iOS
```bash
flutter run -d <device-id>
```

#### Web
```bash
flutter run -d chrome
```

## 🧪 Testing

### Run all tests
```bash
flutter test
```

### Run specific test
```bash
flutter test test/widget_test.dart
```

## 📦 Key Dependencies

### Flutter
- `riverpod` - State management
- `go_router` - Navigation
- `flutter_secure_storage` - Secure data storage
- `image_picker` - Profile picture selection
- `flutter_sound` - Voice recording
- `socket_io_client` - Real-time communication

### Backend
- `express` - Web framework
- `socket.io` - Real-time engine
- `jsonwebtoken` - Authentication
- `helmet` - Security middleware
- `cors` - Cross-origin support

## 🎨 Design System

The app uses a custom design system with:
- **Tokens**: Colors, spacing, radii defined in `lib/theme/tokens.dart`
- **Platform Themes**: Adaptive Fluent (Android) and Glass (iOS) styles
- **Components**: Reusable widgets in `lib/design_system/`

## 📡 API Documentation

See [backend/README.md](backend/README.md) for:
- REST API endpoints
- Socket.IO events
- Authentication flow
- Data models

## 🔐 Authentication Flow

1. User signs up on first launch
2. JWT token generated and stored securely
3. Token sent with all API requests
4. Real-time features connect with user ID

## 📞 Audio Call Architecture

1. User initiates call from chat screen
2. Socket.IO signals call start to participants
3. Call screen shows participant grid
4. WebRTC signaling ready (currently simulated)
5. Mute/speaker controls update state

## 🏅 Badge System

Users earn badges by:
- Completing their first task
- Working consistently
- Helping teammates
- Achieving streaks

Badges come in 4 rarities: Common, Rare, Epic, Legendary

## 🎯 Development Roadmap

### Completed ✅
- Core task management
- Real-time chat
- Voice messages
- File attachments
- Audio call UI
- User profiles
- Badge system
- Status indicators
- Backend API
- Cross-platform themes

### Future Enhancements 🚧
- WebRTC audio implementation
- Video calling
- Screen sharing
- Database integration (MongoDB/PostgreSQL)
- Push notifications
- Offline mode
- Analytics dashboard

## 🛠️ Development Tools

### Available Scripts

```powershell
# Quick daily startup
.\quick_start.ps1

# Full control startup with options
.\start_taskflow.ps1 -Device windows -SkipBackend

# Development commands
.\dev.ps1 clean      # Clean build
.\dev.ps1 analyze    # Run analyzer
.\dev.ps1 format     # Format code
.\dev.ps1 test       # Run tests
.\dev.ps1 devices    # List devices
.\dev.ps1 help       # Show all commands
```

**See [SCRIPTS_README.md](SCRIPTS_README.md) for complete script documentation.**

---

## 📚 Additional Documentation

### Architecture & Design
- [Design Tokens](docs/design-tokens.md) - Design system tokens
- [Fluent UI System](docs/fluent_ui_system.md) - Android design
- [Dual Platform Design](docs/dual_platform_design.md) - Platform-specific UI
- [Interaction Patterns](docs/INTERACTION_PATTERNS.md) - UI/UX patterns

### Features Documentation
- [Chat System](docs/enhanced_chat_system.md) - Real-time messaging
- [Camera & QR System](docs/camera_qr_system.md) - QR code features
- [Deep Linking](docs/deep_link_system.md) - Navigation system
- [Haptics & Sound](docs/haptics_sound_system.md) - Feedback system
- [UI/UX Polish](docs/ui_ux_polish_improvements.md) - Latest enhancements

### Development Phases
- [Phase 2: Interactions](docs/phase2_interactions_complete.md)
- [Phase 3: Performance](docs/phase3_performance_complete.md)
- [Phase 4: Smart Features](docs/phase4_smart_features_complete.md)
- [Phase 5: Accessibility](docs/phase5_accessibility_complete.md)
- [Phase 6: Premium Polish](docs/phase6_premium_polish_complete.md)

### API & Backend
- [API Configuration](docs/api_config.md) - Backend API docs
- [Backend Mock](docs/backend_mock.md) - Mock server guide
- [Backend README](backend/README.md) - Server setup

---

## 🤝 Contributing

We welcome contributions! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for:
- Code standards and style guidelines
- Development workflow
- Commit message conventions
- Pull request process
- Testing requirements

**Quick contribution checklist:**
```powershell
.\dev.ps1 format    # Format code
.\dev.ps1 analyze   # Check for issues
.\dev.ps1 test      # Run tests
```

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🎓 Academic Context

This project was developed as part of the **Human-Computer Interaction** course, Semester 7, 2025.

**Key HCI Implementations:**
1. **Axis 1: Interaction & Feedback** - Haptics, sounds, animations
2. **Axis 2: Collaboration & Communication** - Chat, calls, file sharing
3. **Axis 3: Platform-Adaptive Design** - Fluent UI (Android), Glass UI (iOS)

See [docs/technical_report.md](docs/technical_report.md) for complete analysis.

---

## 🌟 Acknowledgments

- Flutter team for the amazing framework
- Material Design team for design guidelines
- Open source community for excellent packages
- Course instructors and teaching assistants

---

## 📞 Contact & Support

- **Issues**: Use GitHub Issues for bug reports and feature requests
- **Questions**: Check existing documentation first
- **Contributions**: See [CONTRIBUTING.md](CONTRIBUTING.md)

---

**Built with Flutter 💙 and Node.js 🟢**

*Last Updated: December 9, 2025 - Version 1.0.0*
