import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/app_notification.dart';
import '../../../core/providers/data_providers.dart';
import '../../../design_system/widgets/app_state.dart';
import '../../../design_system/widgets/shimmer_list.dart';
import '../../../design_system/widgets/animated_card.dart';
import '../../../theme/tokens.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncNotifications = ref.watch(notificationsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text('Notifications', style: Theme.of(context).textTheme.headlineLarge),
        ),
        const SizedBox(height: AppSpacing.lg),
        Expanded(
          child: asyncNotifications.when(
            data: (items) {
              if (items.isEmpty) {
                return const AppStateView.empty(message: 'No notifications yet.');
              }
              return ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final item = items[index];
                  final color = _typeColor(item.type);
                  final icon = _typeIcon(item.type);
                  return _NotificationTile(
                    notification: item,
                    title: item.title,
                    icon: icon,
                    color: color,
                    onTap: () => context.go('/notifications/${item.id}', extra: item),
                  );
                },
              );
            },
            loading: () => const AppStateView.loading(
              shimmer: ShimmerList(),
            ),
            error: (err, _) =>
                AppStateView.error(message: 'Failed to load notifications: $err'),
          ),
        ),
      ],
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.title,
    required this.icon,
    required this.color,
    this.onTap,
  });

  final AppNotification notification;
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isTaskAssignment = notification.type == NotificationType.taskAssignment && notification.actionable;
    
    return AnimatedCard(
      onTap: isTaskAssignment ? null : onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.15),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              if (!isTaskAssignment)
                Semantics(
                  label: 'View notification',
                  button: true,
                  child: IconButton(
                    onPressed: onTap,
                    icon: const Icon(Icons.chevron_right),
                    tooltip: 'View',
                  ),
                ),
            ],
          ),
          if (isTaskAssignment) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Reject action
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Task assignment rejected')),
                      );
                    },
                    icon: const Icon(Icons.close),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: BorderSide(color: AppColors.error),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      // Accept action
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Task assignment accepted!')),
                      );
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Accept'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

IconData _typeIcon(NotificationType type) {
  switch (type) {
    case NotificationType.overdue:
      return Icons.warning_amber_rounded;
    case NotificationType.comment:
      return Icons.chat_bubble_outline;
    case NotificationType.accepted:
      return Icons.check_circle_outline;
    case NotificationType.declined:
      return Icons.cancel_outlined;
    case NotificationType.completed:
      return Icons.verified_outlined;
    case NotificationType.taskAssignment:
      return Icons.assignment_ind;
  }
}

Color _typeColor(NotificationType type) {
  switch (type) {
    case NotificationType.overdue:
      return AppColors.warning;
    case NotificationType.comment:
      return AppColors.info;
    case NotificationType.accepted:
      return AppColors.success;
    case NotificationType.declined:
      return AppColors.error;
    case NotificationType.completed:
      return AppColors.primary;
    case NotificationType.taskAssignment:
      return AppColors.info;
  }
}
