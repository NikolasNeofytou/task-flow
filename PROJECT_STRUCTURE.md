# TaskFlow Project Structure

Complete directory structure and organization guide for TaskFlow.

## 📁 Root Directory

```
taskflow_app/
├── 📱 lib/                          # Flutter source code
├── 🧪 test/                         # Test files
├── 📖 docs/                         # Documentation
├── 🖼️  assets/                      # Images, sounds, fonts
├── 🔧 scripts/                      # Utility scripts
├── 🌐 backend/                      # Node.js server
├── 🌐 backend_mock/                 # Mock server
├── 🤖 android/                      # Android configuration
├── 🍎 ios/                          # iOS configuration  
├── 🪟 windows/                      # Windows configuration
├── 🌍 web/                          # Web configuration
├── 📦 flutter_windows_3.24.5-stable/ # Flutter SDK (local)
├── 📄 Configuration & Setup Files
└── 🚀 Startup Scripts
```

---

## 📱 lib/ - Flutter Source Code

```
lib/
├── main.dart                        # App entry point
├── app_router.dart                  # Routing configuration
│
├── core/                            # Core utilities & services
│   ├── constants/
│   │   ├── app_constants.dart       # App-wide constants
│   │   └── api_config.dart          # API endpoints
│   ├── services/
│   │   ├── storage_service.dart     # Local storage
│   │   ├── api_service.dart         # API client
│   │   ├── socket_service.dart      # WebSocket connection
│   │   ├── notification_service.dart
│   │   ├── haptic_service.dart      # Haptic feedback
│   │   └── sound_service.dart       # Sound effects
│   ├── utils/
│   │   ├── date_utils.dart
│   │   ├── validators.dart
│   │   └── helpers.dart
│   └── errors/
│       ├── exceptions.dart
│       └── failures.dart
│
├── design_system/                   # Design tokens & components
│   ├── design_system.dart           # Main export file
│   ├── tokens/
│   │   ├── app_colors.dart          # Color palette
│   │   ├── app_spacing.dart         # Spacing scale
│   │   ├── app_radii.dart           # Border radius scale
│   │   ├── app_typography.dart      # Text styles
│   │   └── app_shadows.dart         # Shadow styles
│   ├── components/
│   │   ├── buttons/
│   │   │   ├── primary_button.dart
│   │   │   ├── loading_button.dart  # New: Dec 2025
│   │   │   └── icon_button.dart
│   │   ├── inputs/
│   │   │   ├── text_field.dart
│   │   │   └── enhanced_text_field.dart  # New: Dec 2025
│   │   ├── feedback/
│   │   │   ├── empty_state.dart     # New: Dec 2025
│   │   │   ├── app_snackbar.dart    # New: Dec 2025
│   │   │   └── loading_indicator.dart
│   │   ├── overlays/
│   │   │   ├── app_bottom_sheet.dart  # New: Dec 2025
│   │   │   └── app_dialog.dart
│   │   ├── cards/
│   │   │   ├── task_card.dart
│   │   │   ├── project_card.dart
│   │   │   └── user_card.dart
│   │   └── layout/
│   │       ├── app_scaffold.dart
│   │       └── responsive_layout.dart
│   └── themes/
│       ├── fluent_theme.dart        # Android Fluent UI
│       └── glass_theme.dart         # iOS Glass UI
│
├── features/                        # Feature modules
│   ├── auth/                        # Authentication
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── user_model.dart
│   │   │   │   └── login_response.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   └── providers/
│   │   │       └── auth_providers.dart
│   │   ├── domain/
│   │   │   └── entities/
│   │   │       └── user.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── login_screen.dart
│   │       │   ├── register_screen.dart
│   │       │   └── splash_screen.dart
│   │       ├── widgets/
│   │       │   └── auth_form.dart
│   │       └── providers/
│   │           └── login_state_provider.dart
│   │
│   ├── tasks/                       # Task management
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── task_model.dart
│   │   │   │   └── subtask_model.dart
│   │   │   ├── repositories/
│   │   │   │   └── task_repository.dart
│   │   │   └── providers/
│   │   │       └── task_providers.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── tasks_screen.dart
│   │       │   ├── task_detail_screen.dart  # Enhanced: Dec 2025
│   │       │   └── create_task_screen.dart
│   │       └── widgets/
│   │           ├── task_card.dart
│   │           ├── priority_badge.dart
│   │           └── status_chip.dart
│   │
│   ├── projects/                    # Project management
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── project_model.dart
│   │   │   ├── repositories/
│   │   │   │   └── project_repository.dart
│   │   │   └── providers/
│   │   │       └── project_providers.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── projects_screen.dart     # Enhanced: Dec 2025
│   │       │   ├── project_detail_screen.dart  # Enhanced: Dec 2025
│   │       │   └── create_project_screen.dart
│   │       └── widgets/
│   │           ├── project_card.dart
│   │           ├── qr_code_widget.dart
│   │           └── member_list.dart
│   │
│   ├── calendar/                    # Calendar & scheduling
│   │   ├── data/
│   │   │   └── providers/
│   │   │       └── calendar_providers.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   └── calendar_screen.dart
│   │       └── widgets/
│   │           ├── calendar_view.dart
│   │           └── event_card.dart
│   │
│   ├── chat/                        # Messaging & communication
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── message_model.dart
│   │   │   │   ├── voice_message_model.dart
│   │   │   │   └── chat_room_model.dart
│   │   │   ├── repositories/
│   │   │   │   └── chat_repository.dart
│   │   │   └── providers/
│   │   │       └── chat_providers.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── chat_list_screen.dart
│   │       │   └── chat_room_screen.dart
│   │       └── widgets/
│   │           ├── message_bubble.dart
│   │           ├── voice_recorder.dart
│   │           ├── task_reference_widget.dart
│   │           └── audio_player_widget.dart
│   │
│   ├── profile/                     # User profile
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── profile_model.dart
│   │   │   │   └── badge_model.dart
│   │   │   ├── repositories/
│   │   │   │   └── profile_repository.dart
│   │   │   └── providers/
│   │   │       └── profile_providers.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── profile_screen.dart
│   │       │   ├── edit_profile_screen.dart
│   │       │   └── badges_screen.dart
│   │       └── widgets/
│   │           ├── avatar_widget.dart
│   │           ├── badge_card.dart
│   │           └── status_selector.dart
│   │
│   ├── requests/                    # Team requests
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── request_model.dart
│   │   │   ├── repositories/
│   │   │   │   └── request_repository.dart
│   │   │   └── providers/
│   │   │       └── request_providers.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── requests_screen.dart     # Enhanced: Dec 2025
│   │       │   └── request_detail_screen.dart  # Enhanced: Dec 2025
│   │       └── widgets/
│   │           └── request_card.dart
│   │
│   └── notifications/               # Notifications
│       ├── data/
│       │   ├── models/
│       │   │   └── notification_model.dart
│       │   ├── repositories/
│       │   │   └── notification_repository.dart
│       │   └── providers/
│       │       └── notification_providers.dart
│       └── presentation/
│           ├── screens/
│           │   └── notifications_screen.dart
│           └── widgets/
│               └── notification_card.dart
│
└── theme/                           # Theme configuration
    ├── app_theme.dart               # Main theme
    ├── light_theme.dart             # Light mode
    ├── dark_theme.dart              # Dark mode
    └── theme_extensions.dart        # Custom extensions
```

