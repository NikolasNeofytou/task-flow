# Authentication System Testing Guide

## Quick Test Checklist

### Setup
1. ✅ Backend server running: `cd backend && npm start`
2. ✅ Flutter app running: `flutter run -d windows`

### Test Scenarios

#### 1. First Launch (No Auth)
- [ ] App opens to Splash screen
- [ ] Auto-redirects to Login screen after ~1s
- [ ] Can't access other routes without logging in

#### 2. Login Flow
**Test with demo credentials:**
- Email: `demo@taskflow.com`
- Password: `demo123`

**Steps:**
- [ ] Enter credentials
- [ ] Click "Sign In"
- [ ] Loading indicator shows
- [ ] On success → redirects to Calendar
- [ ] Token stored securely

**Error Cases:**
- [ ] Wrong password → shows error message
- [ ] Invalid email format → validation error
- [ ] Empty fields → validation errors

#### 3. Signup Flow
- [ ] Click "Create Account" from login
- [ ] Opens signup screen
- [ ] Enter name, email, password, confirm password
- [ ] Passwords must match
- [ ] On success → redirects to Calendar
- [ ] New user created in backend

#### 4. Authenticated State
- [ ] Can access Calendar
- [ ] Can access Projects
- [ ] Can access Requests
- [ ] Can access Chat
- [ ] Can access Profile
- [ ] All API calls include Bearer token

#### 5. Logout Flow
- [ ] Go to Profile
- [ ] Click "Logout" tile
- [ ] Confirmation dialog appears
- [ ] Click "Logout" button
- [ ] Token cleared from storage
- [ ] Auto-redirects to Login
- [ ] Can't access protected routes

#### 6. Persistent Auth
- [ ] Login successfully
- [ ] Close app completely
- [ ] Reopen app
- [ ] Should go to Splash → Calendar (skip login)
- [ ] Token still valid

#### 7. Token Expiration
- [ ] Login successfully
- [ ] Wait for token to expire (or manually invalidate)
- [ ] Make API call
- [ ] Should auto-logout on 401
- [ ] Redirects to Login

## Manual Testing Commands

### Start Backend Server
```powershell
cd backend
npm install  # First time only
npm start    # Server on http://localhost:3000
```

### Start Flutter App
```powershell
flutter run -d windows
```

### Check Token Storage
You can use Flutter DevTools to inspect FlutterSecureStorage:
```dart
// In debug console:
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
final storage = FlutterSecureStorage();
final token = await storage.read(key: 'auth_token');
print(token);
```

### Test API Endpoints Directly

#### Login
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "demo@taskflow.com",
    "password": "demo123"
  }'
```

#### Signup
```bash
curl -X POST http://localhost:3000/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "email": "newuser@test.com",
    "password": "password123",
    "displayName": "New User"
  }'
```

#### Protected Endpoint (with token)
```bash
curl http://localhost:3000/api/requests \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

## Known Issues

### Issue 1: Backend not running
**Symptom:** Login/Signup shows "Network error"
**Fix:** Start backend server: `cd backend && npm start`

### Issue 2: CORS errors
**Symptom:** Browser console shows CORS errors
**Fix:** Backend already configured for CORS, check server.js

### Issue 3: Token not persisting
**Symptom:** Must login every time app restarts
**Fix:** Check FlutterSecureStorage permissions

### Issue 4: Redirect loop
**Symptom:** App keeps redirecting between screens
**Fix:** Clear app storage and restart

## Success Criteria

All checkboxes above should be checked ✅

**Priority Tests:**
1. ✅ Login with demo credentials
2. ✅ Logout and redirect
3. ✅ Token persists after app restart
4. ✅ Can't access routes without auth

## Next Steps After Testing

Once authentication is verified:
1. Migrate Requests feature to real API
2. Add token refresh logic
3. Implement "Remember Me" option
4. Add biometric authentication
5. Add social login (Google, Apple)
