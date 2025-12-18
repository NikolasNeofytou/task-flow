# Task Assignment & Request System

## Overview

The Task Assignment & Request System enables collaborative task management by allowing users to assign tasks to team members either directly or through a request-based workflow. When sending a task as a request, the assignee receives a notification with the ability to accept or reject the assignment.

## Features

### 1. Task Assignment Options

#### Direct Assignment
- Immediately assigns the task to the selected team member
- No approval required
- Task appears in assignee's task list instantly

#### Request-Based Assignment
- Sends an assignment request to the team member
- Assignee receives a notification with Accept/Reject options
- Task is only assigned if accepted
- Provides flexibility for team members to manage their workload

### 2. Enhanced Task Creation Form

#### Team Member Selection
- **Assignee Dropdown**: Browse and select from available team members
- **User Cards**: Display user avatar, name, and email
- **None Option**: Assign task to yourself (no assignee)

#### Assignment Mode Toggle
- **Visual Switch**: Toggle between Direct Assignment and Send as Request
- **Mode Indicator**: Color-coded info box shows current mode
- **Clear Descriptions**: 
  - Direct: "Task will be directly assigned to [User Name]"
  - Request: "[User Name] will receive a request notification and can accept or reject"

### 3. Notification System

#### Task Assignment Notifications
- **Visual Design**: 
  - Assignment icon (person with badge)
  - Info color scheme (blue)
  - Clear notification title showing who sent the request
  
- **Actionable Notifications**:
  - Accept button (green, with checkmark)
  - Reject button (red outline, with X icon)
  - Buttons appear directly in the notification list
  
- **Feedback**:
  - Immediate snackbar confirmation
  - Notification removed/updated after action
  - Task status updated accordingly

### 4. Data Models

#### Enhanced TaskItem
```dart
class TaskItem {
  final String? assignedTo;     // User ID of assignee
  final String? assignedBy;     // User ID of assigner
  final String? requestId;      // Link to assignment request if pending
}
```

#### Enhanced Request
```dart
enum RequestType { taskAssignment, taskTransfer, general }

class Request {
  final RequestType type;
  final String? fromUserId;     // Who sent the request
  final String? toUserId;       // Who receives the request
  final String? taskId;         // Related task
  final String? projectId;      // Related project
}
```

#### Enhanced AppNotification
```dart
class AppNotification {
  final NotificationType type;  // Added: taskAssignment
  final String? requestId;      // Link to request
  final String? taskId;         // Related task
  final String? fromUserId;     // Who sent the request
  final bool actionable;        // Can user take action?
}
```

#### User Model
```dart
class User {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
}
```

## User Workflow

### Assigning a Task

1. **Create New Task**
   - Navigate to project
   - Tap the "+" FAB or "Add Task" button
   - Fill in task title and due date

2. **Select Assignee**
   - Open the assignee dropdown
   - Browse team members
   - Select a user or choose "None" (self-assign)

3. **Choose Assignment Mode**
   - Toggle "Send as Request" switch
   - Review the mode description
   - Decide between direct or request-based assignment

4. **Submit**
   - Tap "Create Task"
   - Receive confirmation message
   - Task created with assignment details

### Responding to Assignment Request

1. **Receive Notification**
   - Notification appears in Notifications tab
   - Badge count updates
   - Assignment icon and user name displayed

2. **Review Request**
   - Read task details in notification
   - See who sent the request
   - View task title and context

3. **Take Action**
   - **Accept**: Tap green "Accept" button
     - Task added to your task list
     - Sender receives acceptance notification
     - Request marked as accepted
   
   - **Reject**: Tap red "Reject" button
     - Task not assigned to you
     - Sender receives rejection notification
     - Request marked as rejected

4. **Confirmation**
   - Snackbar shows action result
   - Notification updates/disappears
   - Task status reflects decision

## Technical Implementation

### Components Modified

1. **lib/core/models/**
   - `task_item.dart` - Added assignee fields
   - `request.dart` - Added RequestType and task assignment fields
   - `app_notification.dart` - Added taskAssignment type and action fields
   - `user.dart` - New file for team member model

2. **lib/core/data/mock_data.dart**
   - Added mock users (Alice, Bob, Carol, David)
   - Added `fetchUsers()` method

3. **lib/core/providers/data_providers.dart**
   - Added `usersProvider` for fetching team members

4. **lib/features/projects/presentation/task_form_screen.dart**
   - Converted to ConsumerStatefulWidget
   - Added assignee selection dropdown
   - Added request/direct assignment toggle
   - Enhanced save logic with assignment handling
   - Added visual feedback for assignment mode

5. **lib/features/notifications/presentation/notifications_screen.dart**
   - Updated `_NotificationTile` to show action buttons
   - Added conditional rendering for actionable notifications
   - Implemented Accept/Reject button handlers
   - Updated icon and color helpers for taskAssignment type

6. **lib/features/notifications/presentation/notification_detail_screen.dart**
   - Added taskAssignment cases to switch statements

7. **lib/features/inbox/presentation/inbox_screen.dart**
   - Added taskAssignment cases to switch statements

### Key Design Decisions

1. **Actionable Notifications in List**
   - Actions directly in notification list for quick response
   - No need to navigate to detail screen
   - Reduces friction in acceptance workflow

2. **Visual Mode Toggle**
   - Clear distinction between direct and request modes
   - Info box with gradient background for visibility
   - Dynamic text explains current mode

3. **User-Friendly Selection**
   - Avatar indicators for visual identification
   - Full name and email for clarity
   - "None" option for self-assignment

4. **Flexible Request Model**
   - RequestType enum supports future extensions
   - Links between requests, tasks, and users
   - Supports different request workflows

## Testing Checklist

- [ ] Task creation with no assignee (self-assign)
- [ ] Task creation with direct assignment
- [ ] Task creation with request-based assignment
- [ ] Toggle between assignment modes
- [ ] Accept task assignment request
- [ ] Reject task assignment request
- [ ] Notification displays correctly
- [ ] Action buttons work in notification list
- [ ] Snackbar feedback after actions
- [ ] User dropdown shows all team members
- [ ] User cards display name and email
- [ ] Mode indicator updates correctly
- [ ] Success messages show assignee name

## Future Enhancements

### Phase 1 - Core Improvements
- **Task Reassignment**: Transfer tasks between team members
- **Bulk Assignment**: Assign multiple tasks at once
- **Assignment History**: Track all assignment changes
- **Request Expiration**: Auto-reject after timeout

### Phase 2 - Advanced Features
- **Assignment Comments**: Add messages to requests
- **Priority Indication**: Mark urgent assignment requests
- **Delegation Rules**: Auto-assign based on rules
- **Workload Balancing**: Show team member capacity

### Phase 3 - Analytics & Insights
- **Assignment Metrics**: Track acceptance/rejection rates
- **Response Times**: Monitor how quickly requests are handled
- **Team Collaboration**: Visualize assignment patterns
- **Notification Preferences**: Customize notification settings

## Accessibility

- All interactive elements have semantic labels
- Action buttons have clear accessible names
- Dropdown has proper keyboard navigation
- Color is not the only indicator (icons + text)
- Sufficient contrast ratios maintained
- Screen reader friendly descriptions

## Related Documentation

- [Calendar Enhancements](./calendar_enhancements.md) - Project deadline display
- [Task Comments System](./progress.md) - Commenting on tasks
- [Notification System](./progress.md) - General notification handling
