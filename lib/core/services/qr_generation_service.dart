import 'dart:math';

/// Service for generating QR code data for project invites
class QRGenerationService {
  static const String _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  static const int _tokenLength = 32;
  final Random _random = Random.secure();

  /// Generate a secure random token
  String generateToken() {
    return List.generate(
      _tokenLength,
      (index) => _chars[_random.nextInt(_chars.length)],
    ).join();
  }

  /// Generate invite URL for a project
  /// Format: taskflow://invite/{projectId}/{token}
  String generateInviteUrl(int projectId, String token) {
    return 'taskflow://invite/$projectId/$token';
  }

  /// Generate complete invite data (URL + token) for a project
  InviteQRData generateInvite(int projectId) {
    final token = generateToken();
    final url = generateInviteUrl(projectId, token);

    return InviteQRData(
      projectId: projectId,
      token: token,
      url: url,
      createdAt: DateTime.now(),
    );
  }

  /// Validate token format
  bool isValidToken(String token) {
    if (token.length != _tokenLength) return false;

    // Check all characters are alphanumeric
    return token.split('').every((char) => _chars.contains(char));
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

      return ParsedInvite(
        projectId: projectId,
        token: token,
      );
    } catch (e) {
      return null;
    }
  }
}

/// Generated QR code data for an invite
class InviteQRData {
  final int projectId;
  final String token;
  final String url;
  final DateTime createdAt;

  InviteQRData({
    required this.projectId,
    required this.token,
    required this.url,
    required this.createdAt,
  });

  @override
  String toString() => 'InviteQRData(projectId: $projectId, token: $token)';
}

/// Parsed data from an invite URL
class ParsedInvite {
  final int projectId;
  final String token;

  ParsedInvite({
    required this.projectId,
    required this.token,
  });

  @override
  String toString() => 'ParsedInvite(projectId: $projectId, token: $token)';
}
