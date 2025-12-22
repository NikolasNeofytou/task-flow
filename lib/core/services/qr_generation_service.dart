import 'dart:math';
import 'package:uuid/uuid.dart';

/// Service for generating QR code data for project invites
class QRGenerationService {
  static const String _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  static const int _tokenLength = 32;
  final Random _random = Random.secure();
  final _uuid = const Uuid();

  // Storage for active invites (in production, this would be in a database)
  final Map<String, InviteQRData> _activeInvites = {};
  final Map<String, int> _tokenUsageCount = {};

  /// Generate a secure random token
  String generateToken() {
    return List.generate(
      _tokenLength,
      (index) => _chars[_random.nextInt(_chars.length)],
    ).join();
  }

  /// Generate a UUID-based token for enhanced uniqueness
  String generateUuidToken() {
    return _uuid.v4().replaceAll('-', '');
  }

  /// Generate invite URL for a project
  /// Format: taskflow://invite/{projectId}/{token}?expires={timestamp}
  String generateInviteUrl(
    int projectId,
    String token, {
    DateTime? expiresAt,
  }) {
    var url = 'taskflow://invite/$projectId/$token';
    if (expiresAt != null) {
      url += '?expires=${expiresAt.millisecondsSinceEpoch}';
    }
    return url;
  }

  /// Generate complete invite data (URL + token) for a project
  /// with optional expiration and single-use configuration
  InviteQRData generateInvite(
    int projectId, {
    Duration? expiresIn,
    bool isSingleUse = false,
    int? maxUses,
  }) {
    final token = generateUuidToken();
    final createdAt = DateTime.now();
    final expiresAt = expiresIn != null ? createdAt.add(expiresIn) : null;
    final url = generateInviteUrl(projectId, token, expiresAt: expiresAt);

    final inviteData = InviteQRData(
      projectId: projectId,
      token: token,
      url: url,
      createdAt: createdAt,
      expiresAt: expiresAt,
      isSingleUse: isSingleUse,
      maxUses: maxUses,
      isRevoked: false,
    );

    // Store the invite
    _activeInvites[token] = inviteData;
    _tokenUsageCount[token] = 0;

    return inviteData;
  }

  /// Validate token format
  bool isValidToken(String token) {
    if (token.isEmpty) return false;
    // Support both old format (32 chars) and new UUID format (32 chars without hyphens)
    if (token.length != _tokenLength && token.length != 32) return false;

    // Check all characters are alphanumeric or valid UUID chars
    return token.split('').every((char) => _chars.contains(char) || '0123456789abcdef'.contains(char.toLowerCase()));
  }

  /// Validate an invite token and check if it's still valid
  InviteValidationResult validateInvite(String token) {
    final invite = _activeInvites[token];

    if (invite == null) {
      return InviteValidationResult(
        isValid: false,
        reason: 'Token not found',
      );
    }

    if (invite.isRevoked) {
      return InviteValidationResult(
        isValid: false,
        reason: 'Invite has been revoked',
      );
    }

    if (invite.expiresAt != null && DateTime.now().isAfter(invite.expiresAt!)) {
      return InviteValidationResult(
        isValid: false,
        reason: 'Invite has expired',
      );
    }

    final usageCount = _tokenUsageCount[token] ?? 0;

    if (invite.isSingleUse && usageCount > 0) {
      return InviteValidationResult(
        isValid: false,
        reason: 'Invite has already been used',
      );
    }

    if (invite.maxUses != null && usageCount >= invite.maxUses!) {
      return InviteValidationResult(
        isValid: false,
        reason: 'Invite has reached maximum usage limit',
      );
    }

    return InviteValidationResult(
      isValid: true,
      invite: invite,
      usageCount: usageCount,
    );
  }

  /// Mark an invite as used
  void markInviteUsed(String token) {
    _tokenUsageCount[token] = (_tokenUsageCount[token] ?? 0) + 1;
  }

  /// Revoke an invite
  bool revokeInvite(String token) {
    final invite = _activeInvites[token];
    if (invite == null) return false;

    _activeInvites[token] = invite.copyWith(isRevoked: true);
    return true;
  }

