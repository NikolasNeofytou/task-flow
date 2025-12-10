# Task Comments System Documentation

## Overview

The Task Comments System enables collaborative communication on individual tasks, fulfilling the **Axis 1 - Collaborative Computing** requirement by providing a way for team members to discuss tasks with threaded comments.

**Status:** ✅ Fully Implemented  
**Date Added:** December 4, 2025  
**Features:** View comments, add comments, real-time updates, timestamp formatting

---

## Architecture

### Data Flow

```
UI (TaskDetailScreen)
    ↓
CommentsController (Riverpod)
    ↓
CommentsRepository (Interface)
    ↓
├── MockCommentsRepository (Local Development)
└── CommentsRemoteRepository (Production/Backend)
    ↓
Backend API (/tasks/:taskId/comments)
```

---

## Core Components

### 1. Domain Model

**File:** `lib/core/models/comment.dart`

```dart
class Comment {
  final String id;
  final String taskId;
  final String authorName;
  final String content;
  final DateTime createdAt;
}
```

**Fields:**
- `id` - Unique comment identifier
- `taskId` - Associated task ID
- `authorName` - Display name of comment author
- `content` - Comment text content
- `createdAt` - UTC timestamp of comment creation

---

### 2. Data Transfer Object

**File:** `lib/core/dto/comment_dto.dart`

Handles JSON serialization/deserialization between backend and domain models.

**Methods:**
- `fromJson(Map<String, dynamic>)` - Parse JSON response
- `toJson()` - Convert to JSON for requests
- `toDomain()` - Convert to domain model

---

### 3. Repository Layer

**Interface:** `lib/core/repositories/comments_repository.dart`

```dart
abstract class CommentsRepository {
  Future<List<Comment>> fetchComments(String taskId);
  Future<Comment> addComment({
    required String taskId,
    required String content,
  });
}
```

**Implementations:**

#### Mock Repository
**File:** `lib/core/repositories/mock/mock_comments_repository.dart`

- Uses `MockDataSource` for in-memory data
- Simulates network delay (300-400ms)
- Auto-generates comment IDs
- Perfect for development without backend

#### Remote Repository
**File:** `lib/core/repositories/remote/comments_remote_repository.dart`

- Uses Dio HTTP client
- Endpoints:
  - `GET /tasks/:taskId/comments` - Fetch all comments for a task
  - `POST /tasks/:taskId/comments` - Add new comment
- Error handling via `mapDioError()`

---

### 4. State Management

**File:** `lib/features/projects/application/comments_controller.dart`

**Providers:**

```dart
// Fetch comments for a task
final taskCommentsProvider = FutureProvider.family<List<Comment>, String>

// Manage comments state with mutations
final commentsControllerProvider = 
    AsyncNotifierProvider.family<CommentsController, List<Comment>, String>
```

**CommentsController Methods:**

- `build(String taskId)` - Initial data load
- `addComment(String content)` - Add new comment with optimistic updates

**Features:**
- Optimistic UI updates (comment appears immediately)
- Automatic error recovery (reverts on failure)
- Input validation (trims whitespace, rejects empty)

---

### 5. User Interface

**File:** `lib/features/projects/presentation/task_detail_screen.dart`

**Components:**

#### TaskDetailScreen (Main Widget)
- Changed from `StatelessWidget` to `ConsumerStatefulWidget`
- Manages comment input controller
- Handles submission state

#### _CommentCard Widget
- Displays author avatar with initial
- Shows author name and timestamp
- Formats relative time (e.g., "2h ago", "3d ago")
- Material Design card styling

**Layout Structure:**
```
├── Task Header (title, status, due date)
├── Divider
├── Comments Header ("Comments" with icon)
├── Comments List (scrollable)
│   └── Comment Cards
└── Comment Input Bar (fixed bottom)
    ├── TextField (multi-line)
    └── Send IconButton
```

**UX Features:**
- Keyboard-aware input (adjusts for on-screen keyboard)
- Submit on keyboard "send" action
- Loading indicator during submission
- Disabled input while submitting
- Auto-focus removal after send
- Empty state message for new tasks

