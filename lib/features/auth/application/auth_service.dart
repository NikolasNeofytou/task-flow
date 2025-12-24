import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_config.dart';
import '../models/auth_models.dart';

/// Authentication service for login, signup, and session management
class AuthService {
  AuthService({
    ApiClient? apiClient,
    FlutterSecureStorage? secureStorage,
  })  : _apiClient = apiClient ?? ApiClient(baseUrl: ApiConfig.baseUrl),
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final ApiClient _apiClient;
  final FlutterSecureStorage _secureStorage;

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  /// Login with email and password
  Future<AuthResponse> login(LoginCredentials credentials) async {
    try {
      final response = await _apiClient.post(
        '${ApiConfig.authEndpoint}/login',
        data: credentials.toJson(),
      );

      if (response.data == null) {
        throw ApiException('No data received from server');
      }

      final authResponse = AuthResponse.fromJson(response.data as Map<String, dynamic>);

      // Store token and user data
      await _saveAuthData(authResponse);

      return authResponse;
    } on DioException catch (e) {
      throw ApiException(
        e.message ?? 'Login failed',
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// Signup with email, password, and display name
  Future<AuthResponse> signup(SignupCredentials credentials) async {
    try {
      final response = await _apiClient.post(
        '${ApiConfig.authEndpoint}/signup',
        data: credentials.toJson(),
      );

      if (response.data == null) {
        throw ApiException('No data received from server');
      }

      final authResponse = AuthResponse.fromJson(response.data as Map<String, dynamic>);

      // Store token and user data
      await _saveAuthData(authResponse);

      return authResponse;
    } on DioException catch (e) {
      throw ApiException(
        e.message ?? 'Signup failed',
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// Logout user and clear stored data
  Future<void> logout() async {
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _userKey);
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await _secureStorage.read(key: _tokenKey);
    return token != null && token.isNotEmpty;
  }

  /// Get current user from stored data
  Future<User?> getCurrentUser() async {
    final userJson = await _secureStorage.read(key: _userKey);
    if (userJson == null) return null;

    try {
      final Map<String, dynamic> userData = {};
      // Parse stored JSON string
      final parts = userJson.split(',');
      for (final part in parts) {
        final keyValue = part.split(':');
        if (keyValue.length == 2) {
          userData[keyValue[0].trim()] = keyValue[1].trim().replaceAll('"', '');
        }
      }
      return User.fromJson(userData);
    } catch (e) {
      return null;
    }
  }

  /// Get stored auth token
  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  /// Refresh user data from server
  Future<User> refreshUser() async {
    try {
      final response = await _apiClient.get('${ApiConfig.authEndpoint}/me');

      if (response.data == null) {
        throw ApiException('No data received from server');
      }

      final user = User.fromJson(response.data as Map<String, dynamic>);

      // Update stored user data
      await _secureStorage.write(
        key: _userKey,
        value: _userToString(user),
      );

      return user;
    } on DioException catch (e) {
      throw ApiException(
        e.message ?? 'Failed to refresh user',
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// Save authentication data to secure storage
  Future<void> _saveAuthData(AuthResponse authResponse) async {
    await _secureStorage.write(key: _tokenKey, value: authResponse.token);
    await _secureStorage.write(
      key: _userKey,
      value: _userToString(authResponse.user),
    );
  }

  /// Convert user to string for storage (simple format)
  String _userToString(User user) {
    return 'id:${user.id},email:${user.email},displayName:${user.displayName}';
  }
}
