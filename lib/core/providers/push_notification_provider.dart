import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_client.dart';
import '../services/push_notification_service.dart';

/// Provider for push notification service
final pushNotificationServiceProvider =
    Provider<PushNotificationService>((ref) {
  final dio = ref.watch(dioProvider);
  return PushNotificationService(dio: dio);
});

/// Provider for FCM token
final fcmTokenProvider = StateProvider<String?>((ref) {
  final service = ref.watch(pushNotificationServiceProvider);
  return service.fcmToken;
});
