import '../../models/notification_model.dart';

/// Remote repository for notifications
class NotificationsRemoteRepository {
  /// Get all notifications
  Future<List<NotificationModel>> getAllNotifications() async {
    // Stub implementation
    return [];
  }

  /// Get notification by id
  Future<NotificationModel?> getNotification(String id) async {
    // Stub implementation
    return null;
  }

  /// Create new notification
  Future<NotificationModel> createNotification(
      NotificationModel notification) async {
    // Stub implementation
    return notification;
  }

  /// Mark notification as read
  Future<NotificationModel> markAsRead(String id) async {
    // Stub implementation
    final notification = await getNotification(id);
    return notification ??
        const NotificationModel(
          id: '',
          title: '',
          type: NotificationType.message,
          userId: '',
          isRead: true,
        );
  }

  /// Delete notification
  Future<void> deleteNotification(String id) async {
    // Stub implementation
  }

  /// Get unread notifications
  Future<List<NotificationModel>> getUnreadNotifications() async {
    // Stub implementation
    return [];
  }
}
