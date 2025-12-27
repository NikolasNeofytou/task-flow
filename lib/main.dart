import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_router.dart';
import 'core/providers/feedback_providers.dart';
import 'core/providers/deep_link_providers.dart';
import 'core/providers/push_notification_provider.dart';
import 'core/services/deep_link_service.dart';
import 'core/services/hive_service.dart';
import 'core/storage/hive_storage_service.dart';
import 'core/services/local_notification_service.dart';
import 'core/services/push_notification_service.dart';
import 'theme/fluent_theme.dart';
import 'theme/high_contrast_theme.dart';

// Background message handler for Firebase
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(message) async {
  await firebaseMessagingBackgroundHandler(message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for offline storage
  await HiveService.initialize();
  await HiveStorageService.initializeAdditional();

  // Initialize local notifications
  await LocalNotificationService.initialize();
  await LocalNotificationService.requestPermissions();

  runApp(const ProviderScope(child: TaskflowApp()));
}

class TaskflowApp extends ConsumerStatefulWidget {
  const TaskflowApp({super.key});

  @override
  ConsumerState<TaskflowApp> createState() => _TaskflowAppState();
}

class _TaskflowAppState extends ConsumerState<TaskflowApp> {
  late final GlobalKey<NavigatorState> _navigatorKey;

  @override
  void initState() {
    super.initState();
    _navigatorKey = GlobalKey<NavigatorState>();

    // Initialize services
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Initialize feedback services
      await ref.read(feedbackServiceProvider).initialize();
      ref.read(feedbackSettingsProvider);

      // Initialize push notifications
      final pushService = ref.read(pushNotificationServiceProvider);
      await pushService.initialize();

      // Initialize deep link handling
      final deepLinkService = ref.read(deepLinkServiceProvider);

      // Set up notification tap handler
      LocalNotificationService.setNotificationTapCallback((payload) {
        if (payload != null) {
          _handleNotificationPayload(payload);
        }
      });

      // Check for initial deep link (app opened via link)
      final initialUri = await deepLinkService.initialize();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }

      // Listen for deep links while app is running
      deepLinkService.startListening(_handleDeepLink);
    });
  }

  /// Handle incoming deep link
  void _handleDeepLink(Uri uri) {
    final deepLinkService = ref.read(deepLinkServiceProvider);
    final linkData = deepLinkService.parseDeepLink(uri);

    if (linkData == null) {
      debugPrint('❌ Failed to parse deep link: $uri');
      return;
    }

    debugPrint('✅ Handling deep link: $linkData');

    // Use router to navigate
    final context = _navigatorKey.currentContext;
    if (context == null || !context.mounted) {
      debugPrint('❌ No context available for navigation');
      return;
    }

    // Route based on link type
    switch (linkData.type) {
      case DeepLinkType.invite:
        // Navigate to invite handler screen
        // This screen will validate and process the invite
        Navigator.of(context).pushNamed(
          '/invite/accept',
          arguments: {
            'projectId': linkData.projectId,
            'token': linkData.token,
          },
        );
        break;

      case DeepLinkType.task:
        // Navigate to task detail
        Navigator.of(context).pushNamed(
          '/task/${linkData.taskId}',
        );
        break;

      case DeepLinkType.project:
        // Navigate to project detail
        Navigator.of(context).pushNamed(
          '/projects/${linkData.projectId}',
        );
        break;

      case DeepLinkType.notification:
        // Navigate to notification detail or relevant screen
        Navigator.of(context).pushNamed(
          '/notification/${linkData.notificationId}',
        );
        break;
    }
  }

  /// Handle notification payload (from local or push notifications)
  void _handleNotificationPayload(String payload) {
    debugPrint('Handling notification payload: $payload');

    // Parse payload format: "type:id"
    // Examples: "task:123", "project:456", "notification:789", "request:999"

    final parts = payload.split(':');
    if (parts.length != 2) {
      debugPrint('Invalid payload format: $payload');
      return;
    }

    final type = parts[0];
    final id = parts[1];

    // Convert to deep link format and handle
    Uri? uri;
    switch (type) {
      case 'task':
        uri = Uri.parse('taskflow://task/$id');
        break;
      case 'project':
        uri = Uri.parse('taskflow://project/$id');
        break;
      case 'notification':
        uri = Uri.parse('taskflow://notification/$id');
        break;
      case 'request':
        // Navigate to requests tab or request detail
        final context = _navigatorKey.currentContext;
        if (context != null && context.mounted) {
          Navigator.of(context).pushNamed('/requests');
        }
        return;
      default:
        debugPrint('Unknown payload type: $type');
        return;
    }

    _handleDeepLink(uri);
  }

  @override
  Widget build(BuildContext context) {
    final router = createRouter();

    // Check if high contrast mode is enabled
    return MediaQuery(
      data: MediaQuery.of(context),
      child: Builder(
        builder: (context) {
          final isHighContrast = MediaQuery.of(context).highContrast;

          return MaterialApp.router(
            title: 'Taskflow',
            debugShowCheckedModeBanner: false,
            theme: isHighContrast
                ? HighContrastTheme.buildLightTheme()
                : FluentTheme.light(),
            darkTheme: isHighContrast
                ? HighContrastTheme.buildDarkTheme()
                : FluentTheme.dark(),
            highContrastTheme: HighContrastTheme.buildLightTheme(),
            highContrastDarkTheme: HighContrastTheme.buildDarkTheme(),
            themeMode: ThemeMode.light,
            routerConfig: router,
            builder: (context, child) {
              // Store navigator key for deep link navigation
              return Navigator(
                key: _navigatorKey,
                onGenerateRoute: (_) => MaterialPageRoute(
                  builder: (_) => child!,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
