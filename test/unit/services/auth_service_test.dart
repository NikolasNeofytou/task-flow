/// Unit tests for AuthService
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:taskflow/core/api/api_client.dart';
import 'package:taskflow/features/auth/application/auth_service.dart';
import 'package:taskflow/features/auth/models/auth_models.dart';

@GenerateMocks([ApiClient, FlutterSecureStorage])
import 'auth_service_test.mocks.dart';

void main() {
  late AuthService authService;
  late MockApiClient mockApiClient;
  late MockFlutterSecureStorage mockStorage;

  setUp(() {
    mockApiClient = MockApiClient();
    mockStorage = MockFlutterSecureStorage();
    authService = AuthService(mockApiClient, mockStorage);
  });

  group('AuthService - Login', () {
    test('successful login stores token and returns user', () async {
      // Arrange
      const email = 'test@taskflow.com';
      const password = 'password123';
      final response = {
        'token': 'test-jwt-token',
        'user': {
          'id': 'user-1',
          'name': 'Test User',
          'email': email,
          'avatar': null,
          'createdAt': '2025-01-01T00:00:00.000Z',
        },
      };

      when(mockApiClient.post('/auth/login', data: anyNamed('data')))
          .thenAnswer((_) async => Response(
                data: response,
                statusCode: 200,
                requestOptions: RequestOptions(path: '/auth/login'),
              ));

      when(mockStorage.write(key: 'auth_token', value: 'test-jwt-token'))
          .thenAnswer((_) async => {});

      // Act
      final result = await authService.login(email, password);

      // Assert
      expect(result, isA<LoginResponse>());
      expect(result.token, 'test-jwt-token');
      expect(result.user.email, email);
      verify(mockStorage.write(key: 'auth_token', value: 'test-jwt-token'))
          .called(1);
      verify(mockApiClient.post('/auth/login', data: anyNamed('data')))
          .called(1);
    });

    test('login with invalid credentials throws exception', () async {
      // Arrange
      when(mockApiClient.post('/auth/login', data: anyNamed('data')))
          .thenThrow(DioException(
        requestOptions: RequestOptions(path: '/auth/login'),
        response: Response(
          statusCode: 401,
          data: {'error': 'Invalid credentials'},
          requestOptions: RequestOptions(path: '/auth/login'),
        ),
      ));

      // Act & Assert
      expect(
        () => authService.login('wrong@email.com', 'wrongpass'),
        throwsA(isA<DioException>()),
      );
    });

    test('login with network error throws exception', () async {
      // Arrange
      when(mockApiClient.post('/auth/login', data: anyNamed('data')))
          .thenThrow(DioException(
        requestOptions: RequestOptions(path: '/auth/login'),
        type: DioExceptionType.connectionTimeout,
      ));

      // Act & Assert
      expect(
        () => authService.login('test@email.com', 'password'),
        throwsA(isA<DioException>()),
      );
    });
  });

  group('AuthService - Signup', () {
    test('successful signup returns user', () async {
      // Arrange
      const name = 'New User';
      const email = 'new@taskflow.com';
      const password = 'password123';
      final response = {
        'token': 'new-jwt-token',
        'user': {
          'id': 'user-2',
          'name': name,
          'email': email,
          'avatar': null,
          'createdAt': '2025-01-01T00:00:00.000Z',
        },
      };

      when(mockApiClient.post('/auth/signup', data: anyNamed('data')))
          .thenAnswer((_) async => Response(
                data: response,
                statusCode: 201,
                requestOptions: RequestOptions(path: '/auth/signup'),
              ));

      when(mockStorage.write(key: 'auth_token', value: 'new-jwt-token'))
          .thenAnswer((_) async => {});

      // Act
      final result = await authService.signup(name, email, password);

      // Assert
      expect(result, isA<LoginResponse>());
      expect(result.user.name, name);
      expect(result.user.email, email);
      verify(mockStorage.write(key: 'auth_token', value: 'new-jwt-token'))
          .called(1);
    });

    test('signup with existing email throws exception', () async {
      // Arrange
      when(mockApiClient.post('/auth/signup', data: anyNamed('data')))
          .thenThrow(DioException(
        requestOptions: RequestOptions(path: '/auth/signup'),
        response: Response(
          statusCode: 409,
          data: {'error': 'Email already exists'},
          requestOptions: RequestOptions(path: '/auth/signup'),
        ),
      ));

      // Act & Assert
      expect(
        () => authService.signup('Test', 'existing@email.com', 'pass'),
        throwsA(isA<DioException>()),
      );
    });
  });

  group('AuthService - Token Management', () {
    test('getToken returns stored token', () async {
      // Arrange
      when(mockStorage.read(key: 'auth_token'))
          .thenAnswer((_) async => 'stored-token');

      // Act
      final token = await authService.getToken();

      // Assert
      expect(token, 'stored-token');
      verify(mockStorage.read(key: 'auth_token')).called(1);
    });

    test('getToken returns null when no token stored', () async {
      // Arrange
      when(mockStorage.read(key: 'auth_token')).thenAnswer((_) async => null);

      // Act
      final token = await authService.getToken();

      // Assert
      expect(token, isNull);
    });

    test('logout clears token', () async {
      // Arrange
      when(mockStorage.delete(key: 'auth_token')).thenAnswer((_) async => {});

      // Act
      await authService.logout();

      // Assert
      verify(mockStorage.delete(key: 'auth_token')).called(1);
    });

    test('isLoggedIn returns true when token exists', () async {
      // Arrange
      when(mockStorage.read(key: 'auth_token'))
          .thenAnswer((_) async => 'some-token');

      // Act
      final isLoggedIn = await authService.isLoggedIn();

      // Assert
      expect(isLoggedIn, true);
    });

    test('isLoggedIn returns false when no token', () async {
      // Arrange
      when(mockStorage.read(key: 'auth_token')).thenAnswer((_) async => null);

      // Act
      final isLoggedIn = await authService.isLoggedIn();

      // Assert
      expect(isLoggedIn, false);
    });
  });

  group('AuthService - Token Refresh', () {
    test('refreshToken updates stored token', () async {
      // Arrange
      final response = {
        'token': 'refreshed-token',
        'user': {
          'id': 'user-1',
          'name': 'Test User',
          'email': 'test@taskflow.com',
          'avatar': null,
          'createdAt': '2025-01-01T00:00:00.000Z',
        },
      };

      when(mockApiClient.post('/auth/refresh'))
          .thenAnswer((_) async => Response(
                data: response,
                statusCode: 200,
                requestOptions: RequestOptions(path: '/auth/refresh'),
              ));

      when(mockStorage.write(key: 'auth_token', value: 'refreshed-token'))
          .thenAnswer((_) async => {});

      // Act
      final result = await authService.refreshToken();

      // Assert
      expect(result.token, 'refreshed-token');
      verify(mockStorage.write(key: 'auth_token', value: 'refreshed-token'))
          .called(1);
    });
  });
}
