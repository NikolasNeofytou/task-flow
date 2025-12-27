/// Unit tests for connectivity and caching logic
library;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:taskflow/core/repositories/cached/cached_requests_repository.dart';
import 'package:taskflow/features/requests/repositories/requests_remote_repository.dart';
import 'package:taskflow/core/storage/hive_storage_service.dart';
import '../../helpers/mock_data.dart';

@GenerateMocks([
  RequestsRemoteRepository,
  HiveStorageService,
  Connectivity,
])
import 'cached_repository_test.mocks.dart';

void main() {
  late CachedRequestsRepository cachedRepo;
  late MockRequestsRemoteRepository mockRemoteRepo;
  late MockHiveStorageService mockStorage;
  late MockConnectivity mockConnectivity;

  setUp(() {
    mockRemoteRepo = MockRequestsRemoteRepository();
    mockStorage = MockHiveStorageService();
    mockConnectivity = MockConnectivity();

    cachedRepo = CachedRequestsRepository(
      mockRemoteRepo,
      mockStorage,
      mockConnectivity,
    );
  });

  group('CachedRequestsRepository - Online Mode', () {
    setUp(() {
      // Mock online connectivity
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.wifi);
    });

    test('getAllRequests fetches from API when online', () async {
      // Arrange
      final requests = MockRequests.allRequests;
      when(mockRemoteRepo.getAllRequests()).thenAnswer((_) async => requests);
      when(mockStorage.saveBulkRequests(any)).thenAnswer((_) async => {});
      when(mockStorage.setCacheTimestamp(any, any)).thenAnswer((_) async => {});

      // Act
      final result = await cachedRepo.getAllRequests();

      // Assert
      expect(result, requests);
      verify(mockRemoteRepo.getAllRequests()).called(1);
      verify(mockStorage.saveBulkRequests(requests)).called(1);
    });

    test('createRequest updates both API and cache', () async {
      // Arrange
      final request = MockRequests.pendingRequest;
      when(mockRemoteRepo.createRequest(any)).thenAnswer((_) async => request);
      when(mockStorage.saveRequest(any)).thenAnswer((_) async => {});

      // Act
      final result = await cachedRepo.createRequest(request);

      // Assert
      expect(result, request);
      verify(mockRemoteRepo.createRequest(request)).called(1);
      verify(mockStorage.saveRequest(request)).called(1);
    });
  });

  group('CachedRequestsRepository - Offline Mode', () {
    setUp(() {
      // Mock offline connectivity
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.none);
    });

    test('getAllRequests returns cached data when offline', () async {
      // Arrange
      final cachedRequests = MockRequests.allRequests;
      when(mockStorage.getAllRequests())
          .thenAnswer((_) async => cachedRequests);

      // Act
      final result = await cachedRepo.getAllRequests();

      // Assert
      expect(result, cachedRequests);
      verify(mockStorage.getAllRequests()).called(1);
      verifyNever(mockRemoteRepo.getAllRequests());
    });

    test('createRequest fails gracefully when offline', () async {
      // Arrange
      final request = MockRequests.pendingRequest;

      // Act & Assert
      expect(
        () => cachedRepo.createRequest(request),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('CachedRequestsRepository - Cache Validation', () {
    test('uses cache when valid and fresh', () async {
      // Arrange
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.wifi);
      when(mockStorage.isCacheValid(any, maxAge: anyNamed('maxAge')))
          .thenAnswer((_) async => true);
      when(mockStorage.getAllRequests())
          .thenAnswer((_) async => MockRequests.allRequests);

      // Act
      final result = await cachedRepo.getAllRequests();

      // Assert
      expect(result, isNotEmpty);
      verify(mockStorage.getAllRequests()).called(1);
      verifyNever(mockRemoteRepo.getAllRequests());
    });

    test('fetches from API when cache is stale', () async {
      // Arrange
      final requests = MockRequests.allRequests;
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.wifi);
      when(mockStorage.isCacheValid(any, maxAge: anyNamed('maxAge')))
          .thenAnswer((_) async => false);
      when(mockRemoteRepo.getAllRequests()).thenAnswer((_) async => requests);
      when(mockStorage.saveBulkRequests(any)).thenAnswer((_) async => {});
      when(mockStorage.setCacheTimestamp(any, any)).thenAnswer((_) async => {});

      // Act
      final result = await cachedRepo.getAllRequests();

      // Assert
      expect(result, requests);
      verify(mockRemoteRepo.getAllRequests()).called(1);
      verify(mockStorage.saveBulkRequests(requests)).called(1);
    });
  });

  group('CachedRequestsRepository - Error Handling', () {
    test('falls back to cache when API fails', () async {
      // Arrange
      final cachedRequests = MockRequests.allRequests;
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.wifi);
      when(mockStorage.isCacheValid(any, maxAge: anyNamed('maxAge')))
          .thenAnswer((_) async => false);
      when(mockRemoteRepo.getAllRequests()).thenThrow(Exception('API Error'));
      when(mockStorage.getAllRequests())
          .thenAnswer((_) async => cachedRequests);

      // Act
      final result = await cachedRepo.getAllRequests();

      // Assert
      expect(result, cachedRequests);
      verify(mockStorage.getAllRequests()).called(1);
    });

    test('throws error when both API and cache fail', () async {
      // Arrange
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.wifi);
      when(mockStorage.isCacheValid(any, maxAge: anyNamed('maxAge')))
          .thenAnswer((_) async => false);
      when(mockRemoteRepo.getAllRequests()).thenThrow(Exception('API Error'));
      when(mockStorage.getAllRequests()).thenThrow(Exception('Cache Error'));

      // Act & Assert
      expect(
        () => cachedRepo.getAllRequests(),
        throwsA(isA<Exception>()),
      );
    });
  });
}
