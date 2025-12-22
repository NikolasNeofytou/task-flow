# Understanding Your TaskFlow QR Codes

## What You Should See

When you navigate to the **Demo QR Screen** (`http://localhost:51761/#/profile/qr/demo`), you'll see:

### 1. **Top Section - Instructions Card** 📋
A blue info card that explains:
- How to choose a style
- How to share or export
- How others can scan your code

### 2. **Main QR Code Card** 🎯
A large card displaying:
- **Your Profile Avatar** - Initials in a circle at the top
- **Your Name** - "John Doe" (demo data)
- **Your Email** - "john.doe@taskflow.com"
- **The QR Code** - A scannable QR code in the center (250x250 pixels)
- **"Scan to connect" label** - Below the QR code

This entire card changes colors based on your selected style!

### 3. **Style Selector** 🎨
A horizontal scrollable list with 6 color themes:

| Style | Background | Foreground | Use Case |
|-------|-----------|-----------|----------|
| **Classic** | White | Black | Professional, high contrast |
| **Branded** | Deep Purple | White | TaskFlow brand colors |
| **Dark** | Dark Gray | White | Dark mode friendly |
| **Ocean** | Blue | White | Cool, calming theme |
| **Forest** | Green | White | Nature-inspired |
| **Sunset** | Orange | White | Warm, energetic |

**How to use:**
- Tap any style box to change the QR code appearance
- Selected style has a blue border and shadow
- QR code updates instantly
- You'll see a snackbar confirming the change

### 4. **Action Buttons** 🔘

Three main buttons at the bottom:

#### **Share QR Code** (Blue Button)
- Takes a screenshot of your QR card
- Opens native share sheet
- You can share via:
  - Email
  - Messages
  - Social media
  - Any installed app

#### **Export as Image** (Outlined Button)
- Saves QR code as PNG file
- Location shown in snackbar
- File includes: avatar, name, email, QR code, style

#### **Copy QR Data** (Text Button)
- Copies the encoded data to clipboard
- Data format: `taskflow://user/12345/john.doe@taskflow.com/John Doe`
- Useful for debugging or manual sharing

## How It Works

### QR Code Generation
The QR code encodes a **deep link** that contains:
```
taskflow://user/<USER_ID>/<EMAIL>/<NAME>
```

When someone scans this QR code with their camera:
1. Their device opens the TaskFlow app
2. The app parses the user information
3. It adds you to their team/contacts automatically

### Customization System
Each style applies:
- **Background color** to the card
- **Foreground color** to QR code dots, text, and icons
- **Consistent theming** across all elements

### Screenshot Technology
- Uses `screenshot` package to capture the QR card
- Captures exactly what you see on screen
- Maintains quality and colors
- Works offline

### Sharing Integration
- Uses `share_plus` package for native sharing
- Creates temporary PNG file
- Shares through iOS Share Sheet or Android Share Menu
- File is cleaned up automatically

## Interactive Features

### Visual Feedback
✅ **When you tap a style:**
- Border changes to blue
- Shadow appears
- Check icon replaces QR icon
- Snackbar shows confirmation
- Haptic feedback (on mobile)

✅ **When you share:**
- Button shows loading spinner
- Button text changes to "Preparing..."
- Button is disabled during process
- Success snackbar appears

### Real-Time Updates
- QR code regenerates when style changes
- All colors update instantly
- No loading delay
- Smooth animations

## Testing Checklist

Use this checklist when testing:

- [ ] **Load the screen** - See QR code immediately
- [ ] **Tap each style** - All 6 styles work
- [ ] **Selected style updates** - Border, shadow, check icon
- [ ] **QR code changes color** - Matches selected style
- [ ] **Profile info visible** - Name, email, avatar clear
- [ ] **Tap Share button** - See share sheet (or download)
- [ ] **Tap Export button** - See success message with file path
- [ ] **Tap Copy button** - See "copied" message
- [ ] **Tap info icon** - See about dialog
- [ ] **Scroll styles** - Horizontal scroll works smoothly

## Common Issues & Solutions

### Issue: "Just see a generated box and nothing else"

**This means:**
- The QR code is showing but lacks visual context
- No clear instructions on what to do
- Missing interactive elements

**Solution:**
Use the **Demo QR Screen** instead:
1. Go to: `http://localhost:51761/#/testing/qr`
2. Click "⭐ Demo QR Screen (Start Here!)"
3. You'll now see:
   - Clear instructions at the top
   - Labeled style picker
   - Descriptive buttons
   - Visual feedback

### Issue: Profile data not loading

**Symptoms:**
- See loading spinner forever
- Blank screen
- "Profile not found" error

**Solution:**
The Demo QR Screen uses hardcoded data and doesn't require profile setup.

### Issue: Share doesn't work in web

**Expected:**
Web browsers have limited sharing capabilities. You'll see:
- Download dialog instead of share sheet
- File saved to Downloads folder
- No native app picker

**This is normal:** Full sharing works on mobile/desktop apps.

### Issue: Can't scan the QR code

**On Web:**
- Right-click QR code → "Open image in new tab"
- Use a QR scanner app on your phone
- Point phone camera at your computer screen

**On Mobile:**
- Export the QR code
- Show it to another device
- Use another app to scan

## What Each Screen Does

### 1. Demo QR Screen (`/profile/qr/demo`)
- ✅ **Works immediately** - No setup needed
- ✅ **Full features** - All 6 styles, share, export
- ✅ **Clear UI** - Instructions and labels
- ✅ **Great for testing** - See all capabilities
- 📱 **Use this first!**

### 2. Enhanced Personal QR (`/profile/qr/enhanced`)
- Requires user profile data
- Uses your actual name/email
- Integrates with analytics
- Production-ready version

### 3. QR Management (`/projects/1/qr/manage`)
- For **project invites** (not personal QR)
- Create invites with expiration
- Revoke invites
- Track active/expired invites

### 4. QR Analytics (`/profile/qr/analytics`)
- View usage statistics
- Track scans and shares
- See popular QR codes
- Export analytics data

## Next Steps

1. **Start with Demo QR Screen** - See it working
2. **Test all 6 styles** - Pick your favorite
3. **Try sharing** - Export as image
4. **Test on mobile** - For camera and haptics
5. **Check analytics** - See your usage stats

---

**Need Help?**
- Check the info button (ℹ️) in the app
- All features are clearly labeled
- Tap to interact with everything
- Look for visual feedback

