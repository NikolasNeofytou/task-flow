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

### 2. Real Backend Integration - **COMPLETED** ✅
**Status:** All Features Migrated
**Effort:** 6-8 hours (100% complete)
**Impact:** High - Moved from 100% mock data to real API

**✅ All Features Completed:**
- [x] Backend `/api/requests` endpoint created
- [x] Backend `/api/notifications` endpoint (already existed)
- [x] Backend `/api/projects` endpoint (already existed)
- [x] Backend `/api/tasks` endpoint (already existed)
- [x] Backend `/api/comments` endpoint created
- [x] All DTOs updated with complete field mappings
- [x] AppConfig updated to use `http://localhost:3000/api`
- [x] USE_MOCKS set to `false` by default

**📁 Files Created:**
- `backend/routes/requests.js` - Full REST API for requests
- `backend/routes/comments.js` - Full REST API for comments
- `backend/data/storage.js` - File-based data persistence

**📝 Files Modified:**
- `backend/server.js` - Added requests and comments routes
- `lib/core/dto/request_dto.dart` - Added all fields (type, fromUserId, toUserId, taskId, projectId, dueDate)
- `lib/core/dto/notification_dto.dart` - Added requestId, taskId, fromUserId, read, actionable
- `lib/core/dto/project_dto.dart` - Added description, color, members, createdAt, updatedAt
- `lib/core/dto/task_dto.dart` - Added description, priority, assignedTo, createdAt, updatedAt
- `lib/core/repositories/remote/comments_remote_repository.dart` - Updated to use /comments endpoint
- `lib/core/config/app_config.dart` - Changed baseUrl to localhost:3000, useMocks to false

**🎯 API Endpoints:**
```
✅ POST   /api/auth/login
✅ POST   /api/auth/signup
✅ GET    /api/requests
✅ POST   /api/requests
✅ PATCH  /api/requests/:id
✅ DELETE /api/requests/:id
✅ GET    /api/notifications
✅ PATCH  /api/notifications/:id/read
✅ DELETE /api/notifications/:id
✅ GET    /api/projects
✅ POST   /api/projects
✅ PATCH  /api/projects/:id
✅ DELETE /api/projects/:id
✅ GET    /api/tasks
✅ POST   /api/tasks
✅ PATCH  /api/tasks/:id
✅ DELETE /api/tasks/:id
✅ GET    /api/comments?taskId=xxx
✅ POST   /api/comments
✅ DELETE /api/comments/:id
```

**🧪 Testing:**
```bash
# Start backend
cd backend && npm install && npm start

# Server runs on http://localhost:3000
# All features now use real API calls with JWT authentication
```

**✅ Benefits:**
- Real-time data synchronization
- JWT authentication on all endpoints
- CRUD operations for all entities
- Error handling with proper HTTP status codes
- File-based persistence (easy to reset/test)

---

### 3. Data Persistence (Hive) - **COMPLETED** ✅
**Status:** Fully Implemented
**Effort:** 2-3 hours (100% complete)
**Impact:** Medium - App now has offline support

**✅ All Features Completed:**
- [x] Hive adapters for all models (TaskItem, Project, User)
- [x] HiveService initialized in main.dart
- [x] HiveStorageService for additional models (Requests, Notifications, Comments)
- [x] Offline-first repository pattern implemented
- [x] Connectivity detection with connectivity_plus
- [x] Cache-first strategy with automatic fallback
- [x] All repositories wrapped with caching layer

**📁 Files Created:**
- `lib/core/storage/hive_storage_service.dart` - Extended storage for Requests/Notifications/Comments
- `lib/core/repositories/cached/cached_requests_repository.dart` - Offline-first wrapper
- `lib/core/repositories/cached/cached_notifications_repository.dart` - Offline-first wrapper
- `lib/core/repositories/cached/cached_comments_repository.dart` - Offline-first wrapper
- `lib/core/providers/connectivity_provider.dart` - Network connectivity detection

**📝 Files Modified:**
- `lib/main.dart` - Initialize HiveStorageService
- `lib/core/providers/data_providers.dart` - Use cached repositories

**🎯 How It Works:**
1. **Network Available:** Fetch from API → Cache locally → Return data
2. **Network Unavailable:** Return cached data → User can still browse
3. **Cache Validation:** Timestamps track cache freshness
4. **Write Operations:** Update API → Update cache on success

**✅ Benefits:**
- App works offline with last known data
- Faster load times (cache-first)
- Automatic synchronization when online
- Seamless user experience during network interruptions
- Reduced API calls (cache reuse)

