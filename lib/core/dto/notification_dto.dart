import '../models/app_notification.dart';

class NotificationDto {
  const NotificationDto({
    required this.id,
    required this.title,
    required this.type,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String type;
  final DateTime createdAt;

  factory NotificationDto.fromJson(Map<String, dynamic> json) {
    return NotificationDto(
      id: json['id'] as String,
      title: json['title'] as String,
      type: json['type'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  AppNotification toDomain() {
    return AppNotification(
      id: id,
      title: title,
      type: _mapType(type),
      createdAt: createdAt,
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