---

## 🧪 test/ - Testing

```
test/
├── design_system_widgets_test.dart   # Component tests
├── golden_screens_test.dart          # Visual regression
├── widget_test.dart                  # Widget tests
├── goldens/                          # Golden images
│   ├── projects_screen_android.png
│   ├── projects_screen_ios.png
│   └── ...
├── unit/                             # Unit tests
│   ├── services/
│   ├── repositories/
│   └── utils/
├── widget/                           # Widget tests
│   └── components/
└── integration/                      # Integration tests
    └── flows/
```

---

## 📖 docs/ - Documentation

```
docs/
├── README.md                         # Documentation index
├── technical_report.md               # Complete technical doc (8000+ words)
├── ui_ux_polish_improvements.md      # UI/UX enhancements
│
├── Architecture/
│   ├── project_plan.md               # Project planning
│   ├── design-tokens.md              # Design system
│   ├── dual_platform_design.md       # Platform-specific design
│   └── flutter_checklist.md          # Development checklist
│
├── Features/
│   ├── chat_implementation_summary.md
│   ├── enhanced_chat_system.md
│   ├── chat_visual_reference.md
│   ├── comments_system.md
│   ├── camera_qr_system.md
│   ├── deep_link_system.md
│   ├── haptics_sound_system.md
│   ├── calendar_enhancements.md
│   ├── task_assignment_system.md
│   ├── project_enhancements.md
│   ├── message_viewer_tracking.md
│   ├── message_viewer_visual_reference.md
│   └── pinned_messages_system.md
│
├── UI_Systems/
│   ├── fluent_ui_system.md           # Android Fluent UI
│   ├── fluent_implementation_summary.md
│   ├── INTERACTION_PATTERNS.md       # Interaction guidelines
│   └── PATTERN_DEMO_GUIDE.md         # Demo guide
│
├── Phases/
│   ├── phase2_interactions_complete.md
│   ├── phase3_performance_complete.md
│   ├── phase4_smart_features_complete.md
│   ├── phase5_accessibility_complete.md
│   └── phase6_premium_polish_complete.md
│
├── API/
│   ├── api_config.md                 # API documentation
│   └── backend_mock.md               # Mock server guide
│
├── HCI/
│   ├── axis_requirements_mapping.md  # HCI requirements
│   └── progress.md                   # Project progress
│
└── Release/
    └── release_checklist.md          # Release checklist
```

