import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/comment.dart';
import '../../../core/providers/data_providers.dart';

final taskCommentsProvider = FutureProvider.family<List<Comment>, String>((ref, taskId) {
  return ref.read(commentsRepositoryProvider).fetchComments(taskId);
});

final commentsControllerProvider =
    AsyncNotifierProvider.family<CommentsController, List<Comment>, String>(
  CommentsController.new,
);

class CommentsController extends FamilyAsyncNotifier<List<Comment>, String> {
  @override
  Future<List<Comment>> build(String taskId) async {
    return ref.read(commentsRepositoryProvider).fetchComments(taskId);
  }

  Future<void> addComment(String content) async {
    if (content.trim().isEmpty) return;

    final previous = state.valueOrNull ?? [];
    try {
      final newComment = await ref.read(commentsRepositoryProvider).addComment(
            taskId: arg,
            content: content.trim(),
          );
      state = AsyncData([...previous, newComment]);
    } catch (e, st) {
      state = AsyncError(e, st);
      state = AsyncData(previous);
    }
  }
}
