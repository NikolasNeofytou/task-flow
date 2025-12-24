import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Local notification service for task reminders and app notifications
class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  /// Initialize the notification service
  static Future<void> initialize() async {
    if (_initialized || kIsWeb) return;

    // Initialize timezone
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      macOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  /// Request notification permissions
  static Future<bool> requestPermissions() async {
    if (kIsWeb) return false;

    if (Platform.isIOS || Platform.isMacOS) {
      final result = await _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return result ?? false;
    } else if (Platform.isAndroid) {
      final androidImplementation =
          _notifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      
      final result = await androidImplementation?.requestNotificationsPermission();
      return result ?? false;
    }

    return false;
  }

  /// Show instant notification
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_initialized || kIsWeb) return;

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'default_channel',
      'Default',
      channelDescription: 'Default notification channel',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      macOS: iosDetails,
    );

    await _notifications.show(id, title, body, details, payload: payload);
  }

  /// Schedule notification for specific time
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    if (!_initialized || kIsWeb) return;

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'scheduled_channel',
      'Scheduled',
      channelDescription: 'Scheduled notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      macOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Schedule task reminder (1 day before and 1 hour before)
  static Future<void> scheduleTaskReminder({
    required String taskId,
    required String taskTitle,
    required DateTime dueDate,
  }) async {
    final now = DateTime.now();

    // Schedule 1 day before (if due date is more than 1 day away)
    final oneDayBefore = dueDate.subtract(const Duration(days: 1));
    if (oneDayBefore.isAfter(now)) {
      await scheduleNotification(
        id: taskId.hashCode,
        title: 'Task due tomorrow',
        body: taskTitle,
        scheduledDate: oneDayBefore,
        payload: 'task:$taskId',
      );
    }

    // Schedule 1 hour before (if due date is more than 1 hour away)
    final oneHourBefore = dueDate.subtract(const Duration(hours: 1));
    if (oneHourBefore.isAfter(now)) {
      await scheduleNotification(
        id: taskId.hashCode + 1,
        title: 'Task due in 1 hour',
        body: taskTitle,
        scheduledDate: oneHourBefore,
        payload: 'task:$taskId',
      );
    }
  }

  /// Cancel notification
  static Future<void> cancelNotification(int id) async {
    if (!_initialized || kIsWeb) return;
    await _notifications.cancel(id);
  }

  /// Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    if (!_initialized || kIsWeb) return;
    await _notifications.cancelAll();
  }

  /// Get pending notifications
  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    if (!_initialized || kIsWeb) return [];
    return await _notifications.pendingNotificationRequests();
  }

  /// Notification types
  static Future<void> showTaskNotification({
    required String taskId,
    required String title,
    required String message,
  }) async {
    await showNotification(
      id: taskId.hashCode,
      title: title,
      body: message,
      payload: 'task:$taskId',
    );
  }

  static Future<void> showCommentNotification({
    required String taskId,
    required String commenterName,
    required String message,
  }) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch,
      title: '$commenterName commented',
      body: message,
      payload: 'task:$taskId',
    );
  }

  static Future<void> showAssignmentNotification({
    required String taskId,
    required String taskTitle,
    required String assignerName,
  }) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch,
      title: 'New task assigned',
      body: '$assignerName assigned you: $taskTitle',
      payload: 'task:$taskId',
    );
  }

  static Future<void> showMentionNotification({
    required String taskId,
    required String taskTitle,
    required String mentionerName,
  }) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch,
      title: '$mentionerName mentioned you',
      body: 'In: $taskTitle',
      payload: 'task:$taskId',
    );
  }

  // Callback handlers
  static void _onDidReceiveLocalNotification(
    int id,
    String? title,
    String? body,
    String? payload,
  ) {
    // Handle iOS foreground notification
    // You can show a dialog or navigate here
  }

  static void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null) return;

    // Handle notification tap
    // Parse payload and navigate to appropriate screen
    if (payload.startsWith('task:')) {
      final taskId = payload.substring(5);
      // Navigate to task detail screen
      // You'll need to implement navigation here
    }
  }
}
