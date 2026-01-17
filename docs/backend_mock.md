# Backend Architecture - Current Implementation

## Current Status: No Backend Required ✅

**For this academic submission, TaskFlow operates completely offline using local device storage.**

## Architecture Overview

### Mock Data System
- **Location**: `lib/core/data/mock_data.dart`
- **Purpose**: Provides sample data for demonstration
- **Integration**: Works with local storage providers

### Local Storage Stack
1. **FlutterSecureStorage**: User profiles, authentication
2. **SharedPreferences**: App settings, non-sensitive data  
3. **Mock Repositories**: In-memory data simulation

## Optional Mock Backend Server

The `backend_mock/` directory contains an optional Node.js server for testing network integration, but it's **not required** for the current implementation.

### If You Want to Test the Mock Backend:

**Start Server:**
```bash
cd backend_mock
npm install
npm start   # Runs on http://localhost:4000
```

**Configure Flutter to Use It:**
```bash
flutter run --dart-define=API_BASE_URL=http://localhost:4000 --dart-define=USE_MOCKS=false
```

**Available Endpoints:**
- GET `/requests` - Mock task requests
- GET `/notifications` - Mock notifications  
- GET `/projects` - Mock projects
- GET `/calendar/tasks` - Mock calendar tasks

## Academic Compliance

✅ **Self-Contained**: No external dependencies required  
✅ **Persistent Data**: Local storage survives app restarts  
✅ **Mock Authentication**: Any credentials work for demonstration  
✅ **Offline First**: Complete functionality without internet

**For academic submission, simply use:**
```bash
.\quick_start.ps1
```

This starts the app with the default local storage configuration.
