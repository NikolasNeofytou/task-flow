import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service for managing team members via QR code invites
class TeamService {
  final Dio _dio;
  final FlutterSecureStorage _storage;
  static const String _baseUrl = 'http://10.0.2.2:4000/api'; // Android emulator localhost (mock backend)

  TeamService({
    Dio? dio,
    FlutterSecureStorage? storage,
  })  : _dio = dio ?? Dio(),
        _storage = storage ?? const FlutterSecureStorage();

  /// Add a teammate via QR code scan
  Future<Map<String, dynamic>> addTeammate({
    required String userId,
    required String email,
    required String displayName,
  }) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await _dio.post(
        '$_baseUrl/users/team/add',
        data: {
          'userId': userId,
          'email': email,
          'displayName': displayName,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      return {
        'success': true,
        'message': response.data['message'] ?? 'Teammate added successfully',
        'user': response.data['user'],
        'teamSize': response.data['teamSize'],
      };
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('User not found. QR code may be invalid.');
      } else if (e.response?.statusCode == 400) {
        final message = e.response?.data['message'] ?? 'Invalid request';
        throw Exception(message);
      } else if (e.response?.statusCode == 401) {
        throw Exception('Authentication failed. Please log in again.');
      } else {
        throw Exception('Failed to add teammate: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Get user information by ID (for QR validation)
  Future<Map<String, dynamic>> getUserById(String userId) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await _dio.get(
        '$_baseUrl/users/$userId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('User not found');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Authentication failed');
      } else {
        throw Exception('Failed to fetch user: ${e.message}');
      }
    }
  }

  /// Get current user's team members
  Future<List<Map<String, dynamic>>> getTeamMembers() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await _dio.get(
        '$_baseUrl/users/me/team',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      final team = response.data['team'] as List;
      return team.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication failed');
      } else {
        throw Exception('Failed to fetch team: ${e.message}');
      }
    }
  }

  /// Remove a teammate
  Future<void> removeTeammate(String userId) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) {
        throw Exception('Not authenticated');
      }

      await _dio.delete(
        '$_baseUrl/users/me/team/$userId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('User not in team');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Authentication failed');
      } else {
        throw Exception('Failed to remove teammate: ${e.message}');
      }
    }
  }
}
