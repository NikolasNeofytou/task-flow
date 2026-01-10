import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'core/models/app_notification.dart';
import 'core/models/project.dart';
import 'core/models/request.dart';
import 'features/notifications/presentation/notifications_screen.dart';
import 'features/notifications/presentation/notification_detail_screen.dart';
import 'features/inbox/presentation/inbox_screen.dart';
import 'features/invite/presentation/invite_accept_screen.dart';
import 'features/profile/presentation/profile_screen.dart';
import 'features/profile/presentation/enhanced_profile_screen.dart';
import 'features/profile/presentation/edit_profile_screen.dart';
import 'features/profile/presentation/personal_qr_screen.dart';
import 'features/profile/presentation/scan_teammate_screen.dart';
import 'features/profile/presentation/team_screen.dart';
import 'features/profile/presentation/signup_screen.dart';
// import 'features/invite/presentation/unified_qr_screen.dart'; // TODO: Fix and re-enable
import 'features/projects/presentation/projects_screen.dart';
import 'features/projects/presentation/project_detail_screen.dart';
import 'features/requests/presentation/requests_screen.dart';
import 'features/requests/presentation/request_detail_screen.dart';
import 'features/schedule/presentation/calendar_screen.dart';
import 'features/settings/presentation/feedback_settings_screen.dart';
import 'features/settings/presentation/accessibility_settings_screen.dart';
import 'features/settings/presentation/theme_customization_screen.dart';
import 'features/settings/presentation/pattern_showcase_screen.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'features/shell/presentation/app_shell.dart';
import 'features/chat/presentation/chat_screen.dart';
import 'features/chat/presentation/enhanced_chat_screen.dart';
import '../../features/requests/presentation/requests_screen.dart';

GoRouter createRouter() {
  final rootNavigatorKey = GlobalKey<NavigatorState>();
  final shellNavigatorKey = GlobalKey<NavigatorState>();
  final storage = const FlutterSecureStorage();

  CustomTransitionPage<T> fadeSlide<T>(Widget child) {
    return CustomTransitionPage<T>(
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final offsetTween = Tween(begin: const Offset(0.0, 0.02), end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeOut));
        final fadeTween =
            Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeOut));
        return SlideTransition(
          position: animation.drive(offsetTween),
          child: FadeTransition(
            opacity: animation.drive(fadeTween),
            child: child,
          ),
        );
      },
    );
  }

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/calendar',
    redirect: (context, state) async {
      // Check if onboarding is complete
      final onboardingComplete = await storage.read(key: 'onboarding_complete');
      final isOnSignupPage = state.matchedLocation == '/signup';
      
      // If not completed and not on signup page, redirect to signup
      if (onboardingComplete != 'true' && !isOnSignupPage) {
        return '/signup';
      }
      
      // Allow navigation
      return null;
    },
    routes: [
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (context, state, child) =>
            AppShell(location: state.uri.toString(), child: child),
        routes: [
          GoRoute(
  path: '/requests',
  builder: (context, state) => const RequestsScreen(),
),
          GoRoute(
  path: '/calendar',
  pageBuilder: (context, state) =>
      const NoTransitionPage(child: CalendarScreen()),
),
          GoRoute(
            path: '/projects',
            name: 'projects',
            pageBuilder: (context, state) =>  const NoTransitionPage(child: ProjectsScreen()),
            routes: [
  GoRoute(
    path: ':id',
    name: 'project-detail',
    builder: (context, state) {
      final id = state.pathParameters['id']!;
      final project = state.extra;
      return ProjectDetailScreen(
        projectId: id,
        project: project is Project ? project : null,
      );
    },
  ),
],

          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            pageBuilder: (context, state) => const NoTransitionPage(child: EnhancedProfileScreen()),
            routes: [
              GoRoute(
                path: 'edit',
                name: 'profile-edit',
                builder: (context, state) => const EditProfileScreen(),
              ),
              GoRoute(
                path: 'team',
                name: 'team',
                builder: (context, state) => const TeamScreen(),
              ),
              GoRoute(
                path: 'qr',
                name: 'profile-qr',
                builder: (context, state) => const PersonalQRScreen(),
              ),
              GoRoute(
                path: 'scan',
                name: 'scan-teammate',
                builder: (context, state) => const ScanTeammateScreen(),
              ),
              // GoRoute(
              //   path: 'invite',
              //   name: 'unified-qr',
              //   builder: (context, state) => const UnifiedQRScreen(),
              // ),
            ],
          ),
          GoRoute(
            path: '/chat',
            name: 'chat',
            pageBuilder: (context, state) => 
            const NoTransitionPage(child: EnhancedChatScreen()),
            routes: [
              GoRoute(
                path: ':channelId',
                name: 'chat-thread',
                builder: (context, state) {
                  final channelId = state.pathParameters['channelId']!;
                  final label = state.extra is String ? state.extra as String : 'Chat';
                  return EnhancedChatThreadScreen(channelId: channelId, label: label);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/inbox',
            name: 'inbox',
            pageBuilder: (context, state) => fadeSlide(const InboxScreen()),
            routes: [
              GoRoute(
                path: 'request/:id',
                name: 'request-detail',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  final req = state.extra;
                  return RequestDetailScreen(
                    requestId: id,
                    request: req is Request ? req : null,
                  );
                },
              ),
              GoRoute(
                path: 'notification/:id',
                name: 'notification-detail',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  final notif = state.extra;
                  return NotificationDetailScreen(
                    notificationId: id,
                    notification: notif is AppNotification ? notif : null,
                  );
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/settings/feedback',
        name: 'feedback-settings',
        builder: (context, state) => const FeedbackSettingsScreen(),
      ),
      GoRoute(
        path: '/settings/accessibility',
        name: 'accessibility-settings',
        builder: (context, state) => const AccessibilitySettingsScreen(),
      ),
      GoRoute(
        path: '/settings/theme',
        name: 'theme-customization',
        builder: (context, state) => const ThemeCustomizationScreen(),
      ),
      GoRoute(
        path: '/settings/patterns',
        name: 'pattern-showcase',
        builder: (context, state) => const PatternShowcaseScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      // Deep link routes (outside shell)
      GoRoute(
        path: '/invite/accept',
        name: 'invite-accept',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>?;
          final projectId = args?['projectId'] as int?;
          final token = args?['token'] as String?;

          if (projectId == null || token == null) {
            return const Scaffold(
              body: Center(child: Text('Invalid invite link')),
            );
          }

          return InviteAcceptScreen(
            projectId: projectId,
            token: token,
          );
        },
      ),
    ],
  );
}
