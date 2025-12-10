import 'package:dio/dio.dart';

import '../../dto/notification_dto.dart';
import '../../models/app_notification.dart';
import '../../network/exceptions.dart';
import '../notifications_repository.dart';

class NotificationsRemoteRepository implements NotificationsRepository {
  NotificationsRemoteRepository(this._dio);

  final Dio _dio;

  @override
  Future<List<AppNotification>> fetchNotifications() async {
    try {
      final response = await _dio.get('/notifications');
      final data = response.data as List<dynamic>;
      return data
          .map(
            (json) => NotificationDto.fromJson(json as Map<String, dynamic>).toDomain(),
          )
          .toList();
    } catch (e) {
      throw mapDioError(e);
    }
  }
}
