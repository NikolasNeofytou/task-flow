import 'dart:async';

import '../models/app_notification.dart';
import '../models/comment.dart';
import '../models/project.dart';
import '../models/request.dart';
import '../models/task_item.dart';
import '../models/user.dart';

class MockDataSource {
  static int _commentCounter = 5;
  
  // Mock team members
  static const List<User> mockUsers = [
    User(
      id: 'user-1',
      name: 'Alice Johnson',
      email: 'alice@taskflow.com',
      avatarUrl: null,
    ),
    User(
      id: 'user-2',
      name: 'Bob Smith',
      email: 'bob@taskflow.com',
      avatarUrl: null,
    ),
    User(
      id: 'user-3',
      name: 'Carol Williams',
      email: 'carol@taskflow.com',
      avatarUrl: null,
    ),
    User(
      id: 'user-4',
      name: 'David Brown',
      email: 'david@taskflow.com',
      avatarUrl: null,
    ),
  ];
  
  static Future<List<User>> fetchUsers() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return mockUsers;
  }
  
  static final Map<String, List<TaskItem>> _projectTasks = {
    'proj-1': [
      TaskItem(
        id: 'task-a',
        title: 'Design handoff',
        dueDate: DateTime(2025, 8, 18),
        status: TaskStatus.pending,
        projectId: 'proj-1',
      ),
      TaskItem(
        id: 'task-b',
        title: 'Implement calendar',
        dueDate: DateTime(2025, 8, 20),
        status: TaskStatus.blocked,
        projectId: 'proj-1',
      ),
    ],
    'proj-2': [
      TaskItem(
        id: 'task-c',
        title: 'QA round',
        dueDate: DateTime(2025, 8, 22),
        status: TaskStatus.pending,
        projectId: 'proj-2',
      ),
    ],
    'proj-3': [
      TaskItem(
        id: 'task-d',
        title: 'Dependency fix',
        dueDate: DateTime(2025, 8, 19),
        status: TaskStatus.blocked,
        projectId: 'proj-3',
      ),
    ],
  };

  static Future<List<Request>> fetchRequests() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return [
      Request(
        id: 'req-1',
        title: 'Member X asked you to take task Y',
        status: RequestStatus.pending,
        createdAt: DateTime(2025, 8, 15),
      ),
      Request(
        id: 'req-2',
        title: 'You want to take task X from member Y',
        status: RequestStatus.pending,
        createdAt: DateTime(2025, 8, 16),
      ),
      Request(
        id: 'req-3',
        title: 'Member Z accepted your request',
        status: RequestStatus.accepted,
        createdAt: DateTime(2025, 8, 17),
      ),
    ];
  }

  static Future<List<AppNotification>> fetchNotifications() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return [
      AppNotification(
        id: 'not-0',
        title: 'Alice Johnson wants to assign you "Design handoff" task',
        type: NotificationType.taskAssignment,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        requestId: 'req-task-1',
        taskId: 'task-a',
        fromUserId: 'user-1',
        actionable: true,
      ),
      AppNotification(
        id: 'not-1',
        title: 'Project X is overdue.',
        type: NotificationType.overdue,
        createdAt: DateTime(2025, 8, 12),
      ),
      AppNotification(
        id: 'not-2',
        title: 'Member Z commented on Project Y.',
        type: NotificationType.comment,
        createdAt: DateTime(2025, 8, 13),
      ),
      AppNotification(
        id: 'not-3',
        title: 'Member X accepted your request.',
        type: NotificationType.accepted,
        createdAt: DateTime(2025, 8, 14),
      ),
      AppNotification(
        id: 'not-4',
        title: 'Member Y declined your request.',
        type: NotificationType.declined,
        createdAt: DateTime(2025, 8, 15),
      ),
    ];
  }

  static Future<List<Project>> fetchProjects() async {
    await Future.delayed(const Duration(milliseconds: 200));
    final now = DateTime.now();
    return [
      Project(
        id: 'proj-1',
        name: 'Mobile App V2',
        status: ProjectStatus.onTrack,
        tasks: 12,
        completedTasks: 8,
        deadline: DateTime(now.year, now.month, now.day + 5),
        teamMembers: ['user-1', 'user-2', 'user-3'],
      ),
      Project(
        id: 'proj-2',
        name: 'Website Redesign',
        status: ProjectStatus.dueSoon,
        tasks: 8,
        completedTasks: 3,
        deadline: DateTime(now.year, now.month + 1, 15),
        teamMembers: ['user-2', 'user-4'],
      ),
      Project(
        id: 'proj-3',
        name: 'Backend API Update',
        status: ProjectStatus.blocked,
        tasks: 6,
        completedTasks: 2,
        deadline: DateTime(now.year, now.month, now.day + 10),
        teamMembers: ['user-1', 'user-3', 'user-4'],
      ),
    ];
  }

  static Future<List<TaskItem>> fetchCalendarTasks() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return [
      TaskItem(
        id: 'task-1',
        title: 'Project X due tomorrow',
        dueDate: DateTime(2025, 8, 17),
        status: TaskStatus.pending,
        projectId: 'proj-1',
      ),
      TaskItem(
        id: 'task-2',
        title: 'Project Z kickoff',
        dueDate: DateTime(2025, 8, 19),
        status: TaskStatus.pending,
        projectId: 'proj-2',
      ),
      TaskItem(
        id: 'task-3',
        title: 'Task review with Member Y',
        dueDate: DateTime(2025, 8, 21),
        status: TaskStatus.done,
        projectId: 'proj-1',
      ),
    ];
  }

  static Future<List<TaskItem>> fetchProjectTasks(String projectId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _projectTasks[projectId] ?? [];
  }

  static final Map<String, List<Comment>> _taskComments = {
    'task-a': [
      Comment(
        id: 'comment-1',
        taskId: 'task-a',
        authorName: 'Sarah Chen',
        content: 'Design files are ready for review. Let me know if you need any changes.',
        createdAt: DateTime(2025, 8, 15, 10, 30),
      ),
      Comment(
        id: 'comment-2',
        taskId: 'task-a',
        authorName: 'Mike Johnson',
        content: 'Thanks! I\'ll review them by EOD today.',
        createdAt: DateTime(2025, 8, 15, 14, 20),
      ),
    ],
    'task-b': [
      Comment(
        id: 'comment-3',
        taskId: 'task-b',
        authorName: 'Lisa Park',
        content: 'Blocked on the date picker library integration. Need help with time zones.',
        createdAt: DateTime(2025, 8, 16, 9, 15),
      ),
    ],
    'task-c': [
      Comment(
        id: 'comment-4',
        taskId: 'task-c',
        authorName: 'John Smith',
        content: 'Found 3 issues in the last build. Logging them now.',
        createdAt: DateTime(2025, 8, 17, 11, 45),
      ),
    ],
  };

  static Future<List<Comment>> fetchComments(String taskId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _taskComments[taskId] ?? [];
  }

  static Future<Comment> addComment({
    required String taskId,
    required String content,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final comment = Comment(
      id: 'comment-${_commentCounter++}',
      taskId: taskId,
      authorName: 'You',
      content: content,
      createdAt: DateTime.now(),
    );
    _taskComments.putIfAbsent(taskId, () => []).add(comment);
    return comment;
  }
}