---

## Backend Integration

### Mock Server

**File:** `backend_mock/server.js`

**Data Structure:**
```javascript
let taskComments = {
  'task-1': [ /* comments array */ ],
  'task-2': [ /* comments array */ ],
  // ...
};
```

**Endpoints:**

#### GET /tasks/:taskId/comments
```javascript
// Response: Comment[]
[
  {
    id: "comment-1",
    taskId: "task-1",
    authorName: "Sarah Chen",
    content: "Design files are ready...",
    createdAt: "2025-08-15T10:30:00Z"
  }
]
```

#### POST /tasks/:taskId/comments
```javascript
// Request Body:
{ content: "Great work on this task!" }

// Response: Comment
{
  id: "comment-5",
  taskId: "task-1",
  authorName: "You",
  content: "Great work on this task!",
  createdAt: "2025-12-04T15:30:00Z"
}
```

**Validation:**
- Returns 400 if `content` is missing or empty
- Auto-increments comment ID counter
- Creates task comment array if doesn't exist

---

### Mock Data

**File:** `lib/core/data/mock_data.dart`

**Seed Comments:**
- `task-a` ("task-1"): 2 comments from Sarah Chen, Mike Johnson
- `task-b` ("task-2"): 1 comment from Lisa Park
- `task-c` ("task-3"): 1 comment from John Smith

**Methods:**
- `fetchComments(String taskId)` - Returns comments for task
- `addComment({taskId, content})` - Adds new comment with generated ID

---

## Configuration

### Provider Registration

**File:** `lib/core/providers/data_providers.dart`

```dart
final commentsRepositoryProvider = Provider<CommentsRepository>((ref) {
  final config = ref.watch(appConfigProvider);
  if (config.useMocks) return MockCommentsRepository();
  final dio = ref.watch(dioProvider);
  return CommentsRemoteRepository(dio);
});
```

**Environment Variables:**
- `USE_MOCKS=true` - Use mock repository (no backend needed)
- `USE_MOCKS=false` - Use remote repository (requires backend)

---

## Usage Examples

### Viewing Comments

1. Navigate to Projects screen
2. Tap on any project (e.g., "Project A")
3. Tap on any task (e.g., "Design handoff")
4. Scroll to see existing comments

### Adding a Comment

1. Open any task detail screen
2. Tap the comment input field at bottom
3. Type your comment
4. Press Send button or keyboard "Send" key
5. Comment appears immediately with "You" as author

### Testing with Mock Data

```bash
# Run with mocks (no backend needed)
flutter run --dart-define=USE_MOCKS=true

# Run with backend
cd backend_mock
npm install
npm run dev

# In another terminal
flutter run --dart-define=API_BASE_URL=http://localhost:4000 --dart-define=USE_MOCKS=false
```

---

## API Reference

### CommentsRepository Interface

```dart
// Fetch all comments for a task
Future<List<Comment>> fetchComments(String taskId);

// Add a new comment to a task
Future<Comment> addComment({
  required String taskId,
  required String content,
});
```

### CommentsController Methods

```dart
// Add comment to current task (from controller)
await ref
  .read(commentsControllerProvider(taskId).notifier)
  .addComment("This is a great task!");
```

### Watching Comments in UI

```dart
// Using ConsumerWidget
@override
Widget build(BuildContext context, WidgetRef ref) {
  final commentsAsync = ref.watch(commentsControllerProvider(taskId));
  
  return commentsAsync.when(
    data: (comments) => ListView(...),
    loading: () => CircularProgressIndicator(),
    error: (err, _) => Text('Error: $err'),
  );
}
```

---

## Error Handling

### Network Errors
- Dio errors mapped to user-friendly messages
- State reverts to previous value on failure
- UI shows error state with retry option

### Validation Errors
- Empty comments rejected before API call
- Whitespace-only comments trimmed and rejected
- User sees no feedback (silent validation)

