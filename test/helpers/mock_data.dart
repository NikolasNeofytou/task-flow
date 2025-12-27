/// Mock data builders for testing
library;

import 'package:taskflow/core/models/task.dart';
import 'package:taskflow/core/models/project.dart';
import 'package:taskflow/core/models/user.dart';
import 'package:taskflow/features/requests/models/request_model.dart';
import 'package:taskflow/features/notifications/models/notification_model.dart';

/// Mock user data builder
class MockUsers {
  static User get testUser => User(
        id: 'user-1',
        name: 'Test User',
        email: 'test@taskflow.com',
        avatar: null,
        createdAt: DateTime(2025, 1, 1),
      );

  static User get demoUser => User(
        id: 'user-2',
        name: 'Demo User',
        email: 'demo@taskflow.com',
        avatar: null,
        createdAt: DateTime(2025, 1, 1),
      );

  static User get adminUser => User(
        id: 'user-admin',
        name: 'Admin User',
        email: 'admin@taskflow.com',
        avatar: null,
        createdAt: DateTime(2025, 1, 1),
      );

  static List<User> get allUsers => [testUser, demoUser, adminUser];
}

/// Mock project data builder
class MockProjects {
  static Project get testProject => Project(
        id: 'project-1',
        name: 'Test Project',
        description: 'A test project for unit testing',
        color: '#FF5733',
        ownerId: MockUsers.testUser.id,
        members: [MockUsers.testUser.id, MockUsers.demoUser.id],
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );

  static Project get completedProject => Project(
        id: 'project-2',
        name: 'Completed Project',
        description: 'A completed project',
        color: '#28A745',
        ownerId: MockUsers.testUser.id,
        members: [MockUsers.testUser.id],
        createdAt: DateTime(2024, 12, 1),
        updatedAt: DateTime(2025, 1, 1),
      );

  static Project get archivedProject => Project(
        id: 'project-3',
        name: 'Archived Project',
        description: 'An archived project',
        color: '#6C757D',
        ownerId: MockUsers.adminUser.id,
        members: [MockUsers.adminUser.id],
        createdAt: DateTime(2024, 6, 1),
        updatedAt: DateTime(2024, 12, 31),
      );

  static List<Project> get allProjects => [
        testProject,
        completedProject,
        archivedProject,
      ];
}

/// Mock task data builder
class MockTasks {
  static TaskItem get openTask => TaskItem(
        id: 'task-1',
        title: 'Open Task',
        description: 'This task is open and needs to be done',
        projectId: MockProjects.testProject.id,
        status: TaskStatus.todo,
        priority: TaskPriority.high,
        dueDate: DateTime.now().add(const Duration(days: 7)),
        assignedTo: [MockUsers.testUser.id],
        createdBy: MockUsers.testUser.id,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      );

  static TaskItem get inProgressTask => TaskItem(
        id: 'task-2',
        title: 'In Progress Task',
        description: 'This task is currently being worked on',
        projectId: MockProjects.testProject.id,
        status: TaskStatus.inProgress,
        priority: TaskPriority.medium,
        dueDate: DateTime.now().add(const Duration(days: 3)),
        assignedTo: [MockUsers.demoUser.id],
        createdBy: MockUsers.testUser.id,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now(),
      );

  static TaskItem get completedTask => TaskItem(
        id: 'task-3',
        title: 'Completed Task',
        description: 'This task has been completed',
        projectId: MockProjects.testProject.id,
        status: TaskStatus.done,
        priority: TaskPriority.low,
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
        assignedTo: [MockUsers.testUser.id],
        createdBy: MockUsers.adminUser.id,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      );

  static TaskItem get overdueTask => TaskItem(
        id: 'task-4',
        title: 'Overdue Task',
        description: 'This task is overdue',
        projectId: MockProjects.testProject.id,
        status: TaskStatus.todo,
        priority: TaskPriority.high,
        dueDate: DateTime.now().subtract(const Duration(days: 5)),
        assignedTo: [MockUsers.testUser.id],
        createdBy: MockUsers.testUser.id,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now().subtract(const Duration(days: 10)),
      );

  static List<TaskItem> get allTasks => [
        openTask,
        inProgressTask,
        completedTask,
        overdueTask,
      ];
}

/// Mock request data builder
class MockRequests {
  static RequestModel get pendingRequest => RequestModel(
        id: 'request-1',
        type: RequestType.projectInvitation,
        fromUserId: MockUsers.testUser.id,
        toUserId: MockUsers.demoUser.id,
        projectId: MockProjects.testProject.id,
        status: RequestStatus.pending,
        message: 'Would you like to join this project?',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      );

  static RequestModel get acceptedRequest => RequestModel(
        id: 'request-2',
        type: RequestType.taskAssignment,
        fromUserId: MockUsers.adminUser.id,
        toUserId: MockUsers.testUser.id,
        taskId: MockTasks.openTask.id,
        status: RequestStatus.accepted,
        message: 'Can you take on this task?',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 12)),
      );

  static RequestModel get rejectedRequest => RequestModel(
        id: 'request-3',
        type: RequestType.projectInvitation,
        fromUserId: MockUsers.demoUser.id,
        toUserId: MockUsers.testUser.id,
        projectId: MockProjects.archivedProject.id,
        status: RequestStatus.rejected,
        message: 'Join our archived project',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 4)),
      );

  static List<RequestModel> get allRequests => [
        pendingRequest,
        acceptedRequest,
        rejectedRequest,
      ];
}

/// Mock notification data builder
class MockNotifications {
  static NotificationModel get unreadNotification => NotificationModel(
        id: 'notif-1',
        userId: MockUsers.testUser.id,
        type: NotificationType.taskAssigned,
        title: 'New Task Assigned',
        message: 'You have been assigned to a new task',
        taskId: MockTasks.openTask.id,
        projectId: MockProjects.testProject.id,
        fromUserId: MockUsers.adminUser.id,
        read: false,
        actionable: true,
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      );

  static NotificationModel get readNotification => NotificationModel(
        id: 'notif-2',
        userId: MockUsers.testUser.id,
        type: NotificationType.projectInvitation,
        title: 'Project Invitation',
        message: 'You have been invited to join a project',
        projectId: MockProjects.testProject.id,
        fromUserId: MockUsers.demoUser.id,
        requestId: MockRequests.acceptedRequest.id,
        read: true,
        actionable: false,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      );

  static NotificationModel get actionableNotification => NotificationModel(
        id: 'notif-3',
        userId: MockUsers.testUser.id,
        type: NotificationType.commentMention,
        title: 'You were mentioned',
        message: '@TestUser check this out',
        taskId: MockTasks.inProgressTask.id,
        fromUserId: MockUsers.demoUser.id,
        read: false,
        actionable: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      );

  static List<NotificationModel> get allNotifications => [
        unreadNotification,
        readNotification,
        actionableNotification,
      ];
}

/// Builder for creating custom test data
class TestDataBuilder<T> {
  final T Function() _builder;
  final Map<String, dynamic> _overrides = {};

  TestDataBuilder(this._builder);

  TestDataBuilder<T> with_({required String field, required dynamic value}) {
    _overrides[field] = value;
    return this;
  }

  T build() {
    final instance = _builder();
    // Apply overrides (would need reflection or code generation in production)
    return instance;
  }
}
