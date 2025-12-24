import '../models/task_item.dart';

class TaskDto {
  const TaskDto({
    required this.id,
    required this.title,
    required this.status,
    this.projectId,
    this.description,
    this.priority,
    this.assignedTo,
    this.dueDate,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String title;
  final String status;
  final String? projectId;
  final String? description;
  final String? priority;
  final List<String>? assignedTo;
  final DateTime? dueDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory TaskDto.fromJson(Map<String, dynamic> json) {
    return TaskDto(
      id: json['id'] as String,
      title: json['title'] as String,
      status: json['status'] as String,
      projectId: json['projectId'] as String?,
      description: json['description'] as String?,
      priority: json['priority'] as String?,
      assignedTo: (json['assignedTo'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  TaskItem toDomain() {
    return TaskItem(
      id: id,
      title: title,
      dueDate: dueDate ?? DateTime.now().add(const Duration(days: 7)),
      status: _mapStatus(status),
      projectId: projectId,
    );
  }

  TaskStatus _mapStatus(String value) {
    switch (value.toLowerCase()) {
      case 'done':
      case 'completed':
        return TaskStatus.done;
      case 'blocked':
        return TaskStatus.blocked;
      case 'in_progress':
      case 'inprogress':
        return TaskStatus.pending;
      case 'todo':
      case 'pending':
      default:
        return TaskStatus.pending;
    }
  }
}