---

## 🖼️ assets/ - Resources

```
assets/
├── images/
│   ├── logo.png
│   ├── placeholder.png
│   └── badges/
│       ├── beginner.png
│       ├── contributor.png
│       └── leader.png
├── sounds/
│   ├── README.md
│   ├── tap.mp3                       # Tap sound
│   ├── success.mp3                   # Success sound
│   ├── error.mp3                     # Error sound
│   ├── notification.mp3              # Notification sound
│   └── sent.mp3                      # Message sent sound
└── fonts/
    └── (custom fonts if any)
```

---

## 🌐 backend/ - Node.js Server

```
backend/
├── server.js                         # Express server
├── package.json                      # Dependencies
├── start.ps1                         # Startup script
├── README.md                         # Backend documentation
├── SETUP.md                          # Setup instructions
├── test-client.html                  # WebSocket test client
│
├── routes/                           # API routes
│   ├── auth.js                       # Authentication
│   ├── tasks.js                      # Tasks API
│   ├── projects.js                   # Projects API
│   ├── chat.js                       # Chat API
│   ├── notifications.js              # Notifications API
│   └── users.js                      # Users API
│
├── middleware/                       # Express middleware
│   └── auth.js                       # Auth middleware
│
├── socket/                           # WebSocket handlers
│   └── handlers.js                   # Socket.io handlers
│
└── data/                             # Data storage
    └── store.js                      # In-memory store
```

---

## 🌐 backend_mock/ - Mock Server

```
backend_mock/
├── server.js                         # Simple mock server
├── package.json                      # Dependencies
└── start_mock.ps1                    # Startup script
```

---

## 🔧 scripts/ - Utility Scripts

```
scripts/
├── run_on_local_drive.ps1            # Copy to local drive
├── start_emulator.ps1                # Start Android emulator
└── run_stack.ps1                     # Run full stack
```

---

## 🚀 Root Scripts (Main)

```
Root Directory:
├── quick_start.ps1                   # ⭐ Daily startup (recommended)
├── start_taskflow.ps1                # Full control startup
└── dev.ps1                           # Development tools
```

---

## 📄 Configuration Files

```
Root Directory:
├── pubspec.yaml                      # Flutter dependencies
├── analysis_options.yaml             # Dart analyzer config
├── .gitignore                        # Git ignore rules
├── .metadata                         # Flutter metadata
├── README.md                         # Project README
├── CONTRIBUTING.md                   # Contribution guide
├── LICENSE                           # MIT License
├── CHANGELOG.md                      # Version history
├── QUICKSTART.md                     # Quick start guide
├── STARTUP_GUIDE.md                  # Startup reference
├── GETTING_STARTED.md                # Complete setup guide
├── SCRIPTS_README.md                 # Scripts documentation
├── STARTUP_FLOWS.md                  # Visual flowcharts
└── PROJECT_STRUCTURE.md              # This file
```

---

## 🤖 Platform Configurations

### Android
```
android/
├── build.gradle                      # Root Gradle config
├── gradle.properties                 # Gradle properties
├── settings.gradle                   # Project settings
├── local.properties                  # Local SDK paths
├── app/
│   ├── build.gradle                  # App Gradle config
│   └── src/
│       └── main/
│           ├── AndroidManifest.xml   # App manifest
│           ├── kotlin/               # Kotlin code
│           └── res/                  # Android resources
└── gradle/
    └── wrapper/                      # Gradle wrapper
```

