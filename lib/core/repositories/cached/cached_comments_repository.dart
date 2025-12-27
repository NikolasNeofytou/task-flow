import '../models/comment.dart';
import '../repositories/comments_repository.dart';
import '../storage/hive_storage_service.dart';

/// Offline-first repository for comments
class CachedCommentsRepository implements CommentsRepository {
  CachedCommentsRepository(this._remoteRepository);

  final CommentsRepository _remoteRepository;

  @override
  Future<List<Comment>> fetchComments(String taskId) async {
    try {
      final comments = await _remoteRepository.fetchComments(taskId);
      await HiveStorageService.saveComments(taskId, comments);
      return comments;
    } catch (e) {
      final cached = HiveStorageService.getComments(taskId);
      if (cached.isEmpty) rethrow;
      return cached;
    }
  }

  @override
  Future<Comment> addComment({
    required String taskId,
    required String content,
  }) async {
    final comment = await _remoteRepository.addComment(
      taskId: taskId,
      content: content,
    );
    // Update cache
    final existing = HiveStorageService.getComments(taskId);
    await HiveStorageService.saveComments(taskId, [...existing, comment]);
    return comment;
  }
}
