# Firebase Cloud Messaging (FCM) Setup Guide

## Overview
TaskFlow uses Firebase Cloud Messaging for push notifications. This guide explains how to set up FCM for Android and iOS.

## Current Implementation Status
✅ **Flutter Service**: `PushNotificationService` - Complete  
✅ **Backend Endpoints**: FCM token registration - Complete  
⚠️ **Firebase Config**: Platform configs needed  
⚠️ **Firebase Admin SDK**: Backend sending needs setup  

---

## Prerequisites
1. Firebase project created at [Firebase Console](https://console.firebase.google.com/)
2. Flutter project added to Firebase project
3. Firebase CLI installed: `npm install -g firebase-tools`

---

## Android Setup

### 1. Download google-services.json
1. Go to Firebase Console → Project Settings → Your Apps
2. Select Android app (or create one)
3. Download `google-services.json`
4. Place it in: `android/app/google-services.json`

### 2. Update android/build.gradle
```gradle
buildscript {
    dependencies {
        // ... existing dependencies
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

### 3. Update android/app/build.gradle
```gradle
apply plugin: 'com.android.application'
apply plugin: 'com.google.gms.google-services'  // Add this line

android {
    // ... existing config
}

dependencies {
    // ... existing dependencies
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    implementation 'com.google.firebase:firebase-messaging'
}
```

### 4. Update AndroidManifest.xml
```xml
<manifest>
    <application>
        <!-- ... existing config -->
        
        <!-- FCM Service -->
        <service
            android:name="com.google.firebase.messaging.FirebaseMessagingService"
            android:exported="false">
            <intent-filter>
                <action android:name="com.google.firebase.MESSAGING_EVENT" />
            </intent-filter>
        </service>
        
        <!-- FCM Default Channel (for Android 8.0+) -->
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_channel_id"
            android:value="default_channel" />
    </application>
</manifest>
```

---

## iOS Setup

### 1. Download GoogleService-Info.plist
1. Go to Firebase Console → Project Settings → Your Apps
2. Select iOS app (or create one)
3. Download `GoogleService-Info.plist`
4. Place it in: `ios/Runner/GoogleService-Info.plist`

### 2. Update ios/Podfile
```ruby
platform :ios, '13.0'

target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
  
  # Add Firebase pods
  pod 'FirebaseMessaging'
end
```

### 3. Enable Push Notifications Capability
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select Runner target → Signing & Capabilities
3. Click `+ Capability` → Push Notifications
4. Click `+ Capability` → Background Modes
5. Check "Remote notifications"

### 4. Update AppDelegate.swift
```swift
import UIKit
import Flutter
import FirebaseCore
import FirebaseMessaging

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  override func application(_ application: UIApplication,
                            didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    Messaging.messaging().apnsToken = deviceToken
  }
}
```

### 5. Create APNs Key
1. Go to [Apple Developer](https://developer.apple.com/account/resources/authkeys/list)
2. Create new key → Enable "Apple Push Notifications service (APNs)"
3. Download .p8 file
4. Upload to Firebase Console → Project Settings → Cloud Messaging → APNs Certificates

---

## Backend Setup (Node.js)

### 1. Install Firebase Admin SDK
```bash
cd backend
npm install firebase-admin
```

### 2. Download Service Account Key
1. Firebase Console → Project Settings → Service Accounts
2. Click "Generate new private key"
3. Save as `backend/firebase-service-account.json`
4. **⚠️ Add to .gitignore** (contains secrets!)

### 3. Initialize Firebase Admin
Create `backend/services/firebase.js`:
```javascript
const admin = require('firebase-admin');
const serviceAccount = require('../firebase-service-account.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const messaging = admin.messaging();

module.exports = { messaging };
```

### 4. Update push.js Route
Replace mock implementation in `backend/routes/push.js`:
```javascript
const { messaging } = require('../services/firebase');

// In sendPushToUser function:
async function sendPushToUser(userId, title, body, data = {}) {
  const userTokens = fcmTokens.get(userId) || [];
  const tokens = userTokens.map(t => t.token);

  if (tokens.length === 0) {
    console.log(`[PUSH] No devices for user ${userId}`);
    return;
  }

  const message = {
    notification: { title, body },
    data: data,
    tokens: tokens,
  };

  try {
    const response = await messaging.sendMulticast(message);
    console.log(`[PUSH] Sent ${response.successCount} messages to user ${userId}`);
  } catch (error) {
    console.error('[PUSH] Error sending:', error);
  }
}
```

---

## Testing

### 1. Test Token Registration
```bash
# Login first
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"demo@taskflow.com","password":"demo123"}'

# Register device (use token from response)
curl -X POST http://localhost:3000/api/notifications/register-device \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{"fcmToken":"test-token-123","platform":"android"}'
```

### 2. Send Test Notification
```bash
curl -X POST http://localhost:3000/api/notifications/send-push \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "userIds": ["user1"],
    "title": "Test Notification",
    "body": "This is a test push notification",
    "data": {"taskId": "task123"}
  }'
```

### 3. Test on Physical Device
- Emulators don't support push notifications
- Use Android device or iPhone with Google Play Services
- Check Firebase Console → Cloud Messaging for delivery stats

---

## Notification Payload Format

Notifications use this data structure for deep linking:
```json
{
  "notification": {
    "title": "New task assigned",
    "body": "Alice assigned you: Review PR #42"
  },
  "data": {
    "type": "task",
    "taskId": "task123",
    "projectId": "proj1"
  }
}
```

The app automatically converts data payload to deep links:
- `taskId` → `taskflow://task/123`
- `projectId` → `taskflow://project/456`
- `notificationId` → `taskflow://notification/789`

---

## Troubleshooting

### Android: "Default FirebaseApp is not initialized"
- Ensure `google-services.json` is in `android/app/`
- Run `flutter clean && flutter pub get`
- Rebuild app

### iOS: "No APNs token for device"
- Enable Push Notifications capability in Xcode
- Upload APNs key to Firebase Console
- Test on physical device (not simulator)

### Backend: "Failed to send notification"
- Check Firebase service account key is valid
- Ensure FCM tokens are registered
- Check Firebase Console quota limits

### Windows Development Issue
- Firebase may have CMake errors on Windows
- Develop/test on Android emulator or physical device
- Backend can still mock push notifications for development

---

## Production Checklist
- [ ] Firebase project created
- [ ] Android: google-services.json added
- [ ] iOS: GoogleService-Info.plist added
- [ ] iOS: APNs key uploaded to Firebase
- [ ] Backend: Firebase Admin SDK configured
- [ ] Backend: Service account key secured (not in git)
- [ ] Notification permissions requested
- [ ] Deep linking tested with notification taps
- [ ] Tested on physical devices
- [ ] Firebase Console monitoring enabled
