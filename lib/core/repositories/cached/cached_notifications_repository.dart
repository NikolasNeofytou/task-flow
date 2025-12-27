import '../models/app_notification.dart';
import '../repositories/notifications_repository.dart';
import '../storage/hive_storage_service.dart';

/// Offline-first repository for notifications
class CachedNotificationsRepository implements NotificationsRepository {
  CachedNotificationsRepository(this._remoteRepository);

  final NotificationsRepository _remoteRepository;

  @override
  Future<List<AppNotification>> fetchNotifications() async {
    try {
      final notifications = await _remoteRepository.fetchNotifications();
      await HiveStorageService.saveNotifications(notifications);
      return notifications;
    } catch (e) {
      final cached = HiveStorageService.getNotifications();
      if (cached.isEmpty) rethrow;
      return cached;
    }
  }
}
