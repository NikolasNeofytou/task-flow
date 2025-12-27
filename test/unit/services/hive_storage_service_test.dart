/// Unit tests for HiveStorageService
library;
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:taskflow/core/storage/hive_storage_service.dart';
import 'package:taskflow/features/requests/models/request_model.dart';
import 'package:taskflow/features/notifications/models/notification_model.dart';
import '../../helpers/mock_data.dart';

void main() {
  late HiveStorageService storage;

  setUpAll(() async {
    // Initialize Hive for testing
    await Hive.initFlutter();
  });

  setUp(() async {
    storage = HiveStorageService();
    await storage.init();
  });

  tearDown(() async {
    await storage.clearAll();
  });

  tearDownAll(() async {
    await Hive.deleteFromDisk();
  });

  group('HiveStorageService - Requests', () {
    test('saveRequest stores request successfully', () async {
      // Arrange
      final request = MockRequests.pendingRequest;

      // Act
      await storage.saveRequest(request);
      final retrieved = await storage.getRequest(request.id);

      // Assert
      expect(retrieved, isNotNull);
      expect(retrieved!.id, request.id);
      expect(retrieved.type, request.type);
      expect(retrieved.status, request.status);
    });

    test('getAllRequests returns all stored requests', () async {
      // Arrange
      final requests = MockRequests.allRequests;
      for (final request in requests) {
        await storage.saveRequest(request);
      }

      // Act
      final retrieved = await storage.getAllRequests();

      // Assert
      expect(retrieved.length, requests.length);
    });

    test('deleteRequest removes request', () async {
      // Arrange
      final request = MockRequests.pendingRequest;
      await storage.saveRequest(request);

      // Act
      await storage.deleteRequest(request.id);
      final retrieved = await storage.getRequest(request.id);

      // Assert
      expect(retrieved, isNull);
    });

    test('updateRequestStatus changes request status', () async {
      // Arrange
      final request = MockRequests.pendingRequest;
      await storage.saveRequest(request);

      // Act
      await storage.updateRequestStatus(
        request.id,
        RequestStatus.accepted,
      );
      final retrieved = await storage.getRequest(request.id);

      // Assert
      expect(retrieved!.status, RequestStatus.accepted);
    });
  });

  group('HiveStorageService - Notifications', () {
    test('saveNotification stores notification successfully', () async {
      // Arrange
      final notification = MockNotifications.unreadNotification;

      // Act
      await storage.saveNotification(notification);
      final retrieved = await storage.getNotification(notification.id);

      // Assert
      expect(retrieved, isNotNull);
      expect(retrieved!.id, notification.id);
      expect(retrieved.title, notification.title);
      expect(retrieved.read, notification.read);
    });

    test('getAllNotifications returns all stored notifications', () async {
      // Arrange
      final notifications = MockNotifications.allNotifications;
      for (final notif in notifications) {
        await storage.saveNotification(notif);
      }

      // Act
      final retrieved = await storage.getAllNotifications();

      // Assert
      expect(retrieved.length, notifications.length);
    });

    test('getUnreadNotifications filters unread only', () async {
      // Arrange
      final notifications = MockNotifications.allNotifications;
      for (final notif in notifications) {
        await storage.saveNotification(notif);
      }

      // Act
      final unread = await storage.getUnreadNotifications();

      // Assert
      expect(unread.every((n) => !n.read), true);
      expect(unread.length, lessThan(notifications.length));
    });

    test('markNotificationAsRead updates read status', () async {
      // Arrange
      final notification = MockNotifications.unreadNotification;
      await storage.saveNotification(notification);

      // Act
      await storage.markNotificationAsRead(notification.id);
      final retrieved = await storage.getNotification(notification.id);

      // Assert
      expect(retrieved!.read, true);
    });

    test('deleteNotification removes notification', () async {
      // Arrange
      final notification = MockNotifications.unreadNotification;
      await storage.saveNotification(notification);

      // Act
      await storage.deleteNotification(notification.id);
      final retrieved = await storage.getNotification(notification.id);

      // Assert
      expect(retrieved, isNull);
    });

    test('clearReadNotifications removes only read notifications', () async {
      // Arrange
      final notifications = MockNotifications.allNotifications;
      for (final notif in notifications) {
        await storage.saveNotification(notif);
      }

      // Act
      await storage.clearReadNotifications();
      final remaining = await storage.getAllNotifications();

      // Assert
      expect(remaining.every((n) => !n.read), true);
    });
  });

  group('HiveStorageService - Bulk Operations', () {
    test('clearAll removes all data', () async {
      // Arrange
      await storage.saveRequest(MockRequests.pendingRequest);
      await storage.saveNotification(MockNotifications.unreadNotification);

      // Act
      await storage.clearAll();
      final requests = await storage.getAllRequests();
      final notifications = await storage.getAllNotifications();

      // Assert
      expect(requests.isEmpty, true);
      expect(notifications.isEmpty, true);
    });

    test('saveBulkRequests stores multiple requests', () async {
      // Arrange
      final requests = MockRequests.allRequests;

      // Act
      await storage.saveBulkRequests(requests);
      final retrieved = await storage.getAllRequests();

      // Assert
      expect(retrieved.length, requests.length);
    });

    test('saveBulkNotifications stores multiple notifications', () async {
      // Arrange
      final notifications = MockNotifications.allNotifications;

      // Act
      await storage.saveBulkNotifications(notifications);
      final retrieved = await storage.getAllNotifications();

      // Assert
      expect(retrieved.length, notifications.length);
    });
  });

  group('HiveStorageService - Cache Timestamps', () {
    test('setCacheTimestamp stores timestamp', () async {
      // Arrange
      const key = 'requests_cache';
      final timestamp = DateTime.now();

      // Act
      await storage.setCacheTimestamp(key, timestamp);
      final retrieved = storage.getCacheTimestamp(key);

      // Assert
      expect(retrieved, isNotNull);
      expect(
        retrieved!.difference(timestamp).inSeconds,
        lessThan(1),
      );
    });

    test('isCacheValid returns true for recent cache', () async {
      // Arrange
      const key = 'test_cache';
      await storage.setCacheTimestamp(key, DateTime.now());

      // Act
      final isValid = storage.isCacheValid(
        key,
        maxAge: const Duration(hours: 1),
      );

      // Assert
      expect(isValid, true);
    });

    test('isCacheValid returns false for old cache', () async {
      // Arrange
      const key = 'test_cache';
      await storage.setCacheTimestamp(
        key,
        DateTime.now().subtract(const Duration(hours: 2)),
      );

      // Act
      final isValid = storage.isCacheValid(
        key,
        maxAge: const Duration(hours: 1),
      );

      // Assert
      expect(isValid, false);
    });

    test('isCacheValid returns false for missing timestamp', () async {
      // Act
      final isValid = storage.isCacheValid(
        'nonexistent_key',
        maxAge: const Duration(hours: 1),
      );

      // Assert
      expect(isValid, false);
    });
  });
}
