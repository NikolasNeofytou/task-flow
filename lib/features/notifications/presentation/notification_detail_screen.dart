import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/app_notification.dart';
import '../../../core/providers/data_providers.dart';
import '../../../theme/tokens.dart';

class NotificationDetailScreen extends ConsumerWidget {
  const NotificationDetailScreen({
    super.key,
    required this.notificationId,
    this.notification,
  });

  final String notificationId;
  final AppNotification? notification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);
    final list = notificationsAsync.valueOrNull;
    AppNotification? resolved = notification;
    if (resolved == null && list != null) {
      try {
        resolved = list.firstWhere((n) => n.id == notificationId);
      } catch (_) {}
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Notification')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: resolved == null
            ? notificationsAsync.when(
                data: (_) => const Text('Notification not found'),
                loading: () => const Center(child: CircularProgressIndicator.adaptive()),
                error: (err, _) => Text('Failed to load: $err'),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: _typeColor(resolved.type).withOpacity(0.15),
                        child: Icon(_typeIcon(resolved.type), color: _typeColor(resolved.type)),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Semantics(
                          header: true,
                          child: Text(
                            resolved.title,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Received: ${resolved.createdAt.toLocal().toString().split(' ').first}',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.neutral),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  FilledButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Opening related \${_typeLabel(resolved?.type ?? NotificationType.taskAssignment)}...'),
                        ),
                      );
                      // In a real app, this would navigate to the related item
                      // context.go('/projects/${projectId}');
                    },
                    icon: const Icon(Icons.chevron_right),
                    label: const Text('Open related item'),
                  ),
                ],
              ),
      ),
    );
  }
}

String _typeLabel(NotificationType type) {
  switch (type) {
    case NotificationType.overdue:
      return 'overdue task';
    case NotificationType.comment:
      return 'comment';
    case NotificationType.accepted:
      return 'accepted request';
    case NotificationType.declined:
      return 'declined request';
    case NotificationType.completed:
      return 'completed task';
    case NotificationType.taskAssignment:
      return 'task assignment';
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
