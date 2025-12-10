import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';

/// Service for handling deep links (taskflow:// URLs)
class DeepLinkService {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  /// Initialize deep link listening
  /// Returns the initial deep link if app was opened via link
  Future<Uri?> initialize() async {
    // Get initial link if app was opened via deep link
    try {
      final initialUri = await _appLinks.getInitialAppLink();
      if (initialUri != null) {
        debugPrint('🔗 Initial deep link: $initialUri');
      }
      return initialUri;
    } catch (e) {
      debugPrint('❌ Failed to get initial deep link: $e');
      return null;
    }
  }

  /// Start listening for deep links while app is running
  void startListening(Function(Uri) onLink) {
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) {
        debugPrint('🔗 Received deep link: $uri');
        onLink(uri);
      },
      onError: (err) {
        debugPrint('❌ Deep link error: $err');
      },
    );
  }

  /// Stop listening for deep links
  void stopListening() {
    _linkSubscription?.cancel();
    _linkSubscription = null;
  }

  /// Parse and validate a deep link URI
  /// Returns DeepLinkData if valid, null otherwise
  DeepLinkData? parseDeepLink(Uri uri) {
    debugPrint('🔍 Parsing deep link: $uri');

    // Check scheme
    if (uri.scheme != 'taskflow') {
      debugPrint('❌ Invalid scheme: ${uri.scheme}');
      return null;
    }

    // Parse based on host/path
    if (uri.host.isEmpty && uri.pathSegments.isEmpty) {
      return null;
    }

    // Handle taskflow://invite/{projectId}/{token}
    if (uri.pathSegments.isNotEmpty && uri.pathSegments[0] == 'invite') {
      return _parseInviteLink(uri);
    }

    // Handle taskflow://task/{taskId}
    if (uri.pathSegments.isNotEmpty && uri.pathSegments[0] == 'task') {
      return _parseTaskLink(uri);
    }

    // Handle taskflow://project/{projectId}
    if (uri.pathSegments.isNotEmpty && uri.pathSegments[0] == 'project') {
      return _parseProjectLink(uri);
    }

    // Handle taskflow://notification/{notificationId}
    if (uri.pathSegments.isNotEmpty && uri.pathSegments[0] == 'notification') {
      return _parseNotificationLink(uri);
    }

    debugPrint('❌ Unknown deep link pattern');
    return null;
  }

  /// Parse invite link: taskflow://invite/{projectId}/{token}
  DeepLinkData? _parseInviteLink(Uri uri) {
    if (uri.pathSegments.length < 3) {
      debugPrint('❌ Invalid invite link: missing segments');
      return null;
    }

    final projectIdStr = uri.pathSegments[1];
    final token = uri.pathSegments[2];

    final projectId = int.tryParse(projectIdStr);
    if (projectId == null) {
      debugPrint('❌ Invalid project ID: $projectIdStr');
      return null;
    }

    if (token.isEmpty || token.length != 32) {
      debugPrint('❌ Invalid token: $token');
      return null;
    }

    return DeepLinkData(
      type: DeepLinkType.invite,
      projectId: projectId,
      token: token,
      rawUri: uri,
    );
  }

  /// Parse task link: taskflow://task/{taskId}
  DeepLinkData? _parseTaskLink(Uri uri) {
    if (uri.pathSegments.length < 2) {
      debugPrint('❌ Invalid task link: missing taskId');
      return null;
    }

    final taskId = uri.pathSegments[1];
    if (taskId.isEmpty) {
      debugPrint('❌ Empty task ID');
      return null;
    }

    return DeepLinkData(
      type: DeepLinkType.task,
      taskId: taskId,
      rawUri: uri,
    );
  }

  /// Parse project link: taskflow://project/{projectId}
  DeepLinkData? _parseProjectLink(Uri uri) {
    if (uri.pathSegments.length < 2) {
      debugPrint('❌ Invalid project link: missing projectId');
      return null;
    }

    final projectIdStr = uri.pathSegments[1];
    final projectId = int.tryParse(projectIdStr);

    if (projectId == null) {
      debugPrint('❌ Invalid project ID: $projectIdStr');
      return null;
    }

    return DeepLinkData(
      type: DeepLinkType.project,
      projectId: projectId,
      rawUri: uri,
    );
  }

  /// Parse notification link: taskflow://notification/{notificationId}
  DeepLinkData? _parseNotificationLink(Uri uri) {
    if (uri.pathSegments.length < 2) {
      debugPrint('❌ Invalid notification link: missing notificationId');
      return null;
    }

    final notificationId = uri.pathSegments[1];
    if (notificationId.isEmpty) {
      debugPrint('❌ Empty notification ID');
      return null;
    }

    return DeepLinkData(
      type: DeepLinkType.notification,
      notificationId: notificationId,
      rawUri: uri,
    );
  }

  /// Dispose resources
  void dispose() {
    stopListening();
  }
}

/// Type of deep link
enum DeepLinkType {
  invite,        // taskflow://invite/{projectId}/{token}
  task,          // taskflow://task/{taskId}
  project,       // taskflow://project/{projectId}
  notification,  // taskflow://notification/{notificationId}
}

/// Parsed deep link data
class DeepLinkData {
  final DeepLinkType type;
  final Uri rawUri;

  // Invite-specific
  final int? projectId;
  final String? token;

  // Task-specific
  final String? taskId;

  // Notification-specific
  final String? notificationId;

  DeepLinkData({
    required this.type,
    required this.rawUri,
    this.projectId,
    this.token,
    this.taskId,
    this.notificationId,
  });

  @override
  String toString() {
    switch (type) {
      case DeepLinkType.invite:
        return 'DeepLinkData.invite(projectId: $projectId, token: $token)';
      case DeepLinkType.task:
        return 'DeepLinkData.task(taskId: $taskId)';
      case DeepLinkType.project:
        return 'DeepLinkData.project(projectId: $projectId)';
      case DeepLinkType.notification:
        return 'DeepLinkData.notification(notificationId: $notificationId)';
    }
  }
}