### iOS
```
ios/
├── Runner/                           # iOS project
│   ├── AppDelegate.swift
│   ├── Info.plist                    # iOS configuration
│   └── Assets.xcassets/              # iOS assets
├── Runner.xcodeproj/                 # Xcode project
└── Runner.xcworkspace/               # Xcode workspace
```

### Windows
```
windows/
├── CMakeLists.txt                    # CMake configuration
├── flutter/                          # Flutter Windows engine
└── runner/                           # Windows runner
    ├── main.cpp
    └── resources/
```

### Web
```
web/
├── index.html                        # Main HTML
├── manifest.json                     # Web manifest
└── icons/                            # PWA icons
```

---

## 🏗️ Build Outputs

```
.dart_tool/                           # Dart build cache
build/                                # Build output
  ├── app/
  ├── ios/
  ├── web/
  └── windows/
.flutter-plugins                      # Flutter plugins list
.flutter-plugins-dependencies         # Plugin dependencies
```

---

## 📊 Key Metrics

### Code Organization
- **Total Features:** 8 major feature modules
- **UI Components:** 20+ reusable components
- **Screens:** 30+ screens
- **Design Tokens:** 4 categories (colors, spacing, radii, typography)
- **Services:** 6 core services

### Documentation
- **Documentation Files:** 35+ markdown files
- **Technical Report:** 8000+ words
- **Code Comments:** Comprehensive inline documentation

### Testing
- **Widget Tests:** Core components covered
- **Golden Tests:** Visual regression for main screens
- **Integration Tests:** User flow coverage

---

## 🔍 Finding Things Quickly

### "I want to..."

**...add a new feature:**
- Create folder in `lib/features/`
- Follow data/domain/presentation structure
- Add providers in `data/providers/`

**...create a UI component:**
- Add to `lib/design_system/components/`
- Use design tokens from `design_system/tokens/`
- Export in `design_system/design_system.dart`

**...add a screen:**
- Add to appropriate `features/*/presentation/screens/`
- Register route in `app_router.dart`
- Add navigation logic

**...modify theme:**
- Edit `lib/theme/` files
- Adjust design tokens in `design_system/tokens/`
- Update platform themes if needed

**...add an API endpoint:**
- Backend: Add route in `backend/routes/`
- Frontend: Update `core/services/api_service.dart`
- Add model in feature's `data/models/`

**...write tests:**
- Unit tests: `test/unit/`
- Widget tests: `test/widget/`
- Integration: `test/integration/`

**...update documentation:**
- Feature docs: `docs/Features/`
- Architecture: `docs/Architecture/`
- Update relevant README files

---

## 📚 Naming Conventions

### Files
- Screens: `*_screen.dart` (e.g., `tasks_screen.dart`)
- Widgets: `*_widget.dart` (e.g., `task_card.dart`)
- Models: `*_model.dart` (e.g., `task_model.dart`)
- Repositories: `*_repository.dart`
- Providers: `*_provider.dart` or `*_providers.dart`
- Services: `*_service.dart`

### Classes
- Screens: `*Screen` (e.g., `TasksScreen`)
- Widgets: Descriptive name (e.g., `TaskCard`, `LoadingButton`)
- Models: `*Model` (e.g., `TaskModel`)
- Repositories: `*Repository`
- Services: `*Service`

### Folders
- All lowercase with underscores: `user_profile`, `task_detail`

---

## 🎯 Dependencies Overview

### Main Dependencies (pubspec.yaml)
- **State Management:** riverpod, flutter_riverpod
- **Navigation:** go_router
- **Storage:** flutter_secure_storage, shared_preferences
- **HTTP:** http, dio
- **Real-time:** socket_io_client
- **UI:** flutter_svg, cached_network_image
- **Camera:** camera, qr_code_scanner
- **Audio:** audioplayers, record
- **Notifications:** flutter_local_notifications
- **Haptics:** vibration
- **Deep Links:** uni_links

### Backend Dependencies (package.json)
- **Framework:** express
- **WebSocket:** socket.io
- **CORS:** cors
- **Body Parser:** body-parser

---

## 🔄 Related Documentation

- **Quick Start:** See `README.md` → Quick Start section
- **Complete Setup:** See `GETTING_STARTED.md`
- **Scripts Guide:** See `SCRIPTS_README.md`
- **Startup Flows:** See `STARTUP_FLOWS.md`
- **Contributing:** See `CONTRIBUTING.md`
- **Technical Details:** See `docs/technical_report.md`

---

**Last Updated:** December 9, 2025  
**Version:** 1.0.0
