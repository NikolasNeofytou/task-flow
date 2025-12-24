# Technical Debt & Missing Features

**Last Updated:** December 24, 2025  
**Status:** Active Development

This document tracks all identified gaps, missing features, and technical debt in the TaskFlow project.

---

## 🔴 CRITICAL - Must Fix Before Demo

### 1. User Authentication System ✅ **COMPLETED**
**Status:** ✅ **DONE** (December 24, 2025)  
**Effort:** 4-6 hours  
**Impact:** Blocking - App has no user system

**Implementation Summary:**
- ✅ Created lib/features/auth/ folder structure
- ✅ Built LoginScreen and SignupScreen with validation
- ✅ Created AuthService (Dio-based API calls)
- ✅ Implemented AuthStateNotifier (Riverpod)
- ✅ Added token storage (FlutterSecureStorage)
- ✅ Added auth middleware (API interceptors)
- ✅ Updated app_router.dart with auth redirect logic
- ✅ Created splash screen with auth check
- ✅ Added demo credentials for testing

**Files Created:**
- lib/core/api/api_client.dart
- lib/core/api/api_config.dart
- lib/features/auth/models/auth_models.dart
- lib/features/auth/application/auth_service.dart
- lib/features/auth/application/auth_provider.dart
- lib/features/auth/presentation/login_screen.dart
- lib/features/auth/presentation/signup_screen.dart
- lib/features/auth/presentation/splash_screen.dart

**Files Modified:**
- lib/app_router.dart (added /splash, /login, /signup routes + auth redirects)
- lib/features/profile/presentation/enhanced_profile_screen.dart (integrated auth logout)

**Remaining:**
- [x] Add logout button to profile screen ✅
- [ ] Test with real backend server
- [ ] Add user profile update functionality

**Documentation:** See [docs/auth_implementation.md](auth_implementation.md)

---

### 2. Real Backend Integration ⚠️
**Status:** Not Started  
**Effort:** 6-8 hours  
**Impact:** High - Currently 100% mock data

**Current State:**
- Backend server exists but Flutter app uses only mock Riverpod providers
- Dio package added but no HTTP client configured
- No environment configuration (.env)
- No API base URL management

**Required Work:**
```
[ ] Create lib/core/api/ folder
[ ] Build ApiClient with Dio
[ ] Add interceptors (auth token, logging, error handling)
[ ] Create .env files (dev, staging, prod)
[ ] Add flutter_dotenv package
[ ] Create environment config service
[ ] Migrate data providers to use real API
  [ ] RequestsProvider -> API
  [ ] NotificationsProvider -> API
  [ ] ProjectsProvider -> API
  [ ] TasksProvider -> API
  [ ] CommentsProvider -> API
[ ] Add retry logic and timeout handling
[ ] Implement response/error DTOs
```

**Priority Order for Migration:**
1. Auth endpoints (login/signup)
2. Requests (simple CRUD)
3. Projects & Tasks
4. Comments
5. Notifications

---

### 3. Data Persistence (Hive) ⚠️
**Status:** Partially Complete  
**Effort:** 2-3 hours  
**Impact:** Medium - App loses data on restart

**Current State:**
- Hive adapters exist but were broken (recently fixed)
- No actual database usage in app
- All data stored in memory only

**Required Work:**
```
[x] Fix TaskItemAdapter and ProjectAdapter (DONE)
[ ] Initialize Hive in main.dart
[ ] Create HiveRepository pattern
[ ] Implement offline-first strategy
[ ] Add sync service for online/offline
[ ] Cache API responses locally
[ ] Handle data migrations
```

---

### 4. Error Handling & Loading States ⚠️
**Status:** Partially Complete  
**Effort:** 4-5 hours  
**Impact:** High - Poor user experience

**Current State:**
- Many screens use AsyncValue but incomplete handling
- No global error boundary
- No retry mechanisms
- Inconsistent error messages

**Required Work:**
```
[ ] Create global error handler widget
[ ] Standardize error UI components
[ ] Add retry buttons on all error states
[ ] Implement timeout handling (30s API calls)
[ ] Create AppException hierarchy
[ ] Add error logging service
[ ] Handle network errors gracefully
[ ] Add offline mode indicators
[ ] Implement exponential backoff for retries
```

---

## 🟡 HIGH PRIORITY - Should Fix

### 5. Push Notifications ⚠️
**Status:** Package Added, Not Implemented  
**Effort:** 6-8 hours  
**Impact:** Medium - Expected feature

