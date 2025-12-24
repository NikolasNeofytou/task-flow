import 'package:dio/dio.dart';

import '../../dto/comment_dto.dart';
import '../../models/comment.dart';
import '../../network/exceptions.dart';
import '../comments_repository.dart';

class CommentsRemoteRepository implements CommentsRepository {
  CommentsRemoteRepository(this._dio);

  final Dio _dio;

  @override
  Future<List<Comment>> fetchComments(String taskId) async {
    try {
      final response =
          await _dio.get('/comments', queryParameters: {'taskId': taskId});
      final data = response.data as List<dynamic>;
      return data
          .map((json) =>
              CommentDto.fromJson(json as Map<String, dynamic>).toDomain())
          .toList();
    } catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<Comment> addComment({
    required String taskId,
    required String content,
  }) async {
    try {
      final response = await _dio.post(
        '/comments',
        data: {'taskId': taskId, 'content': content},
      );
      return CommentDto.fromJson(response.data as Map<String, dynamic>)
          .toDomain();
    } catch (e) {
      throw mapDioError(e);
    }
  }
}
