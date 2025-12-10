enum TaskStatus { pending, done, blocked }

class TaskItem {
  const TaskItem({
    required this.id,
    required this.title,
    required this.dueDate,
    required this.status,
    this.projectId,
    this.assignedTo,
    this.assignedBy,
    this.requestId,
  });

  final String id;
  final String title;
  final DateTime dueDate;
  final TaskStatus status;
  final String? projectId;
  final String? assignedTo; // User ID of assignee
  final String? assignedBy; // User ID of assigner
  final String? requestId; // Link to assignment request if pending
}
