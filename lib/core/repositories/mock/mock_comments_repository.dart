import '../../data/mock_data.dart';
import '../../models/comment.dart';
import '../comments_repository.dart';

class MockCommentsRepository implements CommentsRepository {
  @override
  Future<List<Comment>> fetchComments(String taskId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return MockDataSource.fetchComments(taskId);
  }

  @override
  Future<Comment> addComment({
    required String taskId,
    required String content,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return MockDataSource.addComment(taskId: taskId, content: content);
  }
}
