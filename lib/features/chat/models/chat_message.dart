import 'package:flutter/foundation.dart';

/// Enhanced message model supporting text, voice, and file attachments
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.author,
    required this.timestamp,
    required this.isMe,
    required this.type,
    this.authorRole,
    this.text,
    this.voicePath,
    this.voiceDuration,
    this.filePath,
    this.fileName,
    this.fileSize,
    this.fileType,
    this.fileReferences = const [],
    this.viewedBy = const [],
    this.isPinned = false,
    this.pinnedBy,
    this.pinnedAt,
  });

  final String id;
  final String author;
  final UserRole? authorRole;
  final DateTime timestamp;
  final bool isMe;
  final MessageType type;
  
  // Viewer tracking - list of users who have viewed this message
  final List<MessageViewer> viewedBy;
  
  // Pin tracking - whether this message is pinned
  final bool isPinned;
  final String? pinnedBy;
  final DateTime? pinnedAt;

  // Text message fields
  final String? text;

  // Voice message fields
  final String? voicePath;
  final Duration? voiceDuration;

  // File attachment fields
  final String? filePath;
  final String? fileName;
  final int? fileSize;
  final FileAttachmentType? fileType;

  // File references (links to project files)
  final List<FileReference> fileReferences;

  ChatMessage copyWith({
    String? id,
    String? author,
    UserRole? authorRole,
    DateTime? timestamp,
    bool? isMe,
    MessageType? type,
    String? text,
    String? voicePath,
    Duration? voiceDuration,
    String? filePath,
    String? fileName,
    int? fileSize,
    FileAttachmentType? fileType,
    List<FileReference>? fileReferences,
    List<MessageViewer>? viewedBy,
    bool? isPinned,
    String? pinnedBy,
    DateTime? pinnedAt,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      author: author ?? this.author,
      authorRole: authorRole ?? this.authorRole,
      timestamp: timestamp ?? this.timestamp,
      isMe: isMe ?? this.isMe,
      type: type ?? this.type,
      text: text ?? this.text,
      voicePath: voicePath ?? this.voicePath,
      voiceDuration: voiceDuration ?? this.voiceDuration,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      fileType: fileType ?? this.fileType,
      fileReferences: fileReferences ?? this.fileReferences,
      viewedBy: viewedBy ?? this.viewedBy,
      isPinned: isPinned ?? this.isPinned,
      pinnedBy: pinnedBy ?? this.pinnedBy,
      pinnedAt: pinnedAt ?? this.pinnedAt,
    );
  }
}

/// User roles in a team
enum UserRole {
  projectManager,
  developer,
  designer,
  tester,
  analyst,
  teamLead,
  client,
  stakeholder,
}

/// Extension to get display information for roles
extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.projectManager:
        return 'Project Manager';
      case UserRole.developer:
        return 'Developer';
      case UserRole.designer:
        return 'Designer';
      case UserRole.tester:
        return 'Tester';
      case UserRole.analyst:
        return 'Analyst';
      case UserRole.teamLead:
        return 'Team Lead';
      case UserRole.client:
        return 'Client';
      case UserRole.stakeholder:
        return 'Stakeholder';
    }
  }

  String get shortName {
    switch (this) {
      case UserRole.projectManager:
        return 'PM';
      case UserRole.developer:
        return 'DEV';
      case UserRole.designer:
        return 'DES';
      case UserRole.tester:
        return 'QA';
      case UserRole.analyst:
        return 'BA';
      case UserRole.teamLead:
        return 'LEAD';
      case UserRole.client:
        return 'CLIENT';
      case UserRole.stakeholder:
        return 'STAKE';
    }
  }

  /// Color for role badge
  String get colorHex {
    switch (this) {
      case UserRole.projectManager:
        return '#8B5CF6'; // Purple
      case UserRole.developer:
        return '#3B82F6'; // Blue
      case UserRole.designer:
        return '#EC4899'; // Pink
      case UserRole.tester:
        return '#10B981'; // Green
      case UserRole.analyst:
        return '#F59E0B'; // Amber
      case UserRole.teamLead:
        return '#EF4444'; // Red
      case UserRole.client:
        return '#6366F1'; // Indigo
      case UserRole.stakeholder:
        return '#8B5CF6'; // Purple
    }
  }
}

enum MessageType {
  text,
  voice,
  file,
  textWithReferences, // Text message with file references
}

enum FileAttachmentType {
  image,
  document,
  video,
  audio,
  other,
}

/// Reference to a project file that can be clicked to navigate
class FileReference {
  const FileReference({
    required this.projectId,
    required this.fileName,
    required this.filePath,
    this.fileType,
  });

  final String projectId;
  final String fileName;
  final String filePath;
  final FileAttachmentType? fileType;

  /// Display text for the reference (e.g., "design.pdf", "screenshot.png")
  String get displayName => fileName;

  /// Icon based on file type
  String get icon {
    switch (fileType) {
      case FileAttachmentType.image:
        return '🖼️';
      case FileAttachmentType.document:
        return '📄';
      case FileAttachmentType.video:
        return '🎥';
      case FileAttachmentType.audio:
        return '🎵';
      default:
        return '📎';
    }
  }
}

