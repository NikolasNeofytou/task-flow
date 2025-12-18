import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_item.dart';
import '../data/mock_data.dart';

/// State notifier for managing tasks across the app
class TasksNotifier extends StateNotifier<AsyncValue<List<TaskItem>>> {
  TasksNotifier() : super(const AsyncValue.loading()) {
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    state = const AsyncValue.loading();
    try {
      final tasks = await MockDataSource.fetchCalendarTasks();
      state = AsyncValue.data(tasks);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Add a new task
  void addTask(TaskItem task) {
    state.whenData((tasks) {
      final updatedTasks = [...tasks, task];
      updatedTasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
      state = AsyncValue.data(updatedTasks);
    });
  }

  /// Update an existing task
  void updateTask(String taskId, TaskItem updatedTask) {
    state.whenData((tasks) {
      final updatedTasks = tasks.map((t) {
        return t.id == taskId ? updatedTask : t;
      }).toList();
      updatedTasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
      state = AsyncValue.data(updatedTasks);
    });
  }

  /// Remove a task
  void removeTask(String taskId) {
    state.whenData((tasks) {
      final updatedTasks = tasks.where((t) => t.id != taskId).toList();
      state = AsyncValue.data(updatedTasks);
    });
  }

  /// Update task status
  void updateTaskStatus(String taskId, TaskStatus newStatus) {
    state.whenData((tasks) {
      final updatedTasks = tasks.map((t) {
        if (t.id == taskId) {
          return TaskItem(
            id: t.id,
            title: t.title,
            dueDate: t.dueDate,
            status: newStatus,
            projectId: t.projectId,
            assignedTo: t.assignedTo,
            assignedBy: t.assignedBy,
            requestId: t.requestId,
          );
        }
        return t;
      }).toList();
      state = AsyncValue.data(updatedTasks);
    });
  }

  /// Reload tasks from data source
  Future<void> refresh() async {
    await _loadTasks();
  }
}

/// Provider for the tasks state notifier
final tasksProvider = StateNotifierProvider<TasksNotifier, AsyncValue<List<TaskItem>>>(
  (ref) => TasksNotifier(),
);