  /// Get all active invites for a project
  List<InviteQRData> getProjectInvites(int projectId) {
    return _activeInvites.values
        .where((invite) => invite.projectId == projectId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Get invite by token
  InviteQRData? getInvite(String token) {
    return _activeInvites[token];
  }

  /// Clean up expired invites
  void cleanupExpiredInvites() {
    final now = DateTime.now();
    _activeInvites.removeWhere((token, invite) {
      if (invite.expiresAt != null && now.isAfter(invite.expiresAt!)) {
        _tokenUsageCount.remove(token);
        return true;
      }
      return false;
    });
  }

  /// Extract project ID and token from invite URL
  /// Returns null if invalid format
  ParsedInvite? parseInviteUrl(String url) {
    try {
      if (!url.startsWith('taskflow://invite/')) {
        return null;
      }

      final uri = Uri.parse(url);
      final segments = uri.pathSegments;

      if (segments.length < 3) return null;
      if (segments[0] != 'invite') return null;

      final projectId = int.tryParse(segments[1]);
      if (projectId == null) return null;

      final token = segments[2];
      if (!isValidToken(token)) return null;

      // Parse expiration if present
      DateTime? expiresAt;
      if (uri.queryParameters.containsKey('expires')) {
        final expiresMs = int.tryParse(uri.queryParameters['expires']!);
        if (expiresMs != null) {
          expiresAt = DateTime.fromMillisecondsSinceEpoch(expiresMs);
        }
      }

      return ParsedInvite(
        projectId: projectId,
        token: token,
        expiresAt: expiresAt,
      );
    } catch (e) {
      return null;
    }
  }
}

/// Validation result for invite tokens
class InviteValidationResult {
  final bool isValid;
  final String? reason;
  final InviteQRData? invite;
  final int? usageCount;

  InviteValidationResult({
    required this.isValid,
    this.reason,
    this.invite,
    this.usageCount,
  });
}

/// Generated QR code data for an invite
class InviteQRData {
  final int projectId;
  final String token;
  final String url;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final bool isSingleUse;
  final int? maxUses;
  final bool isRevoked;

  InviteQRData({
    required this.projectId,
    required this.token,
    required this.url,
    required this.createdAt,
    this.expiresAt,
    this.isSingleUse = false,
    this.maxUses,
    this.isRevoked = false,
  });

  /// Check if the invite is expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Check if the invite is still active
  bool get isActive => !isRevoked && !isExpired;

  /// Get expiration status text
  String get expirationStatus {
    if (isRevoked) return 'Revoked';
    if (isExpired) return 'Expired';
    if (expiresAt == null) return 'Never expires';

    final duration = expiresAt!.difference(DateTime.now());
    if (duration.inDays > 0) {
      return 'Expires in ${duration.inDays} day${duration.inDays == 1 ? '' : 's'}';
    } else if (duration.inHours > 0) {
      return 'Expires in ${duration.inHours} hour${duration.inHours == 1 ? '' : 's'}';
    } else if (duration.inMinutes > 0) {
      return 'Expires in ${duration.inMinutes} minute${duration.inMinutes == 1 ? '' : 's'}';
    } else {
      return 'Expires soon';
    }
  }

  InviteQRData copyWith({
    int? projectId,
    String? token,
    String? url,
    DateTime? createdAt,
    DateTime? expiresAt,
    bool? isSingleUse,
    int? maxUses,
    bool? isRevoked,
  }) {
    return InviteQRData(
      projectId: projectId ?? this.projectId,
      token: token ?? this.token,
      url: url ?? this.url,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isSingleUse: isSingleUse ?? this.isSingleUse,
      maxUses: maxUses ?? this.maxUses,
      isRevoked: isRevoked ?? this.isRevoked,
    );
  }

  @override
  String toString() => 'InviteQRData(projectId: $projectId, token: $token, active: $isActive)';
}

/// Parsed data from an invite URL
class ParsedInvite {
  final int projectId;
  final String token;
  final DateTime? expiresAt;

  ParsedInvite({
    required this.projectId,
    required this.token,
    this.expiresAt,
  });

  /// Check if the invite has expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  @override
  String toString() => 'ParsedInvite(projectId: $projectId, token: $token, expired: $isExpired)';
}
