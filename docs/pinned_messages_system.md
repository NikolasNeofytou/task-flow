# Pinned Messages System

## Overview

The pinned messages feature allows users to pin important messages in chat channels for easy reference. Pinned messages appear in a dedicated horizontal scrollable section at the top of the chat, making it simple to access critical information without scrolling through the entire conversation history.

## Features

### 1. Pin/Unpin Messages
- **Long Press**: Long press on any message bubble to open the action menu
- **Pin Action**: Select "Pin Message" to pin the message
- **Unpin Action**: Select "Unpin Message" to remove the pin
- **Visual Indicator**: Pinned messages have a blue border and a "Pinned" badge

### 2. Pinned Messages Section
- **Location**: Appears at the top of the chat thread when there are pinned messages
- **Layout**: Horizontal scrollable cards showing pinned message previews
- **Header**: Shows count of pinned messages (e.g., "Pinned Messages (3)")
- **Quick Access**: Tap on a pinned message card to view the full message

### 3. Pinned Message Cards
Each pinned message card displays:
- **Author Information**: Avatar, name, and role badge
- **Timestamp**: Relative time when the message was sent
- **Message Preview**: First 3 lines of the message content
- **Content Type Indicators**: 
  - 🎤 Voice message with duration
  - 📎 File attachment with filename
- **Unpin Button**: Quick unpin action via close (×) button

## UI Components

### Pinned Messages Section
```
┌─────────────────────────────────────────┐
│ 📌 Pinned Messages (2)                  │
├─────────────────────────────────────────┤
│ ┌──────┐  ┌──────┐                     │
│ │ Card │  │ Card │ ───>                │
│ └──────┘  └──────┘                     │
└─────────────────────────────────────────┘
```

### Pinned Message Card
```
┌─────────────────────────────┐
│ [Avatar] Sarah [PM]      [×]│
│          2 hours ago        │
│                             │
│ This is the message         │
│ preview text that shows     │
│ up to 3 lines...            │
└─────────────────────────────┘
```

### Message with Pin Indicator
```
┌─────────────────────────────┐
│ ┌─ Pinned ──────────────┐   │
│ │                        │   │
│ │  Message content here  │   │
│ │                        │   │
│ │  [timestamp] [viewers] │   │
│ └────────────────────────┘   │
└─────────────────────────────┘
```

## Technical Implementation

### Data Model

**ChatMessage** (lib/features/chat/models/chat_message.dart):
```dart
class ChatMessage {
  final bool isPinned;           // Whether message is pinned
  final String? pinnedBy;        // User who pinned the message
  final DateTime? pinnedAt;      // When message was pinned
  // ... other fields
}
```

### State Management

**EnhancedChatController** methods:
- `pinMessage(channelId, messageId, pinnedBy)` - Pin a message
- `unpinMessage(channelId, messageId)` - Unpin a message
- `getPinnedMessages(channelId)` - Get all pinned messages for a channel

### UI Components

1. **_PinnedMessagesSection**: Horizontal scrollable section at top of chat
2. **_PinnedMessageCard**: Individual pinned message preview card
3. **_showMessageActions()**: Bottom sheet with pin/unpin action

### Backend Integration

**Socket Events** (backend/socket/handlers.js):
- `chat:message:pin` - Pin a message
- `chat:message:unpin` - Unpin a message
- `chat:message:pinned` - Broadcast pin update
- `chat:message:unpinned` - Broadcast unpin update

## User Interactions

### Pinning a Message
1. Long press on a message bubble
2. Bottom sheet appears with "Pin Message" option
3. Tap "Pin Message"
4. Message is pinned and appears in the pinned section
5. Message bubble shows "Pinned" badge with blue border

### Unpinning a Message

**From Message Actions**:
1. Long press on a pinned message
2. Bottom sheet appears with "Unpin Message" option
3. Tap "Unpin Message"
4. Message is unpinned and removed from pinned section

**From Pinned Section**:
1. Navigate to pinned messages section at top
2. Tap the close (×) button on a pinned card
3. Message is immediately unpinned

### Viewing Pinned Messages
1. Open any chat channel
2. If pinned messages exist, they appear at the top
3. Scroll horizontally to view all pinned messages
4. Tap a pinned card to jump to that message in the conversation

## Use Cases

### 1. Important Announcements
Pin project announcements or critical updates so team members can easily reference them.

### 2. Meeting Notes
Pin messages containing meeting notes, action items, or decisions for quick access.

### 3. File Sharing
Pin messages with important files or documents for easy retrieval.

### 4. Task References
Pin messages containing task descriptions, requirements, or specifications.

### 5. Quick Links
Pin messages with project file references or external links.

## Visual Design

### Colors
- **Pin Indicator**: Primary color badge
- **Border**: Primary color (2px solid)
- **Background**: Primary container with opacity
- **Icon**: Primary color push pin icon

### Spacing
- **Card Width**: 250px
- **Card Margin**: 12px right
- **Section Height**: 120px
- **Padding**: Standard spacing tokens (sm, md, lg)

### Typography
- **Section Title**: labelMedium, semibold
- **Author Name**: labelSmall, semibold
- **Timestamp**: labelSmall (9px)
- **Preview Text**: bodySmall

## Analytics Events

- `chat_pin_message` - When a message is pinned
  - Parameter: `channel` - The channel ID
- `chat_unpin_message` - When a message is unpinned
  - Parameter: `channel` - The channel ID

## Future Enhancements

### Potential Features
1. **Pin Limit**: Enforce maximum number of pinned messages per channel
2. **Pin Permissions**: Role-based permissions for who can pin/unpin
3. **Pin Notifications**: Notify channel members when important messages are pinned
4. **Jump to Message**: Tap pinned card to scroll to the message in chat
5. **Pin Ordering**: Allow reordering pinned messages by drag and drop
6. **Pin Categories**: Group pinned messages by type (announcement, task, file, etc.)
7. **Pin Search**: Search within pinned messages only
8. **Pin History**: View history of pinned/unpinned messages

## Testing Checklist

- [ ] Pin a text message
- [ ] Pin a voice message
- [ ] Pin a file attachment message
- [ ] Pin multiple messages
- [ ] Unpin from message actions
- [ ] Unpin from pinned section
- [ ] Scroll through pinned messages
- [ ] View pinned message details
- [ ] Pin visual indicators display correctly
- [ ] Pinned section appears/disappears correctly
- [ ] Role badges display on pinned cards
- [ ] Timestamps format correctly
- [ ] Backend sync (if connected)
