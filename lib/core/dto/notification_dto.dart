import '../models/app_notification.dart';

class NotificationDto {
  const NotificationDto({
    required this.id,
    required this.title,
    required this.type,
    required this.createdAt,
    this.requestId,
    this.taskId,
    this.fromUserId,
    this.read,
    this.actionable,
  });

  final String id;
  final String title;
  final String type;
  final DateTime createdAt;
  final String? requestId;
  final String? taskId;
  final String? fromUserId;
  final bool? read;
  final bool? actionable;

  factory NotificationDto.fromJson(Map<String, dynamic> json) {
    return NotificationDto(
      id: json['id'] as String,
      title: json['title'] as String,
      type: json['type'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      requestId: json['requestId'] as String?,
      taskId: json['taskId'] as String?,
      fromUserId: json['fromUserId'] as String?,
      read: json['read'] as bool?,
      actionable: json['actionable'] as bool?,
    );
  }

  AppNotification toDomain() {
    return AppNotification(
      id: id,
      title: title,
      type: _mapType(type),
      createdAt: createdAt,
      requestId: requestId,
      taskId: taskId,
      fromUserId: fromUserId,
      actionable: actionable ?? false,
    );
  }

  NotificationType _mapType(String value) {
    switch (value.toLowerCase()) {
      case 'comment':
        return NotificationType.comment;
      case 'accepted':
        return NotificationType.accepted;
      case 'declined':
        return NotificationType.declined;
      case 'completed':
        return NotificationType.completed;
      case 'overdue':
      default:
        return NotificationType.overdue;
    }
  }
}
