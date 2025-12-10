import '../models/comment.dart';

class CommentDto {
  const CommentDto({
    required this.id,
    required this.taskId,
    required this.authorName,
    required this.content,
    required this.createdAt,
  });

  final String id;
  final String taskId;
  final String authorName;
  final String content;
  final DateTime createdAt;

  factory CommentDto.fromJson(Map<String, dynamic> json) {
    return CommentDto(
      id: json['id'] as String,
      taskId: json['taskId'] as String,
      authorName: json['authorName'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taskId': taskId,
      'authorName': authorName,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Comment toDomain() {
    return Comment(
      id: id,
      taskId: taskId,
      authorName: authorName,
      content: content,
      createdAt: createdAt,
    );
  }
}
