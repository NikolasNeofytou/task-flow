import 'package:hive_flutter/hive_flutter.dart';
import '../models/request.dart';
import '../models/app_notification.dart';
import '../models/comment.dart';

/// Extension to HiveService for additional models
class HiveStorageService {
  static const String requestsBox = 'requests';
  static const String notificationsBox = 'notifications';
  static const String commentsBox = 'comments';
  static const String cacheMetadataBox = 'cache_metadata';

  static bool _initialized = false;

  /// Initialize additional Hive boxes
  static Future<void> initializeAdditional() async {
    if (_initialized) return;

    // Open additional boxes
    await Hive.openBox<Map>(requestsBox);
    await Hive.openBox<Map>(notificationsBox);
    await Hive.openBox<Map>(commentsBox);
    await Hive.openBox<String>(cacheMetadataBox);

    _initialized = true;
  }

  /// Requests operations
  static Box<Map> get _requestsBox => Hive.box<Map>(requestsBox);

  static Future<void> saveRequests(List<Request> requests) async {
    final box = _requestsBox;
    await box.clear();
    for (final request in requests) {
      await box.put(request.id, {
        'id': request.id,
        'title': request.title,
        'status': request.status.toString(),
        'type': request.type.toString(),
        'fromUserId': request.fromUserId,
        'toUserId': request.toUserId,
        'taskId': request.taskId,
        'projectId': request.projectId,
        'createdAt': request.createdAt.toIso8601String(),
      });
    }
    await _updateCacheTimestamp('requests');
  }

  static List<Request> getRequests() {
    return _requestsBox.values.map((data) => _mapToRequest(data)).toList();
  }

  static Request _mapToRequest(Map data) {
    return Request(
      id: data['id'] as String,
      title: data['title'] as String,
      status: _parseRequestStatus(data['status'] as String),
      type: _parseRequestType(data['type'] as String),
      createdAt: DateTime.parse(data['createdAt'] as String),
      fromUserId: data['fromUserId'] as String?,
      toUserId: data['toUserId'] as String?,
      taskId: data['taskId'] as String?,
      projectId: data['projectId'] as String?,
    );
  }

  static RequestStatus _parseRequestStatus(String value) {
    if (value.contains('accepted')) return RequestStatus.accepted;
    if (value.contains('rejected')) return RequestStatus.rejected;
    if (value.contains('sent')) return RequestStatus.sent;
    return RequestStatus.pending;
  }

  static RequestType _parseRequestType(String value) {
    if (value.contains('taskAssignment')) return RequestType.taskAssignment;
    if (value.contains('taskTransfer')) return RequestType.taskTransfer;
    return RequestType.general;
  }

  /// Notifications operations
  static Box<Map> get _notificationsBox => Hive.box<Map>(notificationsBox);

  static Future<void> saveNotifications(
      List<AppNotification> notifications) async {
    final box = _notificationsBox;
    await box.clear();
    for (final notification in notifications) {
      await box.put(notification.id, {
        'id': notification.id,
        'title': notification.title,
        'type': notification.type.toString(),
        'createdAt': notification.createdAt.toIso8601String(),
        'requestId': notification.requestId,
        'taskId': notification.taskId,
        'fromUserId': notification.fromUserId,
        'actionable': notification.actionable,
      });
    }
    await _updateCacheTimestamp('notifications');
  }

  static List<AppNotification> getNotifications() {
    return _notificationsBox.values
        .map((data) => _mapToNotification(data))
        .toList();
  }

  static AppNotification _mapToNotification(Map data) {
    return AppNotification(
      id: data['id'] as String,
      title: data['title'] as String,
      type: _parseNotificationType(data['type'] as String),
      createdAt: DateTime.parse(data['createdAt'] as String),
      requestId: data['requestId'] as String?,
      taskId: data['taskId'] as String?,
      fromUserId: data['fromUserId'] as String?,
      actionable: data['actionable'] as bool? ?? false,
    );
  }

  static NotificationType _parseNotificationType(String value) {
    if (value.contains('comment')) return NotificationType.comment;
    if (value.contains('accepted')) return NotificationType.accepted;
    if (value.contains('declined')) return NotificationType.declined;
    if (value.contains('completed')) return NotificationType.completed;
    if (value.contains('taskAssignment')) {
      return NotificationType.taskAssignment;
    }
    return NotificationType.overdue;
  }

  /// Comments operations
  static Box<Map> get _commentsBox => Hive.box<Map>(commentsBox);

  static Future<void> saveComments(
      String taskId, List<Comment> comments) async {
    final box = _commentsBox;
    // Store comments with taskId prefix
    for (final comment in comments) {
      await box.put('${taskId}_${comment.id}', {
        'id': comment.id,
        'taskId': comment.taskId,
        'authorName': comment.authorName,
        'content': comment.content,
        'createdAt': comment.createdAt.toIso8601String(),
      });
    }
    await _updateCacheTimestamp('comments_$taskId');
  }

  static List<Comment> getComments(String taskId) {
    return _commentsBox.values
        .where((data) => data['taskId'] == taskId)
        .map((data) => Comment(
              id: data['id'] as String,
              taskId: data['taskId'] as String,
              authorName: data['authorName'] as String,
              content: data['content'] as String,
              createdAt: DateTime.parse(data['createdAt'] as String),
            ))
        .toList();
  }

  /// Cache metadata operations
  static Box<String> get _metadataBox => Hive.box<String>(cacheMetadataBox);

  static Future<void> _updateCacheTimestamp(String key) async {
    await _metadataBox.put(
        '${key}_timestamp', DateTime.now().toIso8601String());
  }

  static DateTime? getCacheTimestamp(String key) {
    final timestamp = _metadataBox.get('${key}_timestamp');
    return timestamp != null ? DateTime.parse(timestamp) : null;
  }

  static bool isCacheValid(String key,
      {Duration maxAge = const Duration(minutes: 5)}) {
    final timestamp = getCacheTimestamp(key);
    if (timestamp == null) return false;
    return DateTime.now().difference(timestamp) < maxAge;
  }

  /// Clear all additional caches
  static Future<void> clearAll() async {
    await _requestsBox.clear();
    await _notificationsBox.clear();
    await _commentsBox.clear();
    await _metadataBox.clear();
  }
}
