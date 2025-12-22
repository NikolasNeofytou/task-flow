# QR Code Testing Guide

## 🎉 App is Running!

The TaskFlow app is now running in Chrome. You can test all the new QR code features!

## 🔗 Quick Access URLs

Navigate to these URLs in the Chrome browser that opened:

### Main Testing Screen
```
http://localhost:51761/#/testing/qr
```
This screen provides easy access to all QR features with descriptions.

### Direct Feature URLs

**Enhanced Personal QR Screen**
```
http://localhost:51761/#/profile/qr/enhanced
```
Test: Custom QR styles, sharing, exporting

**QR Management Screen (Project Invites)**
```
http://localhost:51761/#/projects/1/qr/manage
```
Test: Create invites with expiration, single-use tokens, revocation

**QR Analytics Dashboard**
```
http://localhost:51761/#/profile/qr/analytics
```
Test: View usage statistics, popular QRs, share methods

## 🧪 Testing Checklist

### 1. Enhanced Personal QR Screen
- [ ] Change QR style using the color picker (6 themes available)
- [ ] Click "Share QR Code" button
- [ ] Click "Export as Image" button
- [ ] Verify QR code updates with different styles
- [ ] Check haptic feedback on button presses

### 2. QR Management Screen
- [ ] Click "Create Invite" button
- [ ] Set expiration time (1 hour, 24 hours, 7 days, 30 days)
- [ ] Toggle "Single Use" option
- [ ] Set max uses if not single-use
- [ ] Create the invite and verify it appears in "Active" tab
- [ ] Click the QR code to view it full screen
- [ ] Click "Revoke" on an active invite
- [ ] Verify it moves to "Revoked" tab
- [ ] Switch between Active/Expired/Revoked tabs

### 3. QR Analytics Dashboard
- [ ] View overview statistics (generations, scans, shares, exports)
- [ ] Check activity trends
- [ ] View popular QRs list
- [ ] See share method distribution
- [ ] Check cache statistics
- [ ] Test refresh button

### 4. Offline Functionality
- [ ] Open DevTools (F12) → Network tab
- [ ] Set network to "Offline"
- [ ] Navigate to Enhanced Personal QR screen
- [ ] Verify QR code still displays (cached)
- [ ] Try creating an invite (should queue)
- [ ] Restore network and verify queued operations

### 5. Sharing Features
- [ ] Click share button (may have limited functionality in web)
- [ ] Export as image
- [ ] Check downloaded file in Downloads folder
- [ ] Verify image contains QR code with selected style

## 📱 Testing on Mobile/Desktop

For full functionality testing (camera, share sheet, haptics), run on a physical device:

### iOS
```bash
flutter run -d <device-id>
```

### Android
```bash
flutter run -d <device-id>
```

### macOS
```bash
flutter run -d macos
```

## 🐛 Known Web Limitations

- **Camera**: QR scanning requires a physical camera (limited in web)
- **Haptics**: Not available in web browsers
- **Native Share**: May fall back to clipboard/download
- **Background services**: Limited in web environment

## 📊 Features Implemented

✅ **Custom Branded QR Codes**
- 6 preset color themes
- Real-time style preview
- Export capability

✅ **Enhanced Security**
- Token expiration (1h, 24h, 7d, 30d)
- Single-use invites
- Limited-use invites (max uses)
- Instant revocation
- Validation checks

✅ **QR Management**
- 3-tab interface (Active/Expired/Revoked)
- Invite creation dialog
- QR preview modal
- Status badges
- Cleanup expired invites

✅ **Sharing & Export**
- Native share integration
- Screenshot capture
- Image export
- Share history tracking

✅ **Offline Support**
- QR code caching
- Scan queue buffering
- Cache statistics
- Background sync (when online)

✅ **Analytics & Tracking**
- Generation/scan/share tracking
- Popular QRs analysis
- Share method distribution
- Activity trends by day
- JSON export capability

## 🔍 Debugging Tips

### Check Providers
Open DevTools console and verify providers are initialized:
```javascript
// Should see no errors related to:
// - qrGenerationServiceProvider
// - qrCacheServiceProvider
// - qrAnalyticsServiceProvider
```

### Verify Storage
Check if secure storage is working:
```javascript
// In DevTools Console
localStorage.getItem('flutter.cached_qr_codes')
localStorage.getItem('flutter.qr_analytics_events')
```

### Monitor Network
- Open Network tab in DevTools
- Watch for QR-related API calls
- Verify caching behavior

## 🎯 Next Steps

1. **Test on physical device** for full functionality
2. **Connect backend** to persist invites/analytics
3. **Test camera scanning** on mobile
4. **Verify haptic feedback** on mobile
5. **Test share sheet** on native platforms

## 📝 Reporting Issues

If you encounter any issues:
1. Note the URL/screen where it occurred
2. Check browser console for errors (F12)
3. Verify network connectivity
4. Check Flutter console output
5. Try hot reload (press 'r' in terminal)

---

**Happy Testing! 🎉**
