# Message Viewer Tracking & Timestamps

## 📋 Overview

Enhanced the chat message structure to include **timestamp display** and **viewer tracking**, providing users with detailed information about when messages were sent and who has viewed them.

## ✨ Features

### 1. **Message Timestamps** ⏰
- **Relative Time Display**: Shows friendly timestamps like "Just now", "5m ago", "2h ago", "Yesterday", or date
- **Full Timestamp**: Tap on the timestamp to see the complete date and time (e.g., "Dec 9, 2025 at 2:30 PM")
- **Always Visible**: Timestamp appears below every message in small text with a clock icon

### 2. **Viewer Tracking** 👁️
- **Automatic Tracking**: Messages are automatically marked as viewed when they appear on screen (500ms delay)
- **Viewer Count**: Shows the number of people who have viewed each message
- **Viewer Details**: Tap on the viewer count to see a detailed list of who viewed the message and when
- **Real-time Updates**: Viewer information updates in real-time via socket events

### 3. **Viewer List Dialog** 📊
- Shows all viewers with:
  - User avatar (first letter of name)
  - User name
  - Exact view timestamp
  - Check mark indicator
- Sorted by view time

## 🎨 UI Components

### Message Footer
Each message now displays at the bottom:
```
🕐 5m ago  👁️ 3
```
- **Left side**: Timestamp (tappable)
- **Right side**: Viewer count (tappable, only shown if > 0)

### Timestamp Dialog
When tapping on timestamp:
```
Message Timestamp
─────────────────
Sent:
Dec 9, 2025 at 2:30 PM
```

### Viewer List Dialog
When tapping on viewer count:
```
👁️ Viewed by 3
─────────────────
(A) Alex Chen
    Dec 9, 2025 at 2:32 PM  ✓

(S) Sarah Kim  
    Dec 9, 2025 at 2:35 PM  ✓

(M) Mike Johnson
    Dec 9, 2025 at 2:38 PM  ✓
```

## 🔧 Technical Implementation

### Model Changes

#### `ChatMessage` class
```dart
class ChatMessage {
  final DateTime timestamp;           // When message was sent
  final List<MessageViewer> viewedBy; // List of viewers
  // ... other fields
}
```

#### `MessageViewer` class
```dart
class MessageViewer {
  final String userId;
  final String userName;
  final DateTime viewedAt;  // When this user viewed the message
}
```

#### `TimestampFormatter` helper
```dart
class TimestampFormatter {
  static String formatRelative(DateTime timestamp);  // "5m ago"
  static String formatFull(DateTime timestamp);      // "Dec 9, 2025 at 2:30 PM"
  static String formatTime(DateTime timestamp);      // "2:30 PM"
}
```

### Backend Changes

#### Socket Event: `chat:message:viewed`
**Emit** (from client):
```javascript
socket.emit('chat:message:viewed', {
  channelId: 'channel-id',
  messageId: 'msg-123'
});
```

**Listen** (broadcast to channel):
```javascript
socket.on('chat:message:viewed', (data) => {
  messageId: 'msg-123',
  viewer: {
    userId: 'user-1',
    userName: 'Alex',
    viewedAt: '2025-12-09T14:30:00Z'
  }
});
```

#### Message Storage
Messages now include:
```javascript
{
  id: '...',
  author: '...',
  timestamp: '2025-12-09T14:30:00Z',
  text: '...',
  viewedBy: [
    {
      userId: 'user-1',
      userName: 'Alex',
      viewedAt: '2025-12-09T14:32:00Z'
    }
  ]
}
```

### Controller Methods

#### `markMessageAsViewed(channelId, messageId, viewerName)`
- Marks a message as viewed by the current user
- Updates local state
- Prevents duplicate viewer entries

#### `updateMessageViewer(channelId, messageId, viewer)`
- Updates viewer information from socket events
- Used when other users view messages

### Automatic View Detection
```dart
@override
void initState() {
  super.initState();
  // Mark message as viewed after 500ms
  if (!widget.message.isMe && !_hasBeenViewed) {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && !_hasBeenViewed) {
        _hasBeenViewed = true;
        ref.read(chatThreadsProvider.notifier).markMessageAsViewed(
          widget.channelId,
          widget.message.id,
          'You',
        );
      }
    });
  }
}
```

## 📱 User Experience

### Timestamp Behavior
1. **Relative time** updates automatically as time passes
2. Shows **"Just now"** for messages < 1 minute old
3. Shows **minutes/hours** for recent messages (e.g., "5m ago", "2h ago")
4. Shows **days** for messages < 1 week old (e.g., "3d ago")
5. Shows **date** for older messages (e.g., "Dec 1")

### Viewer Tracking Behavior
1. Message appears on screen → **500ms delay** → automatically marked as viewed
2. Viewer count **badge appears** next to timestamp
3. **Own messages** don't show viewer tracking for yourself
4. **Real-time updates**: viewer count increases as others view the message

### Privacy Considerations
- Only shows that a message was viewed, not when it was delivered
- Viewers can see who else has viewed the message
- No "read receipts" pressure - information is subtle and non-intrusive

## 🎯 Use Cases

### Team Communication
- **Project managers** can see if team members have read important announcements
- **Developers** can confirm others have seen their questions or updates

### Collaboration
- Verify that file attachments or references have been viewed
- Track engagement with voice messages or shared documents

### Accountability
- Confirm critical messages have been acknowledged
- Reduce "I didn't see it" situations

## 🚀 Future Enhancements

### Potential Features
1. **Delivery Status**: Add "delivered" indicator before "viewed"
2. **Typing Indicators**: Show when users are typing (already supported in backend)
3. **Last Seen**: Show when users were last active in a channel
4. **Read Receipts Toggle**: Allow users to disable viewer tracking for privacy
5. **Notification on View**: Notify sender when important messages are viewed
6. **Analytics**: Track average time to view messages, engagement rates

### Performance Optimizations
1. **Batch View Updates**: Send multiple view events together
2. **Lazy Loading**: Only load viewer details when dialog is opened
3. **Caching**: Cache viewer information to reduce server calls

## 📊 Statistics

### Code Changes
- **Files Modified**: 2
  - `lib/features/chat/models/chat_message.dart` (+80 lines)
  - `lib/features/chat/presentation/enhanced_chat_screen.dart` (+120 lines)
  - `backend/socket/handlers.js` (+45 lines)
- **New Classes**: 2
  - `MessageViewer` (data class)
  - `TimestampFormatter` (utility class)
- **New Methods**: 4
  - `markMessageAsViewed()`
  - `updateMessageViewer()`
  - `_showFullTimestamp()`
  - `_showViewerList()`

### UI Improvements
- ✅ Timestamp always visible on messages
- ✅ Viewer count badge
- ✅ Interactive timestamp (tap for full date)
- ✅ Interactive viewer count (tap for list)
- ✅ Viewer details with avatars
- ✅ Relative time formatting
- ✅ Automatic view tracking

## 🔗 Related Documentation
- [Enhanced Chat System](./enhanced_chat_system.md)
- [Chat Implementation Summary](./chat_implementation_summary.md)
- [Backend README](../backend/README.md)
