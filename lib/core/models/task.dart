/// Task status enumeration
enum TaskStatus {
  pending,
  inProgress,
  completed,
  cancelled,
}

/// Task priority enumeration
enum TaskPriority {
  low,
  medium,
  high,
  urgent,
}

/// Task item model
class TaskItem {
  const TaskItem({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    required this.priority,
    this.dueDate,
    this.createdAt,
    this.updatedAt,
    this.assignedTo,
    this.projectId,
    this.tags,
  });

  final String id;
  final String title;
  final String? description;
  final TaskStatus status;
  final TaskPriority priority;
  final DateTime? dueDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? assignedTo;
  final String? projectId;
  final List<String>? tags;

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      status: TaskStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TaskStatus.pending,
      ),
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => TaskPriority.medium,
      ),
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      assignedTo: json['assigned_to'] as String?,
      projectId: json['project_id'] as String?,
      tags:
          json['tags'] != null ? List<String>.from(json['tags'] as List) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status.name,
      'priority': priority.name,
      'due_date': dueDate?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'assigned_to': assignedTo,
      'project_id': projectId,
      'tags': tags,
    };
  }
}
