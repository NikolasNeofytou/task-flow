import 'package:hive_flutter/hive_flutter.dart';

/// Local storage service using Hive
class HiveStorageService {
  static const String _requestsBox = 'requests';
  static const String _notificationsBox = 'notifications';
  static const String _cacheBox = 'cache';

  static Box<dynamic>? _requests;
  static Box<dynamic>? _notifications;
  static Box<dynamic>? _cache;

  /// Initialize Hive storage
  Future<void> init() async {
    await Hive.initFlutter();
    _requests = await Hive.openBox(_requestsBox);
    _notifications = await Hive.openBox(_notificationsBox);
    _cache = await Hive.openBox(_cacheBox);
  }

  // Request methods
  Future<void> saveRequest(String id, Map<String, dynamic> data) async {
    await _requests?.put(id, data);
  }

  Future<Map<String, dynamic>?> getRequest(String id) async {
    return _requests?.get(id);
  }

  Future<List<Map<String, dynamic>>> getAllRequests() async {
    final box = _requests;
    if (box == null) return [];
    return box.values.cast<Map<String, dynamic>>().toList();
  }

  Future<void> deleteRequest(String id) async {
    await _requests?.delete(id);
  }

  Future<void> updateRequestStatus(String id, String status) async {
    final data = await getRequest(id);
    if (data != null) {
      data['status'] = status;
      await saveRequest(id, data);
    }
  }

  Future<void> saveBulkRequests(List<Map<String, dynamic>> requests) async {
    for (final request in requests) {
      if (request['id'] != null) {
        await saveRequest(request['id'] as String, request);
      }
    }
  }

  // Notification methods
  Future<void> saveNotification(String id, Map<String, dynamic> data) async {
    await _notifications?.put(id, data);
  }

  Future<Map<String, dynamic>?> getNotification(String id) async {
    return _notifications?.get(id);
  }

  Future<List<Map<String, dynamic>>> getAllNotifications() async {
    final box = _notifications;
    if (box == null) return [];
    return box.values.cast<Map<String, dynamic>>().toList();
  }

  Future<void> deleteNotification(String id) async {
    await _notifications?.delete(id);
  }

  Future<void> markNotificationAsRead(String id) async {
    final data = await getNotification(id);
    if (data != null) {
      data['is_read'] = true;
      data['read_at'] = DateTime.now().toIso8601String();
      await saveNotification(id, data);
    }
  }

  Future<List<Map<String, dynamic>>> getUnreadNotifications() async {
    final all = await getAllNotifications();
    return all.where((n) => n['is_read'] != true).toList();
  }

  Future<void> saveBulkNotifications(
      List<Map<String, dynamic>> notifications) async {
    for (final notification in notifications) {
      if (notification['id'] != null) {
        await saveNotification(notification['id'] as String, notification);
      }
    }
  }

  Future<void> clearReadNotifications() async {
    final all = await getAllNotifications();
    final toDelete = all.where((n) => n['is_read'] == true).toList();
    for (final notification in toDelete) {
      if (notification['id'] != null) {
        await deleteNotification(notification['id'] as String);
      }
    }
  }

  // Cache methods
  Future<void> setCacheTimestamp(String key) async {
    await _cache?.put(
        '${key}_timestamp', DateTime.now().millisecondsSinceEpoch);
  }

  static int? getCacheTimestamp(String key) {
    return _cache?.get('${key}_timestamp') as int?;
  }

  static bool isCacheValid(String key,
      {Duration maxAge = const Duration(minutes: 30)}) {
    final timestamp = getCacheTimestamp(key);
    if (timestamp == null) return false;
    final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateTime.now().difference(cacheTime) < maxAge;
  }

  // Clear all data
  static Future<void> clearAll() async {
    await _requests?.clear();
    await _notifications?.clear();
    await _cache?.clear();
  }
}
