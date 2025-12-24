import '../models/request.dart';

class RequestDto {
  const RequestDto({
    required this.id,
    required this.title,
    required this.status,
    required this.createdAt,
    this.type,
    this.fromUserId,
    this.toUserId,
    this.taskId,
    this.projectId,
    this.dueDate,
  });

  final String id;
  final String title;
  final String status;
  final DateTime createdAt;
  final String? type;
  final String? fromUserId;
  final String? toUserId;
  final String? taskId;
  final String? projectId;
  final DateTime? dueDate;

  factory RequestDto.fromJson(Map<String, dynamic> json) {
    return RequestDto(
      id: json['id'] as String,
      title: json['title'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      type: json['type'] as String?,
      fromUserId: json['fromUserId'] as String?,
      toUserId: json['toUserId'] as String?,
      taskId: json['taskId'] as String?,
      projectId: json['projectId'] as String?,
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate'] as String) : null,
    );
  }

  Request toDomain() {
    return Request(
      id: id,
      title: title,
      status: _mapStatus(status),
      createdAt: createdAt,
      type: _mapType(type),
      fromUserId: fromUserId,
      toUserId: toUserId,
      taskId: taskId,
      projectId: projectId,
    );
  }

  RequestStatus _mapStatus(String value) {
    switch (value.toLowerCase()) {
      case 'accepted':
        return RequestStatus.accepted;
      case 'rejected':
        return RequestStatus.rejected;
      case 'sent':
        return RequestStatus.sent;
      case 'pending':
      default:
        return RequestStatus.pending;
    }
  }

  RequestType _mapType(String? value) {
    if (value == null) return RequestType.general;
    switch (value.toLowerCase()) {
      case 'taskassignment':
        return RequestType.taskAssignment;
      case 'tasktransfer':
        return RequestType.taskTransfer;
      case 'general':
      default:
        return RequestType.general;
    }
  }
}
