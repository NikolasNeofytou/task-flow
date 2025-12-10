enum NotificationType { overdue, comment, accepted, declined, completed, taskAssignment }

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.type,
    required this.createdAt,
    this.requestId,
    this.taskId,
    this.fromUserId,
    this.actionable = false,
  });

  final String id;
  final String title;
  final NotificationType type;
  final DateTime createdAt;
  final String? requestId; // Link to request if notification is for task assignment
  final String? taskId; // Related task
  final String? fromUserId; // Who sent the request
  final bool actionable; // Whether user can take action (accept/reject)
}
