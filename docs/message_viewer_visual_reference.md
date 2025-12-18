# Message Viewer Tracking - Visual Reference

## 📸 UI Examples

### Basic Message with Timestamp
```
┌─────────────────────────────────────┐
│ Alex Chen                           │
│ ┌─────────────────────────────────┐ │
│ │ Hey team, check out the new     │ │
│ │ feature I just pushed!          │ │
│ │                                 │ │
│ │ 🕐 5m ago                        │ │
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

### Message with Viewers
```
┌─────────────────────────────────────┐
│ Sarah Kim                           │
│ ┌─────────────────────────────────┐ │
│ │ The design looks great! I'll    │ │
│ │ start implementation today.     │ │
│ │                                 │ │
│ │ 🕐 2h ago  👁️ 4                 │ │
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

### Your Own Message (No Viewer Badge)
```
                   ┌─────────────────────┐
                   │ Thanks! Looking     │
                   │ forward to it.      │
                   │                     │
                   │ 🕐 Just now         │
                   └─────────────────────┘
                   You
```

## 📋 Dialog Views

### Full Timestamp Dialog
```
┌────────────────────────────────────┐
│ Message Timestamp                  │
├────────────────────────────────────┤
│                                    │
│ Sent:                              │
│ Dec 9, 2025 at 2:30 PM            │
│                                    │
├────────────────────────────────────┤
│                      [Close]       │
└────────────────────────────────────┘
```

### Viewer List Dialog
```
┌────────────────────────────────────┐
│ 👁️ Viewed by 4                     │
├────────────────────────────────────┤
│                                    │
│  (A)  Alex Chen               ✓   │
│       Dec 9, 2025 at 2:32 PM      │
│  ─────────────────────────────     │
│  (S)  Sarah Kim               ✓   │
│       Dec 9, 2025 at 2:35 PM      │
│  ─────────────────────────────     │
│  (M)  Mike Johnson            ✓   │
│       Dec 9, 2025 at 2:38 PM      │
│  ─────────────────────────────     │
│  (J)  Jane Doe                ✓   │
│       Dec 9, 2025 at 2:40 PM      │
│                                    │
├────────────────────────────────────┤
│                      [Close]       │
└────────────────────────────────────┘
```

## 🎨 Message Footer Layout

### Without Viewers
```
┌──────────────────────┐
│ [Message content]    │
│                      │
│ 🕐 15m ago           │ ← Timestamp only
└──────────────────────┘
```

### With Viewers
```
┌──────────────────────┐
│ [Message content]    │
│                      │
│ 🕐 1h ago  👁️ 7      │ ← Timestamp + Viewer count
└──────────────────────┘
```

## ⏰ Timestamp Format Examples

| Time Elapsed | Display Format |
|--------------|----------------|
| < 1 minute   | Just now       |
| 1-59 minutes | Xm ago         |
| 1-23 hours   | Xh ago         |
| 1 day        | Yesterday      |
| 2-6 days     | Xd ago         |
| 7+ days      | Dec 9          |

### Full Timestamp Format
- Format: `[Month] [Day], [Year] at [Hour]:[Minute] [AM/PM]`
- Example: `Dec 9, 2025 at 2:30 PM`

## 🎯 Interaction Flow

### Viewing a Message
```
1. Message appears on screen
   ↓
2. 500ms delay (reading time)
   ↓
3. Automatically marked as viewed
   ↓
4. Socket event sent to backend
   ↓
5. Backend broadcasts to channel
   ↓
6. All clients update viewer count
```

### Checking Who Viewed
```
1. User sees viewer count: 👁️ 4
   ↓
2. Taps on viewer count
   ↓
3. Dialog opens with list
   ↓
4. Shows all viewers with timestamps
   ↓
5. User taps "Close"
```

### Checking Full Timestamp
```
1. User sees relative time: 🕐 2h ago
   ↓
2. Taps on timestamp
   ↓
3. Dialog opens
   ↓
4. Shows full date and time
   ↓
5. User taps "Close"
```

## 🎨 Color Scheme

### For Own Messages (Blue Background)
- **Timestamp text**: White at 70% opacity
- **Icon color**: White at 70% opacity
- **Viewer count**: White at 70% opacity

