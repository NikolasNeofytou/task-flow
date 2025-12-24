import 'package:hive_flutter/hive_flutter.dart';
import '../models/task_item.dart';
import '../models/project.dart';
import '../models/user.dart';

/// Hive database service for offline storage
/// Handles local caching of tasks, projects, and users
class HiveService {
  static const String tasksBox = 'tasks';
  static const String projectsBox = 'projects';
  static const String usersBox = 'users';
  static const String metadataBox = 'metadata';

  /// Initialize Hive and register adapters
  static Future<void> initialize() async {
    await Hive.initFlutter();
    
    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TaskItemAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ProjectAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(UserAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(TaskStatusAdapter());
    }
    
    // Open boxes
    await Hive.openBox<TaskItem>(tasksBox);
    await Hive.openBox<Project>(projectsBox);
    await Hive.openBox<User>(usersBox);
    await Hive.openBox(metadataBox);
  }

  /// Close all boxes
  static Future<void> close() async {
    await Hive.close();
  }

  /// Clear all offline data
  static Future<void> clearAll() async {
    await Hive.box<TaskItem>(tasksBox).clear();
    await Hive.box<Project>(projectsBox).clear();
    await Hive.box<User>(usersBox).clear();
    await Hive.box(metadataBox).clear();
  }

  // Tasks operations
  static Box<TaskItem> get tasks => Hive.box<TaskItem>(tasksBox);
  
  static Future<void> saveTasks(List<TaskItem> taskList) async {
    final box = tasks;
    await box.clear();
    for (final task in taskList) {
      await box.put(task.id, task);
    }
    await _updateLastSync('tasks');
  }

  static List<TaskItem> getTasks() {
    return tasks.values.toList();
  }

  static Future<void> saveTask(TaskItem task) async {
    await tasks.put(task.id, task);
  }

  static TaskItem? getTask(String id) {
    return tasks.get(id);
  }

  static Future<void> deleteTask(String id) async {
    await tasks.delete(id);
  }

  // Projects operations
  static Box<Project> get projects => Hive.box<Project>(projectsBox);
  
  static Future<void> saveProjects(List<Project> projectList) async {
    final box = projects;
    await box.clear();
    for (final project in projectList) {
      await box.put(project.id, project);
    }
    await _updateLastSync('projects');
  }

  static List<Project> getProjects() {
    return projects.values.toList();
  }

  static Future<void> saveProject(Project project) async {
    await projects.put(project.id, project);
  }

  static Project? getProject(String id) {
    return projects.get(id);
  }

  static Future<void> deleteProject(String id) async {
    await projects.delete(id);
  }

  // Users operations
  static Box<User> get users => Hive.box<User>(usersBox);
  
  static Future<void> saveUsers(List<User> userList) async {
    final box = users;
    await box.clear();
    for (final user in userList) {
      await box.put(user.id, user);
    }
    await _updateLastSync('users');
  }

  static List<User> getUsers() {
    return users.values.toList();
  }

  static Future<void> saveUser(User user) async {
    await users.put(user.id, user);
  }

  static User? getUser(String id) {
    return users.get(id);
  }

  // Metadata operations
  static Box get metadata => Hive.box(metadataBox);
  
  static Future<void> _updateLastSync(String key) async {
    await metadata.put('last_sync_$key', DateTime.now().toIso8601String());
  }

  static DateTime? getLastSync(String key) {
    final value = metadata.get('last_sync_$key');
    if (value == null) return null;
    return DateTime.parse(value as String);
  }

  static Future<void> setPendingSync(String key, bool value) async {
    await metadata.put('pending_sync_$key', value);
  }

  static bool hasPendingSync(String key) {
    return metadata.get('pending_sync_$key', defaultValue: false) as bool;
  }
}

// Hive Type Adapters
class TaskItemAdapter extends TypeAdapter<TaskItem> {
  @override
  final int typeId = 0;

  @override
  TaskItem read(BinaryReader reader) {
    return TaskItem(
      id: reader.readString(),
      title: reader.readString(),
      dueDate: DateTime.parse(reader.readString()),
      status: TaskStatus.values[reader.readInt()],
      projectId: reader.readString().isEmpty ? null : reader.readString(),
      assignedTo: reader.readString().isEmpty ? null : reader.readString(),
      assignedBy: reader.readString().isEmpty ? null : reader.readString(),
      requestId: reader.readString().isEmpty ? null : reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, TaskItem obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.title);
    writer.writeString(obj.dueDate.toIso8601String());
    writer.writeInt(obj.status.index);
    writer.writeString(obj.projectId ?? '');
    writer.writeString(obj.assignedTo ?? '');
    writer.writeString(obj.assignedBy ?? '');
    writer.writeString(obj.requestId ?? '');
  }
}

class ProjectAdapter extends TypeAdapter<Project> {
  @override
  final int typeId = 1;

  @override
  Project read(BinaryReader reader) {
    return Project(
      id: reader.readString(),
      name: reader.readString(),
      status: ProjectStatus.values[reader.readInt()],
      tasks: reader.readInt(),
      deadline: reader.readString().isEmpty ? null : DateTime.parse(reader.readString()),
      completedTasks: reader.readInt(),
      teamMembers: List<String>.from(reader.readList()),
    );
  }

  @override
  void write(BinaryWriter writer, Project obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeInt(obj.status.index);
    writer.writeInt(obj.tasks);
    writer.writeString(obj.deadline?.toIso8601String() ?? '');
    writer.writeInt(obj.completedTasks);
    writer.writeList(obj.teamMembers);
  }
}

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 2;

  @override
  User read(BinaryReader reader) {
    return User(
      id: reader.readString(),
      name: reader.readString(),
      email: reader.readString(),
      avatarUrl: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeString(obj.email);
    writer.writeString(obj.avatarUrl ?? '');
  }
}

class TaskStatusAdapter extends TypeAdapter<TaskStatus> {
  @override
  final int typeId = 3;

  @override
  TaskStatus read(BinaryReader reader) {
    return TaskStatus.values[reader.readInt()];
  }

  @override
  void write(BinaryWriter writer, TaskStatus obj) {
    writer.writeInt(obj.index);
  }
}
