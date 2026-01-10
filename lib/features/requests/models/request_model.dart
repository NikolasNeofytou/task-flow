/// Request type enumeration
enum RequestType {
  taskAssignment,
  projectInvitation,
  collaboration,
  support,
}

/// Request status enumeration
enum RequestStatus {
  pending,
  accepted,
  declined,
  cancelled,
}

/// Request model for handling user requests
class RequestModel {
  const RequestModel({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    required this.status,
    required this.fromUserId,
    required this.toUserId,
    this.createdAt,
    this.updatedAt,
    this.expiresAt,
    this.metadata,
  });

  final String id;
  final String title;
  final String? description;
  final RequestType type;
  final RequestStatus status;
  final String fromUserId;
  final String toUserId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? expiresAt;
  final Map<String, dynamic>? metadata;

  factory RequestModel.fromJson(Map<String, dynamic> json) {
    return RequestModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      type: RequestType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => RequestType.collaboration,
      ),
      status: RequestStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => RequestStatus.pending,
      ),
      fromUserId: json['from_user_id'] as String,
      toUserId: json['to_user_id'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'status': status.name,
      'from_user_id': fromUserId,
      'to_user_id': toUserId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
      'metadata': metadata,
    };
  }
}