**Current State:**
- `firebase_messaging` package in pubspec but never used
- No FCM token registration
- No notification handlers
- Backend notification endpoints exist but no push capability

**Required Work:**
```
[ ] Configure Firebase project (iOS & Android)
[ ] Add google-services.json and GoogleService-Info.plist
[ ] Implement NotificationService
[ ] Register FCM tokens with backend
[ ] Handle foreground notifications
[ ] Handle background notifications
[ ] Implement notification tap actions
[ ] Add notification permissions request
[ ] Create notification settings screen
[ ] Test on physical devices
```

**Blockers:** Firebase CMake errors on Windows need resolution

---

### 6. Deep Linking ❌
**Status:** Service Exists, Not Configured  
**Effort:** 3-4 hours  
**Impact:** High - QR codes won't work externally

**Current State:**
- DeepLinkService exists in code
- No taskflow:// URL scheme in AndroidManifest.xml
- No associated domains in iOS Info.plist
- Invite links won't open app

**Required Work:**
```
[ ] Add URL scheme to AndroidManifest.xml
[ ] Configure iOS associated domains
[ ] Test taskflow://invite/{projectId}/{token} URLs
[ ] Add app link verification (Android)
[ ] Implement universal links (iOS)
[ ] Handle deep link on app cold start
[ ] Handle deep link when app in background
[ ] Add deep link testing documentation
```

---

### 7. Comprehensive Testing ❌
**Status:** Minimal Coverage (~5%)  
**Effort:** 10-15 hours  
**Impact:** Critical for maintenance

**Current State:**
- Only 3 test files (mostly boilerplate)
- No unit tests for services/providers
- No widget tests for screens
- No integration tests
- Golden tests likely outdated

**Required Work:**
```
[ ] Unit Tests (Target: 70% coverage)
  [ ] Services (Auth, API, Hive, etc.)
  [ ] Providers (all Riverpod notifiers)
  [ ] Models (validation, serialization)
  [ ] Utils (formatters, validators)
  
[ ] Widget Tests (Target: 50+ screens)
  [ ] Authentication screens
  [ ] Request screens (list, detail, form)
  [ ] Project screens
  [ ] Calendar screen
  [ ] Profile screens
  
[ ] Integration Tests
  [ ] Login -> Create Project -> Add Task flow
  [ ] Request creation and acceptance flow
  [ ] QR code invite flow
  
[ ] Golden Tests
  [ ] Update all existing golden files
  [ ] Add goldens for new screens
  
[ ] Test Infrastructure
  [ ] Create test helpers and mocks
  [ ] Set up test data builders
  [ ] Configure CI for automated testing
```

---

## 🟢 MEDIUM PRIORITY - Nice to Have

### 8. Accessibility Improvements ⚠️
**Status:** Basic Implementation  
**Effort:** 4-6 hours

**Required Work:**
```
[ ] Add semantic labels to all interactive elements
[ ] Test with TalkBack (Android) and VoiceOver (iOS)
[ ] Ensure minimum touch target size (48x48)
[ ] Add high-contrast theme support
[ ] Test keyboard navigation
[ ] Add accessibility documentation
[ ] Run accessibility audits
```

---

### 9. Performance Optimization ❌
**Status:** Not Started  
**Effort:** 5-7 hours

**Required Work:**
```
[ ] Implement image caching (cached_network_image)
[ ] Add lazy loading for large lists
[ ] Implement pagination (20-50 items per page)
[ ] Add debouncing on search inputs (300ms)
[ ] Optimize large message lists (virtualization)
[ ] Profile app with Flutter DevTools
[ ] Reduce widget rebuilds (use const, keys)
[ ] Optimize JSON parsing (isolates for large payloads)
```

---

### 10. Production Readiness ❌
**Status:** Not Started  
**Effort:** 8-10 hours

**Required Work:**
```
Environment Configuration:
[ ] Create .env files (dev, staging, prod)
[ ] Configure API base URLs per environment
[ ] Set up build flavors (flutter run --flavor dev)
[ ] Add feature flags service

App Metadata:
[ ] Add Privacy Policy screen
[ ] Add Terms of Service screen
[ ] Add About screen with version info
[ ] Add licenses screen

Monitoring & Analytics:
[ ] Implement comprehensive analytics tracking
[ ] Add crash reporting (Sentry or Crashlytics)
[ ] Add performance monitoring
[ ] Set up A/B testing capability

Release Process:
[ ] Configure app signing (Android keystore)
[ ] Set up iOS certificates and provisioning
[ ] Create release build scripts
[ ] Add version checking / force update
[ ] Set up beta distribution (TestFlight, Firebase App Distribution)
```