/// Helper to detect and parse file references in text
class FileReferenceParser {
  FileReferenceParser._();

  /// Pattern: @file[projectId:path/to/file.ext]
  static final _fileRefPattern = RegExp(r'@file\[([^:]+):([^\]]+)\]');

  /// Parse text and extract file references
  static List<FileReference> parse(String text) {
    final matches = _fileRefPattern.allMatches(text);
    return matches.map((match) {
      final projectId = match.group(1)!;
      final filePath = match.group(2)!;
      final fileName = filePath.split('/').last;
      final fileType = _detectFileType(fileName);

      return FileReference(
        projectId: projectId,
        fileName: fileName,
        filePath: filePath,
        fileType: fileType,
      );
    }).toList();
  }

  /// Check if text contains file references
  static bool hasReferences(String text) {
    return _fileRefPattern.hasMatch(text);
  }

  /// Replace file references with placeholders for display
  static String replaceWithPlaceholders(String text) {
    return text.replaceAllMapped(_fileRefPattern, (match) {
      final filePath = match.group(2)!;
      final fileName = filePath.split('/').last;
      return '📎 $fileName';
    });
  }

  static FileAttachmentType _detectFileType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(ext)) {
      return FileAttachmentType.image;
    }
    if (['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(ext)) {
      return FileAttachmentType.video;
    }
    if (['mp3', 'wav', 'ogg', 'm4a', 'flac'].contains(ext)) {
      return FileAttachmentType.audio;
    }
    if (['pdf', 'doc', 'docx', 'txt', 'xls', 'xlsx', 'ppt', 'pptx'].contains(ext)) {
      return FileAttachmentType.document;
    }
    return FileAttachmentType.other;
  }
}

/// Helper to format file sizes
class FileSizeFormatter {
  FileSizeFormatter._();

  static String format(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

/// Represents a viewer of a message
class MessageViewer {
  const MessageViewer({
    required this.userId,
    required this.userName,
    required this.viewedAt,
  });

  final String userId;
  final String userName;
  final DateTime viewedAt;
}

/// Helper to format timestamps for display
class TimestampFormatter {
  TimestampFormatter._();

  /// Format timestamp relative to now (e.g., "Just now", "5m ago", "Yesterday", "Dec 1")
  static String formatRelative(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      // Format as date
      final month = _monthNames[timestamp.month - 1];
      return '$month ${timestamp.day}';
    }
  }

  /// Format timestamp as full date and time (e.g., "Dec 9, 2025 at 2:30 PM")
  static String formatFull(DateTime timestamp) {
    final month = _monthNames[timestamp.month - 1];
    final day = timestamp.day;
    final year = timestamp.year;
    final hour = timestamp.hour > 12 ? timestamp.hour - 12 : (timestamp.hour == 0 ? 12 : timestamp.hour);
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final period = timestamp.hour >= 12 ? 'PM' : 'AM';
    
    return '$month $day, $year at $hour:$minute $period';
  }

  /// Format time only (e.g., "2:30 PM")
  static String formatTime(DateTime timestamp) {
    final hour = timestamp.hour > 12 ? timestamp.hour - 12 : (timestamp.hour == 0 ? 12 : timestamp.hour);
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final period = timestamp.hour >= 12 ? 'PM' : 'AM';
    
    return '$hour:$minute $period';
  }

  /// Get phase of day based on time
  static String getPhaseOfDay(DateTime timestamp) {
    final hour = timestamp.hour;
    
    if (hour >= 5 && hour < 12) {
      return 'MORNING';
    } else if (hour >= 12 && hour < 17) {
      return 'AFTERNOON';
    } else if (hour >= 17 && hour < 21) {
      return 'EVENING';
    } else {
      return 'NIGHT';
    }
  }

  /// Format milestone separator (e.g., "MORNING | Dec 9, 2025 | 9:30 AM")
  static String formatMilestone(DateTime timestamp) {
    final phase = getPhaseOfDay(timestamp);
    final month = _monthNames[timestamp.month - 1];
    final day = timestamp.day;
    final year = timestamp.year;
    final hour = timestamp.hour > 12 ? timestamp.hour - 12 : (timestamp.hour == 0 ? 12 : timestamp.hour);
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final period = timestamp.hour >= 12 ? 'PM' : 'AM';
    
    return '$phase | $month $day, $year | $hour:$minute $period';
  }

  /// Check if a milestone should be shown between two messages
  /// Returns true if messages are in different phases or more than 30 minutes apart
  static bool shouldShowMilestone(DateTime? previousTimestamp, DateTime currentTimestamp) {
    if (previousTimestamp == null) return true;
    
    final difference = currentTimestamp.difference(previousTimestamp);
    
    // Show milestone if more than 30 minutes of inactivity
    if (difference.inMinutes >= 30) return true;
    
    // Show milestone if in different phases of day
    if (getPhaseOfDay(previousTimestamp) != getPhaseOfDay(currentTimestamp)) {
      return true;
    }
    
    return false;
  }

  static const _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
}