### For Other Messages (Gray Background)
- **Timestamp text**: OnSurfaceVariant color
- **Icon color**: OnSurfaceVariant color
- **Viewer count**: OnSurfaceVariant color

## 📐 Spacing & Sizing

### Message Footer
- **Padding**: 
  - Left/Right: AppSpacing.md (16px)
  - Top: AppSpacing.xs (4px)
  - Bottom: AppSpacing.sm (8px)
- **Icon size**: 12px
- **Font size**: 10px (labelSmall)
- **Gap between icon and text**: 4px
- **Gap between timestamp and viewers**: AppSpacing.xs (4px)

### Dialog Elements
- **Title icon size**: 20px
- **Avatar size**: 40px (default CircleAvatar)
- **Check icon size**: 16px
- **List item separator**: Divider widget

## 🔍 Visual Hierarchy

### Priority Order (Top to Bottom)
1. **Author name** - Medium weight, larger text
2. **Message content** - Normal weight, body text
3. **Timestamp + Viewers** - Small weight, subtle color

### Interactive Elements
- Both timestamp and viewer count are **tappable**
- Visual feedback: `InkWell` with border radius
- Hover/tap shows ripple effect

## 📱 Responsive Behavior

### Small Screens
- Message footer remains visible
- Dialogs scale to fit screen
- Viewer list scrolls if needed

### Large Screens
- Same layout, better spacing
- Dialogs don't stretch too wide (`maxFinite`)
- Better touch targets

## ♿ Accessibility

### Screen Reader Support
- **Timestamp**: "Sent 5 minutes ago, tap for full timestamp"
- **Viewer count**: "Viewed by 4 people, tap for details"
- **Viewer list**: "Alex Chen viewed at December 9, 2025 at 2:32 PM"

### Touch Targets
- Minimum 44x44 dp touch area
- Padding around interactive elements
- Clear visual feedback

## 🎭 Animation & Transitions

### Viewer Count Update
```
👁️ 3 → 👁️ 4
   ↓
Subtle fade-in for new count
No jarring changes
```

### Dialog Appearance
```
Standard Material dialog transition:
- Fade in background
- Scale up dialog
- Smooth animation (300ms)
```

## 💡 Best Practices

### When to Check Viewers
✅ **Good use cases:**
- Important announcements
- Action items
- Critical information
- File shares

❌ **Avoid checking for:**
- Casual chat
- Every single message
- Small talk

### Privacy Consideration
- Viewer tracking is **opt-in** by nature (automatic but transparent)
- Users can see who viewed **any** message
- No hidden tracking or surveillance feel
- Clear, honest communication of feature

## 🔄 Real-time Updates

### Scenario: Multiple Users Viewing
```
Time: 2:30 PM - Message sent
      👁️ 0

Time: 2:32 PM - Alex views
      👁️ 1

Time: 2:35 PM - Sarah views
      👁️ 2

Time: 2:38 PM - Mike views
      👁️ 3

All updates happen instantly via socket events!
```

## 🎬 Complete Example

```
┌─────────────────────────────────────────────────┐
│ ChatThread: Project Alpha                       │
├─────────────────────────────────────────────────┤
│                                                 │
│ Alex Chen                                       │
│ ┌─────────────────────────────────────────────┐ │
│ │ Can someone review the PR?                  │ │
│ │                                             │ │
│ │ 🕐 10m ago  👁️ 5                            │ │
│ └─────────────────────────────────────────────┘ │
│                                                 │
│                        Sarah Kim                │
│                 ┌─────────────────────────────┐ │
│                 │ I'll check it now!          │ │
│                 │                             │ │
│                 │ 🕐 8m ago  👁️ 3             │ │
│                 └─────────────────────────────┘ │
│                                                 │
│                                          You    │
│                 ┌─────────────────────────────┐ │
│                 │ Thanks Sarah!               │ │
│                 │                             │ │
│                 │ 🕐 Just now                 │ │
│                 └─────────────────────────────┘ │
│                                                 │
├─────────────────────────────────────────────────┤
│ [📎] [🎤] [Type here...        ] [Send]        │
└─────────────────────────────────────────────────┘
```
