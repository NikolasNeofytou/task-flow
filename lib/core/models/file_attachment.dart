/// File attachment model for tasks
class FileAttachment {
  final String id;
  final String name;
  final String path;
  final String? url; // Remote URL if uploaded
  final int size; // Size in bytes
  final String type; // MIME type
  final DateTime uploadedAt;
  final String uploadedBy;

  const FileAttachment({
    required this.id,
    required this.name,
    required this.path,
    this.url,
    required this.size,
    required this.type,
    required this.uploadedAt,
    required this.uploadedBy,
  });

  String get extension {
    final parts = name.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : '';
  }

  bool get isImage {
    return ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(extension);
  }

  bool get isPDF {
    return extension == 'pdf';
  }

  bool get isDocument {
    return ['doc', 'docx', 'txt', 'rtf', 'odt'].contains(extension);
  }

  String get sizeFormatted {
    if (size < 1024) {
      return '$size B';
    } else if (size < 1024 * 1024) {
      return '${(size / 1024).toStringAsFixed(1)} KB';
    } else if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'path': path,
      'url': url,
      'size': size,
      'type': type,
      'uploadedAt': uploadedAt.toIso8601String(),
      'uploadedBy': uploadedBy,
    };
  }

  factory FileAttachment.fromJson(Map<String, dynamic> json) {
    return FileAttachment(
      id: json['id'] as String,
      name: json['name'] as String,
      path: json['path'] as String,
      url: json['url'] as String?,
      size: json['size'] as int,
      type: json['type'] as String,
      uploadedAt: DateTime.parse(json['uploadedAt'] as String),
      uploadedBy: json['uploadedBy'] as String,
    );
  }
}
