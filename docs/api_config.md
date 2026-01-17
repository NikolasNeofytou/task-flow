# API Configuration - TaskFlow Current Implementation

## Current Architecture

TaskFlow uses a **mock data approach** with local storage for this academic submission. The app is designed to work completely offline without requiring external backend services.

## Data Storage

### Primary Storage: FlutterSecureStorage
- **Purpose**: User credentials, profile data, authentication tokens
- **Location**: `lib/core/network/auth_token_provider.dart`, `lib/features/profile/providers/profile_provider.dart`  
- **Encryption**: AES-256 via device keystore (iOS Keychain/Android Keystore)
- **Persistence**: Survives app restarts, device reboots

### Secondary Storage: SharedPreferences
- **Purpose**: App settings and form data
- **Persistence**: Non-sensitive data that persists across sessions

### Mock Data Sources
- **Location**: `lib/core/data/mock_data.dart`
- **Purpose**: Provides sample tasks, projects, users, notifications
- **Integration**: Seamlessly works with local storage layers

## Configuration

### App Config Provider
```dart
// lib/core/config/app_config.dart
final appConfigProvider = Provider<AppConfig>((ref) => AppConfig.fromEnvironment());

// Default settings:
// - useMocks: true (always uses mock data)
// - baseUrl: 'https://api.example.com' (not used in current implementation)
```

### Mock Repository Selection
```dart
// lib/core/providers/data_providers.dart
final projectsRepositoryProvider = Provider<ProjectsRepository>((ref) {
  final config = ref.watch(appConfigProvider);
  if (config.useMocks) return MockProjectsRepository();  // Always used in current branch
  // Real repositories not implemented in current branch
});
```

## Academic Compliance

✅ **Data Persistence**: Profile names and form data persist via FlutterSecureStorage  
✅ **Cross-Session Storage**: Data survives app restarts as required  
✅ **No Backend Required**: Completely self-contained for demonstration  
✅ **Mock Authentication**: Any email/password combination works
