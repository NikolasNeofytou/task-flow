import 'dart:async';
// import 'package:firebase_messaging/firebase_messaging.dart';  // Temporarily disabled for web
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';


/// Push notification service using Firebase Cloud Messaging
/// Note: Firebase messaging is temporarily disabled for web compatibility
class PushNotificationService {
  PushNotificationService({
    required Dio dio,
  }) : _dio = dio;

  final Dio _dio;
  // final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  String? _fcmToken;
  // StreamSubscription<RemoteMessage>? _foregroundSubscription;
  // StreamSubscription<RemoteMessage>? _backgroundSubscription;

  /// Get current FCM token
  String? get fcmToken => _fcmToken;

  /// Initialize push notifications
  Future<void> initialize() async {
    debugPrint('Push notifications temporarily disabled for web compatibility');
    return;
  }

  /// Register FCM token with backend
  Future<void> _registerToken(String token) async {
    debugPrint('Token registration disabled for web compatibility');
    return;
  }

  /// Unregister FCM token from backend
  Future<void> unregisterToken() async {
    debugPrint('Token unregistration disabled for web compatibility');
    return;
  }

  /// Setup foreground and background message handlers
  void _setupMessageHandlers() {
    debugPrint('Message handlers disabled for web compatibility');
  }

  /// Dispose resources
  void dispose() {
    debugPrint('Push notification service disposed');
  }
}
