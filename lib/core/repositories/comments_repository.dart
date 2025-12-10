import '../models/comment.dart';

abstract class CommentsRepository {
  Future<List<Comment>> fetchComments(String taskId);
  Future<Comment> addComment({
    required String taskId,
    required String content,
  });
}
