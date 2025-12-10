import 'package:dio/dio.dart';

import '../../dto/request_dto.dart';
import '../../models/request.dart';
import '../../network/exceptions.dart';
import '../requests_repository.dart';

class RequestsRemoteRepository implements RequestsRepository {
  RequestsRemoteRepository(this._dio);

  final Dio _dio;

  @override
  Future<List<Request>> fetchRequests() async {
    try {
      final response = await _dio.get('/requests');
      final data = response.data as List<dynamic>;
      return data
          .map((json) => RequestDto.fromJson(json as Map<String, dynamic>).toDomain())
          .toList();
    } catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<void> acceptRequest(String id) async {
    try {
      await _dio.patch('/requests/$id', data: {'status': 'accepted'});
    } catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<void> rejectRequest(String id) async {
    try {
      await _dio.patch('/requests/$id', data: {'status': 'rejected'});
    } catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<Request> createRequest({required String title, DateTime? dueDate}) async {
    try {
      final response = await _dio.post('/requests', data: {
        'title': title,
        if (dueDate != null) 'dueDate': dueDate.toIso8601String(),
        'status': 'pending',
        'createdAt': DateTime.now().toIso8601String(),
      });
      return RequestDto.fromJson(response.data as Map<String, dynamic>).toDomain();
    } catch (e) {
      throw mapDioError(e);
    }
  }
}
