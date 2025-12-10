enum RequestStatus { pending, accepted, rejected, sent }
enum RequestType { taskAssignment, taskTransfer, general }

class Request {
  const Request({
    required this.id,
    required this.title,
    required this.status,
    required this.createdAt,
    this.type = RequestType.general,
    this.fromUserId,
    this.toUserId,
    this.taskId,
    this.projectId,
  });

  final String id;
  final String title;
  final RequestStatus status;
  final DateTime createdAt;
  final RequestType type;
  final String? fromUserId; // Who sent the request
  final String? toUserId; // Who receives the request
  final String? taskId; // Related task if task assignment
  final String? projectId; // Related project
}
