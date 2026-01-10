import '../../../core/models/task.dart';

/// Remote repository for tasks
class TasksRemoteRepository {
  /// Get all tasks
  Future<List<TaskItem>> getAllTasks() async {
    // Stub implementation
    return [];
  }

  /// Get task by id
  Future<TaskItem?> getTask(String id) async {
    // Stub implementation
    return null;
  }

  /// Create new task
  Future<TaskItem> createTask(TaskItem task) async {
    // Stub implementation
    return task;
  }

  /// Update existing task
  Future<TaskItem> updateTask(TaskItem task) async {
    // Stub implementation
    return task;
  }

  /// Delete task
  Future<void> deleteTask(String id) async {
    // Stub implementation
  }
}