---

## 🔵 LOW PRIORITY - Future Enhancements

### 11. Advanced Chat Features
```
[ ] Message editing
[ ] Message deletion
[ ] Typing indicators
[ ] File upload progress bars
[ ] Voice message playback controls
[ ] Message reactions (emoji)
[ ] Message threading
```

### 12. Project Management Enhancements
```
[ ] Task dependencies (blocked by relationships)
[ ] Gantt chart view
[ ] Time tracking per task
[ ] Budget tracking
[ ] Project templates
[ ] Recurring tasks
[ ] Task labels/tags
```

### 13. UX Polish
```
[ ] Onboarding tutorial (complete implementation)
[ ] Custom empty state illustrations
[ ] Skeleton loaders on all async screens
[ ] Pull-to-refresh on all list screens
[ ] Infinite scroll with pagination
[ ] Search history
[ ] Recent items shortcuts
[ ] Dark mode refinements
```

### 14. DevOps & Deployment
```
[ ] GitHub Actions CI/CD pipeline
[ ] Automated testing in CI
[ ] Code coverage reporting
[ ] Automated app store releases
[ ] Automated changelog generation
[ ] Branch protection rules
```

---

## 📊 Effort & Impact Matrix

| Priority | Feature | Effort | Impact | Status |
|----------|---------|--------|--------|--------|
| 🔴 CRITICAL | Authentication | 4-6h | Blocking | ❌ Not Started |
| 🔴 CRITICAL | Backend Integration | 6-8h | High | ❌ Not Started |
| 🔴 CRITICAL | Error Handling | 4-5h | High | ⚠️ Partial |
| 🔴 CRITICAL | Data Persistence | 2-3h | Medium | ⚠️ Partial |
| 🟡 HIGH | Push Notifications | 6-8h | Medium | ⚠️ Package Added |
| 🟡 HIGH | Deep Linking | 3-4h | High | ⚠️ Service Exists |
| 🟡 HIGH | Testing | 10-15h | Critical | ❌ Minimal |
| 🟢 MEDIUM | Accessibility | 4-6h | Medium | ⚠️ Basic |
| 🟢 MEDIUM | Performance | 5-7h | Medium | ❌ Not Started |
| 🟢 MEDIUM | Production Readiness | 8-10h | Low | ❌ Not Started |

**Total Critical Path:** ~20-27 hours of work

---

## 🎯 Recommended Implementation Order

### Sprint 1: Core Functionality (Must Have for Demo)
1. **Authentication System** (Day 1-2)
   - Login/Signup screens
   - Token management
   - Auth state handling

2. **Backend Integration** (Day 2-4)
   - API client setup
   - Migrate 2-3 key features to real API
   - Error handling

3. **Data Persistence** (Day 4)
   - Complete Hive integration
   - Offline support

### Sprint 2: Feature Completion
4. **Deep Linking** (Day 5)
   - Configure URL schemes
   - Test QR invite flow

5. **Push Notifications** (Day 5-6)
   - Basic FCM setup
   - Notification handling

6. **Testing** (Day 6-7)
   - Critical path tests
   - Basic coverage

### Sprint 3: Polish (Optional)
7. Accessibility improvements
8. Performance optimization
9. Production preparation

---

## 🚧 Known Blockers

1. **Firebase Windows/Web Compatibility**
   - Status: Blocking Windows/Chrome builds
   - Workaround: Test on Android emulator
   - Solution: Update Firebase packages or conditional compilation

2. **Android Emulator Detection**
   - Status: Emulator not detected by Flutter
   - Workaround: Use `flutter devices` to verify
   - Solution: Restart ADB or emulator

3. **Deprecated API Usage**
   - Status: ~450 deprecation warnings
   - Impact: Low (still compiles)
   - Solution: Migrate withOpacity → withValues (low priority)

---

## 📝 Notes

- **Code Quality:** Current code is well-structured with good separation of concerns
- **Architecture:** Solid foundation with Riverpod + go_router
- **Design System:** Excellent token-based design system already in place
- **Documentation:** Strong documentation (rare for student projects!)

**Biggest Gap:** No user authentication despite having a complete backend ready to go. This should be the #1 priority.

**Quick Win:** Authentication can be implemented in 4-6 hours and unblocks everything else.
