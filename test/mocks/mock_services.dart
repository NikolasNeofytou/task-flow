/// Mock services for testing
library;

import 'package:dio/dio.dart';
import 'package:mockito/annotations.dart';
import 'package:taskflow/core/api/api_client.dart';
import 'package:taskflow/features/auth/application/auth_service.dart';
import 'package:taskflow/core/storage/hive_service.dart';
import 'package:taskflow/core/storage/hive_storage_service.dart';
import 'package:taskflow/core/repositories/remote/projects_remote_repository.dart';
import 'package:taskflow/core/repositories/remote/tasks_remote_repository.dart';
import 'package:taskflow/features/requests/repositories/requests_remote_repository.dart';
import 'package:taskflow/features/notifications/repositories/notifications_remote_repository.dart';
import 'package:taskflow/core/services/local_notification_service.dart';
import 'package:taskflow/core/services/push_notification_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Generate mocks with: flutter pub run build_runner build
@GenerateMocks([
  // Core services
  ApiClient,
  Dio,
  FlutterSecureStorage,
  HiveService,
  HiveStorageService,
  Connectivity,

  // Auth
  AuthService,

  // Repositories
  ProjectsRemoteRepository,
  TasksRemoteRepository,
  RequestsRemoteRepository,
  NotificationsRemoteRepository,

  // Notification services
  LocalNotificationService,
  PushNotificationService,
])
void main() {}
