/// Notification type enumeration
enum NotificationType {
  taskAssigned,
  taskCompleted,
  projectInvitation,
  deadlineReminder,
  systemUpdate,
  message,
}

/// Notification model for handling user notifications
class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.title,
    this.message,
    required this.type,
    required this.userId,
    this.isRead = false,
    this.createdAt,
    this.readAt,
    this.data,
    this.actionUrl,
  });

  final String id;
  final String title;
  final String? message;
  final NotificationType type;
  final String userId;
  final bool isRead;
  final DateTime? createdAt;
  final DateTime? readAt;
  final Map<String, dynamic>? data;
  final String? actionUrl;

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String?,
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.message,
      ),
      userId: json['user_id'] as String,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      readAt: json['read_at'] != null
          ? DateTime.parse(json['read_at'] as String)
          : null,
      data: json['data'] as Map<String, dynamic>?,
      actionUrl: json['actionUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.name,
      'user_id': userId,
      'is_read': isRead,
      'created_at': createdAt?.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
      'data': data,
      'actionUrl': actionUrl,
    };
  }
}