### Backend Errors
- 400 Bad Request: Missing content
- 404 Not Found: Invalid task ID
- 500 Server Error: Logged and user notified

---

## Performance Considerations

### Optimistic Updates
Comments appear instantly in UI before backend confirmation:
1. User submits comment
2. Comment added to local state immediately
3. API request sent in background
4. On success: State already updated
5. On failure: State reverted, error shown

### Memory Management
- TextEditingController properly disposed
- Async operations cancelled on widget dispose
- No memory leaks from listeners

### Network Optimization
- Comments fetched once per task view
- Riverpod caching prevents redundant requests
- Mock mode eliminates network entirely

---

## Testing

### Manual Testing Checklist

- [ ] View comments on task with existing comments
- [ ] View task with no comments (empty state)
- [ ] Add comment to task
- [ ] Add multiple comments in sequence
- [ ] Submit empty comment (should be rejected)
- [ ] Test with backend server running
- [ ] Test with USE_MOCKS=true (no backend)
- [ ] Test keyboard "Send" action
- [ ] Test loading states
- [ ] Test error states (stop backend mid-operation)

### Unit Test Suggestions

```dart
// Test comment model
test('Comment model has all required fields', () {
  final comment = Comment(/* ... */);
  expect(comment.id, isNotEmpty);
  expect(comment.taskId, isNotEmpty);
});

// Test repository
test('MockCommentsRepository returns comments for task', () async {
  final repo = MockCommentsRepository();
  final comments = await repo.fetchComments('task-1');
  expect(comments, isNotEmpty);
});

// Test controller
test('addComment adds comment to state', () async {
  // ... test implementation
});
```

---

## Future Enhancements

### Potential Features

1. **Edit Comments** - Allow users to edit their own comments
2. **Delete Comments** - Allow deletion with confirmation
3. **Rich Text** - Support markdown formatting
4. **Mentions** - @mention team members
5. **Reactions** - Emoji reactions to comments
6. **Attachments** - Upload files with comments
7. **Threading** - Reply to specific comments
8. **Notifications** - Notify users of new comments
9. **Real-time Updates** - WebSocket for live comments
10. **Search** - Search comments across all tasks

### Technical Improvements

- Pagination for tasks with many comments
- Pull-to-refresh gesture
- Offline support with local caching
- Comment drafts (auto-save)
- Push notifications for mentions

---

## Troubleshooting

### Comments Not Loading

**Problem:** Comments list shows loading spinner indefinitely

**Solutions:**
1. Check backend server is running (`npm run dev`)
2. Verify `API_BASE_URL` is correct
3. Check browser network tab for 404/500 errors
4. Try with `USE_MOCKS=true` to isolate backend issues

### Cannot Add Comments

**Problem:** Send button doesn't work

**Solutions:**
1. Ensure comment input is not empty
2. Check console for error messages
3. Verify backend endpoint accepts POST requests
4. Test with mock mode first

### Old Comments Showing

**Problem:** Comments don't update after adding

**Solutions:**
1. Force refresh by navigating away and back
2. Check Riverpod provider isn't cached incorrectly
3. Verify backend returns new comment in POST response

---

## Related Documentation

- `api_config.md` - API configuration and environment variables
- `backend_mock.md` - Mock server setup and endpoints
- `flutter_checklist.md` - Development checklist
- `progress.md` - Overall project progress

---

## Changelog

### v1.0.0 - December 4, 2025
- ✅ Initial implementation
- ✅ Comment model and DTOs
- ✅ Repository layer (mock + remote)
- ✅ Riverpod state management
- ✅ UI with comments list and input
- ✅ Backend endpoints
- ✅ Mock data seeding
- ✅ Error handling
- ✅ Time formatting ("2h ago")
- ✅ Empty state handling
- ✅ Loading states
- ✅ Optimistic updates

---

## Contributors

- Task Comments System: Implemented December 4, 2025
- Addresses: **Axis 1 - Collaborative Computing** requirement
- Feature: **Comments per task** for team collaboration
