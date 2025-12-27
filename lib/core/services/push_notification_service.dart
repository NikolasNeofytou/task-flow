import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import 'local_notification_service.dart';

/// Push notification service using Firebase Cloud Messaging
class PushNotificationService {
  PushNotificationService({
    required Dio dio,
  }) : _dio = dio;

  final Dio _dio;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  String? _fcmToken;
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _backgroundSubscription;

  /// Get current FCM token
  String? get fcmToken => _fcmToken;

  /// Initialize push notifications
  Future<void> initialize() async {
    if (kIsWeb) {
      debugPrint('Push notifications not supported on web');
      return;
    }

    try {
      // Request permission
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus != AuthorizationStatus.authorized &&
          settings.authorizationStatus != AuthorizationStatus.provisional) {
        debugPrint('Push notification permission denied');
        return;
      }

      // Get FCM token
      _fcmToken = await _messaging.getToken();
      debugPrint('FCM Token: $_fcmToken');

      // Register token with backend
      if (_fcmToken != null) {
        await _registerToken(_fcmToken!);
      }

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        _registerToken(newToken);
      });

      // Setup message handlers
      _setupMessageHandlers();

      debugPrint('Push notification service initialized');
    } catch (e) {
      debugPrint('Failed to initialize push notifications: $e');
    }
  }

  /// Register FCM token with backend
  Future<void> _registerToken(String token) async {
    try {
      await _dio.post(
        '/notifications/register-device',
        data: {
          'fcmToken': token,
          'platform': defaultTargetPlatform.name,
        },
      );
      debugPrint('FCM token registered with backend');
    } catch (e) {
      debugPrint('Failed to register FCM token: $e');
    }
  }

  /// Unregister FCM token from backend
  Future<void> unregisterToken() async {
    if (_fcmToken == null) return;

    try {
      await _dio.delete('/notifications/register-device');
      debugPrint('FCM token unregistered from backend');
    } catch (e) {
      debugPrint('Failed to unregister FCM token: $e');
    }
  }

  /// Setup foreground and background message handlers
  void _setupMessageHandlers() {
    // Handle foreground messages
    _foregroundSubscription = FirebaseMessaging.onMessage.listen((message) {
      debugPrint('Foreground message received: ${message.messageId}');
      _handleMessage(message, isBackground: false);
    });

    // Handle background messages (app opened from notification)
    _backgroundSubscription =
        FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('Background message opened: ${message.messageId}');
      _handleMessage(message, isBackground: true);
    });

    // Handle message when app is opened from terminated state
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        debugPrint(
            'Message opened app from terminated state: ${message.messageId}');
        _handleMessage(message, isBackground: true);
      }
    });
  }

  /// Handle incoming push notification
  void _handleMessage(RemoteMessage message, {required bool isBackground}) {
    final notification = message.notification;
    final data = message.data;

    if (notification == null) return;

    // Show local notification if app is in foreground
    if (!isBackground) {
      LocalNotificationService.showNotification(
        id: message.hashCode,
        title: notification.title ?? 'Notification',
        body: notification.body ?? '',
        payload: _buildPayload(data),
      );
    }

    // Handle notification tap action
    if (isBackground && data.isNotEmpty) {
      _handleNotificationTap(data);
    }
  }

  /// Build payload string from notification data
  String? _buildPayload(Map<String, dynamic> data) {
    if (data.isEmpty) return null;

    // Handle different notification types
    if (data.containsKey('taskId')) {
      return 'task:${data['taskId']}';
    } else if (data.containsKey('projectId')) {
      return 'project:${data['projectId']}';
    } else if (data.containsKey('requestId')) {
      return 'request:${data['requestId']}';
    } else if (data.containsKey('notificationId')) {
      return 'notification:${data['notificationId']}';
    }

    return null;
  }

  /// Handle notification tap action
  void _handleNotificationTap(Map<String, dynamic> data) {
    // This will be handled by DeepLinkService
    // The payload format matches deep link patterns
    debugPrint('Notification tapped with data: $data');

    // You can emit an event here for the app to handle
    // For now, the payload will be handled by LocalNotificationService
  }

  /// Dispose resources
  void dispose() {
    _foregroundSubscription?.cancel();
    _backgroundSubscription?.cancel();
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background message received: ${message.messageId}');

  // Handle background message
  // You can show notification, update local database, etc.
}
