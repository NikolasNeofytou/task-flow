import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

import '../models/task_item.dart';
import '../models/project.dart';
import '../models/user.dart';
import '../providers/data_providers.dart';
import 'hive_service.dart';
import 'connectivity_service.dart';

/// Sync service to manage data synchronization between local and remote
class SyncService {
  final Ref _ref;
  Timer? _syncTimer;
  bool _isSyncing = false;

  SyncService(this._ref) {
    _startPeriodicSync();
  }

  /// Start periodic background sync
  void _startPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => syncAll(),
    );
  }

  /// Sync all data (tasks, projects, users)
  Future<SyncResult> syncAll() async {
    if (_isSyncing) {
      return SyncResult(
        success: false,
        message: 'Sync already in progress',
      );
    }

    final connectivity = _ref.read(connectivityServiceProvider);
    if (!connectivity.isOnline) {
      return SyncResult(
        success: false,
        message: 'No internet connection',
        isOffline: true,
      );
    }

    _isSyncing = true;

    try {
      // Fetch from remote
      final tasks = await _ref.read(tasksProvider.future);
      final projects = await _ref.read(projectsProvider.future);
      final users = await _ref.read(usersProvider.future);

      // Save to local storage
      await HiveService.saveTasks(tasks);
      await HiveService.saveProjects(projects);
      await HiveService.saveUsers(users);

      _isSyncing = false;

      return SyncResult(
        success: true,
        message: 'Synced successfully',
        taskCount: tasks.length,
        projectCount: projects.length,
        userCount: users.length,
      );
    } catch (e) {
      _isSyncing = false;
      
      return SyncResult(
        success: false,
        message: 'Sync failed: $e',
      );
    }
  }

  /// Sync tasks only
  Future<void> syncTasks() async {
    try {
      final tasks = await _ref.read(tasksProvider.future);
      await HiveService.saveTasks(tasks);
    } catch (e) {
      // Handle error silently - data will be synced on next attempt
    }
  }

  /// Sync projects only
  Future<void> syncProjects() async {
    try {
      final projects = await _ref.read(projectsProvider.future);
      await HiveService.saveProjects(projects);
    } catch (e) {
      // Handle error silently
    }
  }

  /// Sync users only
  Future<void> syncUsers() async {
    try {
      final users = await _ref.read(usersProvider.future);
      await HiveService.saveUsers(users);
    } catch (e) {
      // Handle error silently
    }
  }

  /// Get cached data
  Future<CachedData> getCachedData() async {
    return CachedData(
      tasks: HiveService.getTasks(),
      projects: HiveService.getProjects(),
      users: HiveService.getUsers(),
      lastSyncTasks: HiveService.getLastSync('tasks'),
      lastSyncProjects: HiveService.getLastSync('projects'),
      lastSyncUsers: HiveService.getLastSync('users'),
    );
  }

  /// Dispose resources
  void dispose() {
    _syncTimer?.cancel();
  }
}

/// Sync result data class
class SyncResult {
  final bool success;
  final String message;
  final bool isOffline;
  final int? taskCount;
  final int? projectCount;
  final int? userCount;

  SyncResult({
    required this.success,
    required this.message,
    this.isOffline = false,
    this.taskCount,
    this.projectCount,
    this.userCount,
  });
}

/// Cached data class
class CachedData {
  final List<TaskItem> tasks;
  final List<Project> projects;
  final List<User> users;
  final DateTime? lastSyncTasks;
  final DateTime? lastSyncProjects;
  final DateTime? lastSyncUsers;

  CachedData({
    required this.tasks,
    required this.projects,
    required this.users,
    this.lastSyncTasks,
    this.lastSyncProjects,
    this.lastSyncUsers,
  });

  bool get hasCachedData =>
      tasks.isNotEmpty || projects.isNotEmpty || users.isNotEmpty;

  DateTime? get oldestSync {
    final syncs = [lastSyncTasks, lastSyncProjects, lastSyncUsers]
        .where((d) => d != null)
        .toList();
    
    if (syncs.isEmpty) return null;
    
    syncs.sort((a, b) => a!.compareTo(b!));
    return syncs.first;
  }
}

/// Riverpod provider for sync service
final syncServiceProvider = Provider<SyncService>((ref) {
  final service = SyncService(ref);
  ref.onDispose(() => service.dispose());
  return service;
});

/// Provider that returns cached data when offline
final offlineTasksProvider = FutureProvider.autoDispose<List<TaskItem>>((ref) async {
  final connectivity = ref.watch(connectivityServiceProvider);
  
  if (connectivity.isOnline) {
    // Try to fetch from remote
    try {
      return await ref.watch(tasksProvider.future);
    } catch (e) {
      // If remote fails, fall back to cache
      return HiveService.getTasks();
    }
  } else {
    // Offline - return cached data
    return HiveService.getTasks();
  }
});

final offlineProjectsProvider = FutureProvider.autoDispose<List<Project>>((ref) async {
  final connectivity = ref.watch(connectivityServiceProvider);
  
  if (connectivity.isOnline) {
    try {
      return await ref.watch(projectsProvider.future);
    } catch (e) {
      return HiveService.getProjects();
    }
  } else {
    return HiveService.getProjects();
  }
});

final offlineUsersProvider = FutureProvider.autoDispose<List<User>>((ref) async {
  final connectivity = ref.watch(connectivityServiceProvider);
  
  if (connectivity.isOnline) {
    try {
      return await ref.watch(usersProvider.future);
    } catch (e) {
      return HiveService.getUsers();
    }
  } else {
    return HiveService.getUsers();
  }
});
