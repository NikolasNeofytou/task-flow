import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../models/app_notification.dart';
import '../models/project.dart';
import '../models/request.dart';
import '../models/task_item.dart';
import '../models/user.dart';
import '../network/api_client.dart';
import '../repositories/calendar_repository.dart';
import '../repositories/comments_repository.dart';
import '../repositories/mock/mock_repositories.dart';
import '../repositories/notifications_repository.dart';
import '../repositories/projects_repository.dart';
import '../repositories/remote/calendar_remote_repository.dart';
import '../repositories/remote/comments_remote_repository.dart';
import '../repositories/remote/notifications_remote_repository.dart';
import '../repositories/remote/projects_remote_repository.dart';
import '../repositories/remote/requests_remote_repository.dart';
import '../repositories/requests_repository.dart';
import '../data/mock_data.dart';

// Repository providers (mock vs remote selection)
final requestsRepositoryProvider = Provider<RequestsRepository>((ref) {
  final config = ref.watch(appConfigProvider);
  if (config.useMocks) return MockRequestsRepository();
  final dio = ref.watch(dioProvider);
  return RequestsRemoteRepository(dio);
});

final notificationsRepositoryProvider = Provider<NotificationsRepository>((ref) {
  final config = ref.watch(appConfigProvider);
  if (config.useMocks) return MockNotificationsRepository();
  final dio = ref.watch(dioProvider);
  return NotificationsRemoteRepository(dio);
});

final projectsRepositoryProvider = Provider<ProjectsRepository>((ref) {
  final config = ref.watch(appConfigProvider);
  if (config.useMocks) return MockProjectsRepository();
  final dio = ref.watch(dioProvider);
  return ProjectsRemoteRepository(dio);
});

final calendarRepositoryProvider = Provider<CalendarRepository>((ref) {
  final config = ref.watch(appConfigProvider);
  if (config.useMocks) return MockCalendarRepository();
  final dio = ref.watch(dioProvider);
  return CalendarRemoteRepository(dio);
});

final commentsRepositoryProvider = Provider<CommentsRepository>((ref) {
  final config = ref.watch(appConfigProvider);
  if (config.useMocks) return MockCommentsRepository();
  final dio = ref.watch(dioProvider);
  return CommentsRemoteRepository(dio);
});

// Data providers using repositories with autoDispose for better memory management
final requestsProvider = FutureProvider.autoDispose<List<Request>>(
  (ref) => ref.read(requestsRepositoryProvider).fetchRequests(),
);

final notificationsProvider = FutureProvider.autoDispose<List<AppNotification>>(
  (ref) => ref.read(notificationsRepositoryProvider).fetchNotifications(),
);

final projectsProvider = FutureProvider.autoDispose<List<Project>>(
  (ref) => ref.read(projectsRepositoryProvider).fetchProjects(),
);

final calendarTasksProvider = FutureProvider.autoDispose<List<TaskItem>>(
  (ref) => ref.read(calendarRepositoryProvider).fetchCalendarTasks(),
);

final projectTasksProvider =
    FutureProvider.autoDispose.family<List<TaskItem>, String>((ref, projectId) {
  return ref.read(projectsRepositoryProvider).fetchProjectTasks(projectId);
});

// All tasks provider (for search)
final tasksProvider = FutureProvider.autoDispose<List<TaskItem>>(
  (ref) async {
    final projects = await ref.watch(projectsProvider.future);
    final List<TaskItem> allTasks = [];
    
    for (final project in projects) {
      final tasks = await ref.read(projectsRepositoryProvider).fetchProjectTasks(project.id);
      allTasks.addAll(tasks);
    }
    
    return allTasks;
  },
);

// Users provider
final usersProvider = FutureProvider.autoDispose<List<User>>(
  (ref) => MockDataSource.fetchUsers(),
);
