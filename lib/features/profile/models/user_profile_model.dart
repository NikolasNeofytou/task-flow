import 'package:flutter/material.dart';

/// User online status (Discord-style)
enum UserStatus {
  online,
  away,
  doNotDisturb,
  offline,
}

/// User profile model
class UserProfile {
  final String id;
  final String displayName;
  final String email;
  final String? photoPath; // Local file path to profile picture
  final UserStatus status;
  final String? customStatusMessage;
  final List<String> unlockedBadgeIds;
  final String? selectedBadgeId; // Currently displayed badge
  final DateTime createdAt;
  final DateTime lastActiveAt;

  const UserProfile({
    required this.id,
    required this.displayName,
    required this.email,
    this.photoPath,
    this.status = UserStatus.online,
    this.customStatusMessage,
    this.unlockedBadgeIds = const [],
    this.selectedBadgeId,
    required this.createdAt,
    required this.lastActiveAt,
  });

  UserProfile copyWith({
    String? id,
    String? displayName,
    String? email,
    String? photoPath,
    UserStatus? status,
    String? customStatusMessage,
    List<String>? unlockedBadgeIds,
    String? selectedBadgeId,
    DateTime? createdAt,
    DateTime? lastActiveAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoPath: photoPath ?? this.photoPath,
      status: status ?? this.status,
      customStatusMessage: customStatusMessage ?? this.customStatusMessage,
      unlockedBadgeIds: unlockedBadgeIds ?? this.unlockedBadgeIds,
      selectedBadgeId: selectedBadgeId ?? this.selectedBadgeId,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }

  /// Get status color
  Color get statusColor {
    switch (status) {
      case UserStatus.online:
        return Colors.green;
      case UserStatus.away:
        return Colors.amber;
      case UserStatus.doNotDisturb:
        return Colors.red;
      case UserStatus.offline:
        return Colors.grey;
    }
  }

  /// Get status display name
  String get statusName {
    switch (status) {
      case UserStatus.online:
        return 'Online';
      case UserStatus.away:
        return 'Away';
      case UserStatus.doNotDisturb:
        return 'Do Not Disturb';
      case UserStatus.offline:
        return 'Offline';
    }
  }

  /// Get status icon
  IconData get statusIcon {
    switch (status) {
      case UserStatus.online:
        return Icons.check_circle;
      case UserStatus.away:
        return Icons.access_time;
      case UserStatus.doNotDisturb:
        return Icons.do_not_disturb;
      case UserStatus.offline:
        return Icons.circle_outlined;
    }
  }
}
