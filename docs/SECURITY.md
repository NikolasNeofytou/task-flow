# Security Guide

This document outlines security best practices and configurations for TaskFlow.

## Table of Contents
- [Authentication & Authorization](#authentication--authorization)
- [Data Security](#data-security)
- [Network Security](#network-security)
- [Code Security](#code-security)
- [Deployment Security](#deployment-security)
- [Monitoring & Incident Response](#monitoring--incident-response)

---

## Authentication & Authorization

### JWT Token Security

**Backend Implementation:**
```javascript
// Strong secret generation
const JWT_SECRET = process.env.JWT_SECRET || crypto.randomBytes(64).toString('hex');

// Token configuration
const jwtOptions = {
  expiresIn: '7d',
  issuer: 'taskflow-api',
  audience: 'taskflow-app'
};

// Generate token
const token = jwt.sign(
  { userId: user.id, email: user.email },
  JWT_SECRET,
  jwtOptions
);
```

**Frontend Storage:**
```dart
// Use flutter_secure_storage for tokens
final storage = FlutterSecureStorage();

// Store token
await storage.write(key: 'auth_token', value: token);

// Read token
final token = await storage.read(key: 'auth_token');

// Delete token on logout
await storage.delete(key: 'auth_token');
```

### Password Security

**Backend - Password Hashing:**
```javascript
const bcrypt = require('bcrypt');
const saltRounds = 12;

// Hash password
const hashedPassword = await bcrypt.hash(password, saltRounds);

// Verify password
const isValid = await bcrypt.compare(password, hashedPassword);
```

**Frontend - Password Requirements:**
```dart
String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Password is required';
  }
  if (value.length < 8) {
    return 'Password must be at least 8 characters';
  }
  if (!RegExp(r'[A-Z]').hasMatch(value)) {
    return 'Password must contain uppercase letter';
  }
  if (!RegExp(r'[a-z]').hasMatch(value)) {
    return 'Password must contain lowercase letter';
  }
  if (!RegExp(r'[0-9]').hasMatch(value)) {
    return 'Password must contain number';
  }
  return null;
}
```

### Session Management

**Token Refresh:**
```dart
class AuthService {
  Future<void> refreshTokenIfNeeded() async {
    final token = await _storage.read(key: 'auth_token');
    if (token != null) {
      final decoded = JwtDecoder.decode(token);
      final expiryDate = DateTime.fromMillisecondsSinceEpoch(
        decoded['exp'] * 1000
      );
      
      // Refresh 1 hour before expiry
      if (expiryDate.difference(DateTime.now()).inHours < 1) {
        await _refreshToken();
      }
    }
  }
}
```

---

## Data Security

### Secure Storage

**Sensitive Data:**
```dart
// Use flutter_secure_storage for:
// - Auth tokens
// - API keys
// - User credentials
// - Encryption keys

final storage = FlutterSecureStorage(
  aOptions: AndroidOptions(
    encryptedSharedPreferences: true,
  ),
  iOptions: IOSOptions(
    accessibility: KeychainAccessibility.first_unlock,
  ),
);
```

**Local Database Encryption:**
```dart
// Use sqflite with sqlcipher for encrypted database
import 'package:sqflite_sqlcipher/sqflite.dart';

final database = await openDatabase(
  path,
  password: encryptionKey,
  version: 1,
);
```

### Data Validation

**Input Sanitization:**
```dart
String sanitizeInput(String input) {
  return input
    .replaceAll(RegExp(r'<script[^>]*>.*?</script>'), '')
    .replaceAll(RegExp(r'[<>]'), '')
    .trim();
}
```

**Backend Validation:**
```javascript
const validator = require('validator');

function validateEmail(email) {
  return validator.isEmail(email);
}

function sanitizeInput(input) {
  return validator.escape(input.trim());
}
```

---

## Network Security

### HTTPS Only

**Backend Configuration:**
```javascript
// Redirect HTTP to HTTPS
app.use((req, res, next) => {
  if (process.env.NODE_ENV === 'production' && !req.secure) {
    return res.redirect(301, `https://${req.headers.host}${req.url}`);
  }
  next();
});

// Set security headers
const helmet = require('helmet');
app.use(helmet());
```

**Frontend Configuration:**
```dart
// ApiConfig ensures HTTPS in production
static String get baseUrl {
  if (environment == Environment.production) {
    return 'https://api.taskflow.app'; // HTTPS only!
  }
  // ...
}
```

### Certificate Pinning

**Implementation:**
```dart
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

class SecureHttpClient {
  static Dio createSecureClient() {
    final dio = Dio();
    
    (dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate = 
      (client) {
        client.badCertificateCallback = 
          (X509Certificate cert, String host, int port) {
            // Pin your certificate
            return cert.sha256.toString() == 'YOUR_CERT_SHA256';
          };
        return client;
      };
    
    return dio;
  }
}
```

### API Security

**Rate Limiting:**
```javascript
const rateLimit = require('express-rate-limit');

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
  message: 'Too many requests from this IP'
});

app.use('/api/', limiter);
```

**CORS Configuration:**
```javascript
const cors = require('cors');

app.use(cors({
  origin: process.env.CORS_ORIGIN || 'https://app.taskflow.com',
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));
```

---

## Code Security

### Code Obfuscation

**Build Command:**
```bash
flutter build apk --release \
  --obfuscate \
  --split-debug-info=build/debug-info
```

**ProGuard Configuration:**
See `android/app/proguard-rules.pro` for rules.

### Secrets Management

**Environment Variables:**
```bash
# NEVER commit these files:
.env
.env.local
key.properties
google-services.json (with real keys)
GoogleService-Info.plist (with real keys)
```

**Git Ignore:**
```gitignore
# Secrets
.env
.env.*
*.key
*.keystore
*.jks
key.properties

# Firebase
google-services.json
GoogleService-Info.plist

# iOS
ios/Runner/GoogleService-Info.plist
```

### Dependency Security

**Regular Updates:**
```bash
# Check for outdated packages
flutter pub outdated

# Update dependencies
flutter pub upgrade

# Audit for vulnerabilities
npm audit (for backend)
```

---

## Deployment Security

### Android Security

**App Signing:**
```gradle
// Use Play App Signing
// Google manages your signing key
android {
    signingConfigs {
        release {
            // Use upload keystore, not release keystore
        }
    }
}
```

**Security Config:**
Create `android/app/src/main/res/xml/network_security_config.xml`:
```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <!-- Production - HTTPS only -->
    <base-config cleartextTrafficPermitted="false">
        <trust-anchors>
            <certificates src="system" />
        </trust-anchors>
    </base-config>
    
    <!-- Development - Allow localhost -->
    <domain-config cleartextTrafficPermitted="true">
        <domain includeSubdomains="true">localhost</domain>
        <domain includeSubdomains="true">10.0.2.2</domain>
    </domain-config>
</network-security-config>
```

### iOS Security

**App Transport Security:**
`ios/Runner/Info.plist`:
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <!-- Allow only HTTPS in production -->
    <key>NSAllowsArbitraryLoads</key>
    <false/>
    
    <!-- Development exception -->
    <key>NSExceptionDomains</key>
    <dict>
        <key>localhost</key>
        <dict>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <true/>
        </dict>
    </dict>
</dict>
```

### Backend Security

**Environment Variables:**
```env
# Use strong secrets
JWT_SECRET=$(openssl rand -base64 64)

# Database credentials
DB_PASSWORD=$(openssl rand -base64 32)

# API keys (use key management service)
FIREBASE_PRIVATE_KEY="..."
```

**Server Hardening:**
```javascript
// Hide Express
app.disable('x-powered-by');

// Security headers
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
    },
  },
  hsts: {
    maxAge: 31536000,
    includeSubDomains: true,
    preload: true
  }
}));

// Request validation
app.use(express.json({ limit: '10mb' }));
```

---

## Monitoring & Incident Response

### Logging

**Secure Logging:**
```dart
void logSecurely(String message, {Object? error}) {
  // Never log sensitive data
  final sanitized = message
    .replaceAll(RegExp(r'password.*', caseSensitive: false), '[REDACTED]')
    .replaceAll(RegExp(r'token.*', caseSensitive: false), '[REDACTED]');
  
  if (ApiConfig.enableLogging) {
    print('[$level] $sanitized');
  }
}
```

**Backend Logging:**
```javascript
const winston = require('winston');

const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: winston.format.json(),
  transports: [
    new winston.transports.File({ filename: 'error.log', level: 'error' }),
    new winston.transports.File({ filename: 'combined.log' })
  ]
});

// Never log sensitive data
logger.info('User login', {
  userId: user.id,
  // DON'T log password, token, etc.
});
```

### Crash Reporting

**Firebase Crashlytics:**
```dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Enable Crashlytics
  if (ApiConfig.enableCrashReporting) {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    
    // Catch async errors
    runZonedGuarded(() {
      runApp(MyApp());
    }, (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack);
    });
  } else {
    runApp(MyApp());
  }
}
```

### Security Monitoring

**Suspicious Activity Detection:**
```javascript
// Track failed login attempts
const loginAttempts = new Map();

function checkLoginAttempts(ip) {
  const attempts = loginAttempts.get(ip) || 0;
  
  if (attempts > 5) {
    throw new Error('Too many failed login attempts');
  }
  
  loginAttempts.set(ip, attempts + 1);
  
  // Clear after 15 minutes
  setTimeout(() => {
    loginAttempts.delete(ip);
  }, 15 * 60 * 1000);
}
```

### Incident Response Plan

1. **Detection**: Monitor logs and crash reports
2. **Containment**: Disable affected features via feature flags
3. **Investigation**: Analyze logs and user reports
4. **Remediation**: Deploy hotfix
5. **Recovery**: Re-enable features, monitor closely
6. **Post-Incident**: Document and improve

---

## Security Checklist

### Development
- [ ] Use HTTPS in production
- [ ] Validate all inputs
- [ ] Sanitize user data
- [ ] Never log sensitive information
- [ ] Use secure storage for tokens
- [ ] Implement certificate pinning

### Build
- [ ] Enable code obfuscation
- [ ] Remove debug symbols
- [ ] Configure ProGuard/R8
- [ ] Sign with release keys
- [ ] Disable logging in production

### Deployment
- [ ] Use environment variables for secrets
- [ ] Never commit API keys
- [ ] Configure CORS properly
- [ ] Enable rate limiting
- [ ] Set up monitoring
- [ ] Use security headers

### Maintenance
- [ ] Regular dependency updates
- [ ] Security audits
- [ ] Penetration testing
- [ ] Monitor crash reports
- [ ] Review access logs
- [ ] Rotate secrets periodically

---

## Resources

- [OWASP Mobile Security](https://owasp.org/www-project-mobile-security/)
- [Flutter Security](https://flutter.dev/docs/deployment/obfuscate)
- [Node.js Security Best Practices](https://nodejs.org/en/docs/guides/security/)

---

**Security Contact**: security@taskflow.app

**Last Updated**: December 27, 2025
