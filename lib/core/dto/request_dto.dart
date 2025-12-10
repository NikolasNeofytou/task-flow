import '../models/request.dart';

class RequestDto {
  const RequestDto({
    required this.id,
    required this.title,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String status;
  final DateTime createdAt;

  factory RequestDto.fromJson(Map<String, dynamic> json) {
    return RequestDto(
      id: json['id'] as String,
      title: json['title'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Request toDomain() {
    return Request(
      id: id,
      title: title,
      status: _mapStatus(status),
      createdAt: createdAt,
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
}
