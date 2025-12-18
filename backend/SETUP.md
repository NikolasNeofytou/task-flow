# Quick Setup Guide

## Option 1: Local Installation (Recommended)

Due to Google Drive sync issues with npm, it's recommended to copy the backend to a local folder:

```powershell
# Copy backend folder to local drive
Copy-Item "G:\My Drive\university\semester_7\human computer interaction\backend" -Destination "C:\taskflow-backend" -Recurse

# Navigate to local folder
cd C:\taskflow-backend

# Install dependencies
npm install

# Start server
npm start
```

## Option 2: Direct Installation

If you want to keep it in Google Drive:

```powershell
cd "G:\My Drive\university\semester_7\human computer interaction\backend"

# Clear cache if needed
npm cache clean --force

# Install with retry
npm install --verbose

# Or install without optional dependencies
npm install --no-optional

# Start server
npm start
```

## Verify Installation

Once installed, test the server:

```powershell
# Start server
npm start

# In another terminal, test:
curl http://localhost:3000/health
```

You should see: `{"status":"ok","timestamp":"..."}`

## Common Issues

### EBADF / EPERM Errors
- **Cause**: Google Drive sync conflicts with npm
- **Solution**: Copy backend folder to C:\ drive

### Port Already in Use
```powershell
# Find process using port 3000
netstat -ano | findstr :3000

# Kill process (replace PID)
taskkill /PID <PID> /F
```

### Missing Dependencies
```powershell
npm install --save express socket.io cors bcryptjs jsonwebtoken uuid dotenv multer compression helmet express-rate-limit
```
