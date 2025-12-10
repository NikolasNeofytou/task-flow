import '../models/task_item.dart';

class TaskDto {
  const TaskDto({
    required this.id,
    required this.title,
    required this.dueDate,
    required this.status,
    this.projectId,
  });

  final String id;
  final String title;
  final DateTime dueDate;
  final String status;
  final String? projectId;

  factory TaskDto.fromJson(Map<String, dynamic> json) {
    return TaskDto(
      id: json['id'] as String,
      title: json['title'] as String,
      dueDate: DateTime.parse(json['dueDate'] as String),
      status: json['status'] as String,
      projectId: json['projectId'] as String?,
    );
  }

  TaskItem toDomain() {
    return TaskItem(
      id: id,
      title: title,
      dueDate: dueDate,
      status: _mapStatus(status),
      projectId: projectId,
    );
  }

  TaskStatus _mapStatus(String value) {
    switch (value.toLowerCase()) {
      case 'done':
        return TaskStatus.done;
      case 'blocked':
        return TaskStatus.blocked;
      case 'pending':
      default:
        return TaskStatus.pending;
    }
  }
}
