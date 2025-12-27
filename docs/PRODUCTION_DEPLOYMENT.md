# Production Deployment Guide

This guide covers deploying TaskFlow to production environments (Google Play Store and Apple App Store).

## Table of Contents
- [Prerequisites](#prerequisites)
- [Environment Configuration](#environment-configuration)
- [Build Variants](#build-variants)
- [Android Deployment](#android-deployment)
- [iOS Deployment](#ios-deployment)
- [Backend Deployment](#backend-deployment)
- [Post-Deployment](#post-deployment)

---

## Prerequisites

### Required Tools
- Flutter SDK (3.38.5+)
- Dart SDK (3.10.4+)
- Android Studio / Xcode
- Git
- Docker (for backend)

### Required Accounts
- Google Play Console account (Android)
- Apple Developer account (iOS)
- Firebase project
- App Store Connect access

### Required Files
- Android: Keystore file (`release.keystore`)
- iOS: Distribution certificate and provisioning profiles
- Firebase configuration files (`google-services.json`, `GoogleService-Info.plist`)

---

## Environment Configuration

### Development Environment
```bash
flutter run --dart-define=ENV=development --dart-define=ENABLE_LOGGING=true
```

### Staging Environment
```bash
flutter run --dart-define=ENV=staging --dart-define=API_BASE_URL=https://staging-api.taskflow.app
```

### Production Environment
```bash
flutter build apk --release --dart-define=ENV=production --dart-define=ENABLE_LOGGING=false
```

### Environment Variables

| Variable | Development | Staging | Production |
|----------|------------|---------|------------|
| `ENV` | `development` | `staging` | `production` |
| `API_BASE_URL` | `http://localhost:3000` | `https://staging-api.taskflow.app` | `https://api.taskflow.app` |
| `ENABLE_LOGGING` | `true` | `true` | `false` |
| `ENABLE_ANALYTICS` | `false` | `true` | `true` |
| `ENABLE_CRASH_REPORTING` | `false` | `true` | `true` |

---

## Build Variants

### Android Build Variants

#### Debug Build
```bash
flutter build apk --debug --dart-define=ENV=development
```

#### Release Build
```bash
flutter build apk --release \
  --dart-define=ENV=production \
  --dart-define=ENABLE_LOGGING=false \
  --dart-define=ENABLE_ANALYTICS=true
```

#### App Bundle (for Play Store)
```bash
flutter build appbundle --release \
  --dart-define=ENV=production \
  --dart-define=ENABLE_LOGGING=false
```

### iOS Build Variants

#### Debug Build
```bash
flutter build ios --debug --dart-define=ENV=development
```

#### Release Build
```bash
flutter build ios --release \
  --dart-define=ENV=production \
  --dart-define=ENABLE_LOGGING=false
```

---

## Android Deployment

### 1. Prepare Signing Configuration

Create `android/key.properties`:
```properties
storePassword=<your-keystore-password>
keyPassword=<your-key-password>
keyAlias=release
storeFile=../release.keystore
```

⚠️ **Never commit this file to Git!** Add to `.gitignore`.

### 2. Generate Keystore (First Time Only)

```bash
keytool -genkey -v -keystore release.keystore -alias release -keyalg RSA -keysize 2048 -validity 10000
```

Store the keystore file securely and backup the passwords!

### 3. Update `android/app/build.gradle`

Add signing configuration:
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

### 4. Build Release APK/AAB

```bash
# App Bundle (recommended for Play Store)
flutter build appbundle --release --dart-define=ENV=production

# APK (for direct distribution)
flutter build apk --release --dart-define=ENV=production --split-per-abi
```

Output: `build/app/outputs/bundle/release/app-release.aab`

### 5. Upload to Google Play Console

1. Go to [Google Play Console](https://play.google.com/console)
2. Navigate to **Production** → **Create new release**
3. Upload the AAB file
4. Fill in release notes
5. Review and roll out

### 6. ProGuard Rules (Optional)

Create `android/app/proguard-rules.pro`:
```proguard
# Keep Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }

# Keep Firebase
-keep class com.google.firebase.** { *; }

# Keep Socket.IO
-keep class io.socket.** { *; }
```

---

## iOS Deployment

### 1. Configure Xcode Project

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select **Runner** project
3. Go to **Signing & Capabilities**
4. Set **Team** to your Apple Developer team
5. Enable **Automatically manage signing**

### 2. Update Info.plist

Ensure required permissions are present in `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>TaskFlow needs camera access for QR code scanning and profile pictures</string>

<key>NSMicrophoneUsageDescription</key>
<string>TaskFlow needs microphone access for audio calls</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>TaskFlow needs photo library access to select images</string>
```

### 3. Build Release Archive

```bash
flutter build ios --release --dart-define=ENV=production
```

Then in Xcode:
1. Select **Any iOS Device (arm64)** as build target
2. Go to **Product** → **Archive**
3. Wait for archive to complete

### 4. Upload to App Store Connect

1. In Xcode Organizer, select the archive
2. Click **Distribute App**
3. Select **App Store Connect**
4. Follow the wizard to upload

### 5. Submit for Review

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Navigate to your app
3. Fill in app metadata:
   - Screenshots
   - Description
   - Keywords
   - Support URL
   - Privacy Policy URL
4. Submit for review

---

## Backend Deployment

### Option 1: Docker Deployment (Recommended)

See [DOCKER_SETUP.md](../DOCKER_SETUP.md) for complete Docker deployment guide.

Quick start:
```bash
cd backend
docker-compose up -d
```

### Option 2: Cloud Platform Deployment

#### Deploying to AWS EC2

```bash
# SSH into EC2 instance
ssh -i your-key.pem ec2-user@your-instance-ip

# Install Docker
sudo yum update -y
sudo yum install docker -y
sudo service docker start

# Clone repository
git clone https://github.com/yourusername/task-flow.git
cd task-flow/backend

# Set environment variables
cp .env.example .env
nano .env  # Edit with production values

# Start with Docker
docker-compose up -d
```

#### Deploying to Heroku

```bash
# Install Heroku CLI
npm install -g heroku

# Login
heroku login

# Create app
heroku create taskflow-backend

# Set environment variables
heroku config:set NODE_ENV=production
heroku config:set JWT_SECRET=your-secret-key

# Deploy
git subtree push --prefix backend heroku main
```

### Environment Variables for Backend

Create `.env` in `backend/`:
```env
NODE_ENV=production
PORT=3000
JWT_SECRET=your-super-secret-jwt-key-change-this
JWT_EXPIRES_IN=7d

# Database (if using)
DATABASE_URL=postgresql://user:password@host:5432/dbname

# Firebase (for push notifications)
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk@your-project.iam.gserviceaccount.com

# CORS
CORS_ORIGIN=https://app.taskflow.com

# Logging
LOG_LEVEL=info
```

---

## Post-Deployment

### 1. Verify Deployment

```bash
# Test API endpoint
curl https://api.taskflow.app/health

# Expected response:
# {"status":"ok","timestamp":"2025-12-27T..."}
```

### 2. Monitor Application

- Set up Firebase Crashlytics for crash reporting
- Configure Firebase Analytics for usage tracking
- Set up server monitoring (e.g., DataDog, New Relic)

### 3. Health Checks

Add health check endpoint in `backend/server.js`:
```javascript
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    version: process.env.npm_package_version
  });
});
```

### 4. Update DNS Records

Point your domain to the server:
```
A Record: api.taskflow.app → Your Server IP
```

### 5. SSL/TLS Certificate

Use Let's Encrypt for free SSL:
```bash
sudo apt-get install certbot
sudo certbot --nginx -d api.taskflow.app
```

---

## Version Management

### Semantic Versioning

Follow semantic versioning: `MAJOR.MINOR.PATCH`

Example: `1.2.3`
- `1` = Major version (breaking changes)
- `2` = Minor version (new features)
- `3` = Patch version (bug fixes)

### Updating Version

Update in `pubspec.yaml`:
```yaml
version: 1.2.3+4
# Format: MAJOR.MINOR.PATCH+BUILD_NUMBER
```

### Build Numbers

- **iOS**: Increment for every TestFlight build
- **Android**: Auto-incremented in `build.gradle`

---

## Release Checklist

### Pre-Release
- [ ] All tests passing
- [ ] Code reviewed and approved
- [ ] Version number updated
- [ ] Changelog updated
- [ ] Privacy Policy and Terms updated
- [ ] Firebase configured for production
- [ ] API endpoints using production URLs
- [ ] Logging disabled in production
- [ ] Analytics and crash reporting enabled

### Android Release
- [ ] Keystore generated and secured
- [ ] Signing configuration set up
- [ ] ProGuard rules configured
- [ ] App bundle built successfully
- [ ] Uploaded to Play Console
- [ ] Release notes written
- [ ] Screenshots updated

### iOS Release
- [ ] Code signing configured
- [ ] Certificates and profiles valid
- [ ] Archive built successfully
- [ ] Uploaded to App Store Connect
- [ ] Metadata filled in
- [ ] Screenshots uploaded
- [ ] Submitted for review

### Backend Release
- [ ] Production environment variables set
- [ ] Database migrations run
- [ ] SSL certificate configured
- [ ] Health checks passing
- [ ] Monitoring configured
- [ ] Backup strategy in place

### Post-Release
- [ ] Monitor crash reports
- [ ] Check analytics
- [ ] Respond to user reviews
- [ ] Monitor server logs
- [ ] Verify all features working

---

## Troubleshooting

### Build Failed

```bash
# Clean build
flutter clean
flutter pub get
flutter build apk --release
```

### Signing Issues (Android)

```bash
# Verify keystore
keytool -list -v -keystore release.keystore
```

### Xcode Archive Failed (iOS)

1. Clean build folder: **Product** → **Clean Build Folder**
2. Restart Xcode
3. Try archiving again

### App Rejected

Common reasons:
- Missing privacy policy
- Incomplete metadata
- Crashes on launch
- Missing required screenshots
- Violates app store guidelines

---

## Security Best Practices

1. **Never commit secrets to Git**
   - Use `.env` files
   - Add to `.gitignore`

2. **Use HTTPS only**
   - Force SSL on backend
   - No mixed content

3. **Implement certificate pinning**
   ```dart
   // In Dio configuration
   final dio = Dio()
     ..httpClientAdapter = IOHttpClientAdapter()
     ..options.connectTimeout = Duration(seconds: 30);
   ```

4. **Obfuscate code**
   ```bash
   flutter build apk --obfuscate --split-debug-info=build/debug-info
   ```

5. **Validate all inputs**
   - Sanitize user input
   - Use prepared statements for DB

---

## Support

For deployment issues:
- Documentation: [https://taskflow.app/docs](https://taskflow.app/docs)
- Email: support@taskflow.app
- GitHub Issues: [https://github.com/yourusername/task-flow/issues](https://github.com/yourusername/task-flow/issues)

---

**Last Updated**: December 27, 2025
