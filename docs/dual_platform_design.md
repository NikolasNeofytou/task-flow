# Dual Platform Design System

## Overview

The Taskflow app now supports **both Android and iOS** with platform-specific design systems:

- 🤖 **Android** → Microsoft Fluent Design (Windows 11 style)
- 🍎 **iOS** → iOS 18 Glass Design (Glassmorphism)

## How It Works

The app automatically detects the platform at runtime and applies the appropriate theme:

```dart
// In main.dart
final bool isIOS = Platform.isIOS;

MaterialApp.router(
  theme: isIOS ? iOSGlassTheme.light() : FluentTheme.light(),
  darkTheme: isIOS ? iOSGlassTheme.dark() : FluentTheme.dark(),
  //...
)
```

## Android Design (Fluent)

### Characteristics:
- 🔵 **Microsoft Blue** (`#0078D4`)
- 📦 **Subtle shadows** (low opacity, small blur)
- 🎨 **Segoe UI typography**
- ✨ **Acrylic & Mica effects**
- 🪟 **Windows 11 aesthetics**

### Key Features:
- FluentButton, FluentCard, FluentTextField
- Soft elevation (shadow2 to shadow64)
- Acrylic translucent backgrounds
- Mica layered materials
- Reveal hover effects

### Files:
- `lib/theme/fluent_tokens.dart` (395 lines)
- `lib/theme/fluent_theme.dart` (480 lines)
- `lib/design_system/fluent_buttons.dart` (520 lines)
- `lib/design_system/fluent_cards.dart` (650 lines)
- `lib/design_system/fluent_inputs.dart` (580 lines)

## iOS Design (Glass)

### Characteristics:
- 🔵 **iOS Blue** (`#007AFF`)
- 🪟 **Frosted glass blur** (BackdropFilter 20px)
- 📱 **SF Pro typography** (system font)
- ✨ **iOS 18 glassmorphism**
- 🌟 **Dynamic Island aesthetics**

### Key Features:
- iOSGlassContainer (frosted blur effect)
- iOSGlassCard, iOSGlassButton
- iOSGlassNavigationBar (translucent)
- iOSGlassSearchBar
- 70% opacity with 20px blur

### Files:
- `lib/theme/ios_glass_theme.dart` (650 lines)

## Platform-Specific Widgets

### Android (Fluent)
```dart
FluentCard(
  child: FluentListTile(
    title: Text('Task'),
    subtitle: Text('Description'),
  ),
)

FluentButton(
  onPressed: () {},
  icon: Icons.add,
  child: Text('Create'),
)
```

### iOS (Glass)
```dart
iOSGlassCard(
  child: iOSGlassListTile(
    title: Text('Task'),
    subtitle: Text('Description'),
  ),
)

iOSGlassButton(
  onPressed: () {},
  isPrimary: true,
  child: Text('Create'),
)
```

## Design Comparison

| Feature | Android (Fluent) | iOS (Glass) |
|---------|-----------------|-------------|
| Primary Color | `#0078D4` (MS Blue) | `#007AFF` (iOS Blue) |
| Background | Light gray `#F5F5F5` | Light gray `#F2F2F7` |
| Cards | Subtle shadow + border | Frosted glass blur |
| Buttons | Solid colors | Glass or solid |
| Typography | Segoe UI | SF Pro (system) |
| Effects | Acrylic, Mica, Reveal | BackdropFilter blur |
| Border Radius | 8-12px | 12-16px |
| Shadows | Subtle (0.06-0.17 opacity) | None (glass instead) |

## Running on Different Platforms

### Android Emulator
```powershell
.\scripts\start_emulator.ps1
```
Will show **Fluent Design** (Microsoft style)

### iOS Simulator (macOS required)
```bash
flutter run -d "iPhone 15 Pro"
```
Will show **Glass Design** (iOS 18 style)

### Web/Desktop
Defaults to Fluent Design (can be customized)

## Theme Switching

The app automatically applies the correct theme based on `Platform.isIOS`. No manual switching needed!

### Light Mode (Default)
- Android: Clean white with Fluent blue
- iOS: Light gray with frosted glass

### Dark Mode
- Android: Dark gray (`#1F1F1F`) with Fluent blue
- iOS: Pure black with translucent glass

Change mode in `main.dart`:
```dart
themeMode: ThemeMode.light,  // or ThemeMode.dark
```

## Glass Effect Details (iOS)

The signature iOS glass effect uses Flutter's `BackdropFilter`:

```dart
BackdropFilter(
  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
  child: Container(
    color: Colors.white.withOpacity(0.7),
    // content here
  ),
)
```

This creates that beautiful frosted glass blur seen in:
- iOS Control Center
- iOS Dynamic Island
- iOS Widgets
- iOS Notifications

## Files Structure

```
lib/
├── theme/
│   ├── fluent_tokens.dart          # Android design tokens
│   ├── fluent_theme.dart           # Android theme config
│   └── ios_glass_theme.dart        # iOS theme + widgets
├── design_system/
│   ├── fluent_buttons.dart         # Android buttons
│   ├── fluent_cards.dart           # Android cards
│   └── fluent_inputs.dart          # Android inputs
├── main.dart                        # Platform detection
└── features/
    └── shell/
        └── app_shell.dart          # Works on both platforms
```

## Benefits

### For Users:
✅ **Native feel** on each platform  
✅ **Familiar UI** patterns  
✅ **Platform-appropriate** aesthetics  
✅ **Premium design** quality

### For Developers:
✅ **Single codebase** for both platforms  
✅ **Automatic platform detection**  
✅ **Reusable widgets**  
✅ **Easy to extend**

## Next Steps

To apply platform-specific designs to screens:

1. **Create platform wrapper widgets**:
```dart
class PlatformCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Platform.isIOS 
      ? iOSGlassCard(child: child)
      : FluentCard(child: child);
  }
}
```

2. **Update screens** to use platform wrappers

3. **Test on both platforms** to ensure consistency

## References

- [Microsoft Fluent Design](https://fluent2.microsoft.design/)
- [iOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [Flutter Platform Detection](https://api.flutter.dev/flutter/dart-io/Platform-class.html)

---

**Status**: ✅ Dual platform support complete  
**Android**: Fluent Design (Windows 11 style)  
**iOS**: Glass Design (iOS 18 style)  
**Platform Detection**: Automatic