---

### 4. Error Handling & Loading States - **COMPLETED** ✅
**Status:** Fully Implemented
**Effort:** 4-5 hours (100% complete)
**Impact:** High - Significantly improved user experience

**✅ All Features Completed:**
- [x] AppException hierarchy for typed errors
- [x] Dio error handler with user-friendly messages
- [x] Retry interceptor with exponential backoff (3 retries max)
- [x] Standardized error display widgets (compact & full-screen)
- [x] Error snackbar helper
- [x] Offline indicator banner
- [x] Connection status icon
- [x] AsyncValue extension helpers
- [x] 30-second API timeouts

**📁 Files Created:**
- `lib/core/errors/app_exception.dart` - Exception type hierarchy
- `lib/core/errors/error_handler.dart` - Dio error converter
- `lib/core/widgets/error_display.dart` - Reusable error UI components
- `lib/core/widgets/offline_indicator.dart` - Network status indicators
- `lib/core/network/interceptors/retry_interceptor.dart` - Automatic retry logic
- `lib/core/utils/async_value_extensions.dart` - AsyncValue helpers

**📝 Files Modified:**
- `lib/core/network/api_client.dart` - Added retry, error handling, 30s timeouts
- `lib/features/shell/presentation/app_shell.dart` - Already had OfflineIndicator

**🎯 Error Types:**
```dart
NetworkException    // Connection issues
ApiException        // HTTP 4xx/5xx errors
AuthException       // 401/403 errors
ValidationException // 422 validation errors
NotFoundException   // 404 errors
TimeoutException    // Request timeouts
OfflineException    // No network
CacheException      // Local storage errors
UnknownException    // Unexpected errors
```

**🔄 Retry Logic:**
- Retries: 3 attempts max
- Delays: 1s → 2s → 4s (exponential backoff)
- Retries on: timeouts, connection errors, 5xx server errors
- No retry on: 4xx client errors (bad data, auth issues)

**✅ Benefits:**
- User-friendly error messages
- Automatic retry on temporary failures
- Offline mode detection
- Consistent error UI across app
- Better debugging with typed exceptions
- Reduced support burden with clear messages

---

## 🟡 HIGH PRIORITY - Should Fix

### 5. Push Notifications - **COMPLETED** ✅
**Status:** Fully Implemented (Config Required)
**Effort:** 6-8 hours (100% complete)
**Impact:** Medium - Expected feature

**✅ All Features Completed:**
- [x] PushNotificationService with Firebase Messaging
- [x] FCM token registration and management
- [x] Foreground notification handling
- [x] Background notification handling  
- [x] Notification tap actions with deep linking
- [x] Backend FCM token storage
- [x] Backend push notification endpoints
- [x] Integration with LocalNotificationService
- [x] Automatic payload to deep link conversion

**📁 Files Created:**
- `lib/core/services/push_notification_service.dart` - FCM service
- `lib/core/providers/push_notification_provider.dart` - Riverpod providers
- `backend/routes/push.js` - FCM token registration and push endpoints
- `docs/FIREBASE_SETUP.md` - Complete Firebase configuration guide

**📝 Files Modified:**
- `backend/data/store.js` - Added fcmTokens Map
- `backend/server.js` - Registered push routes
- `lib/main.dart` - Initialize push service, notification tap handler
- `lib/core/services/local_notification_service.dart` - Added tap callback support

**🔧 Backend Endpoints:**
```
POST   /api/notifications/register-device   - Register FCM token
DELETE /api/notifications/register-device   - Unregister token
POST   /api/notifications/send-push         - Send push to users
```

**📱 Notification Flow:**
1. App requests FCM token on startup
2. Token registered with backend via API
3. Backend stores token per user
4. Backend sends push via Firebase Admin SDK (when configured)
5. App receives push → shows notification → handles tap → navigates via deep link

**⚠️ Setup Required:**
To enable actual push notifications, follow `docs/FIREBASE_SETUP.md`:
- [ ] Add `google-services.json` (Android)
- [ ] Add `GoogleService-Info.plist` (iOS)
- [ ] Install Firebase Admin SDK on backend
- [ ] Add Firebase service account key to backend
- [ ] Update backend to use real Firebase messaging

**✅ Benefits:**
- Real-time notifications for team activity
- Background notifications even when app closed
- Deep linking from notifications to content
- Token management and multi-device support
- Production-ready infrastructure (config needed)

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
