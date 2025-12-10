import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/app_notification.dart';
import '../../../core/models/request.dart';
import '../../../core/providers/data_providers.dart';
import '../../../design_system/widgets/animated_card.dart';
import '../../../design_system/widgets/app_pill.dart';
import '../../../design_system/widgets/app_state.dart';
import '../../../design_system/widgets/shimmer_list.dart';
import '../../../theme/tokens.dart';
import '../../requests/application/requests_controller.dart';

class InboxScreen extends ConsumerWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncRequests = ref.watch(requestsControllerProvider);
    final asyncNotifications = ref.watch(notificationsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Inbox', style: Theme.of(context).textTheme.headlineLarge),
              ),
              FilledButton.icon(
                onPressed: () => _showRequestModal(
                  context,
                  onSubmit: (title, dueDate) =>
                      ref.read(requestsControllerProvider.notifier).send(title, dueDate: dueDate),
                ),
                icon: const Icon(Icons.send),
                label: const Text('New request'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Requests', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          _RequestsSection(asyncRequests: asyncRequests),
          const SizedBox(height: AppSpacing.xl),
          Text('Notifications', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          _NotificationsSection(asyncNotifications: asyncNotifications),
        ],
      ),
    );
  }
}

class _RequestsSection extends ConsumerWidget {
  const _RequestsSection({required this.asyncRequests});

  final AsyncValue<List<Request>> asyncRequests;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return asyncRequests.when(
      data: (items) {
        if (items.isEmpty) {
          return const AppStateView.empty(message: 'No requests yet.');
        }
        return Column(
          children: [
            for (final item in items) ...[
              _RequestCard(
                title: item.title,
                statusLabel: _statusLabel(item.status),
                statusColor: _statusColor(item.status),
                onAccept: () => ref.read(requestsControllerProvider.notifier).accept(item.id),
                onReject: () => ref.read(requestsControllerProvider.notifier).reject(item.id),
                onTap: () => context.go('/inbox/request/${item.id}', extra: item),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ],
        );
      },
      loading: () => const AppStateView.loading(shimmer: ShimmerList()),
      error: (err, _) => AppStateView.error(message: 'Failed to load requests: $err'),
    );
  }
}

class _NotificationsSection extends ConsumerWidget {
  const _NotificationsSection({required this.asyncNotifications});

  final AsyncValue<List<AppNotification>> asyncNotifications;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return asyncNotifications.when(
      data: (items) {
        if (items.isEmpty) {
          return const AppStateView.empty(message: 'No notifications yet.');
        }
        return Column(
          children: [
            for (final item in items) ...[
              _NotificationTile(
                title: item.title,
                icon: _typeIcon(item.type),
                color: _typeColor(item.type),
                onTap: () => context.go('/inbox/notification/${item.id}', extra: item),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ],
        );
      },
      loading: () => const AppStateView.loading(shimmer: ShimmerList()),
      error: (err, _) => AppStateView.error(message: 'Failed to load notifications: $err'),
    );
  }
}

class _RequestCard extends StatefulWidget {
  const _RequestCard({
    required this.title,
    required this.statusLabel,
    required this.statusColor,
    this.onAccept,
    this.onReject,
    this.onTap,
  });

  final String title;
  final String statusLabel;
  final Color statusColor;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onTap;

  @override
  State<_RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends State<_RequestCard> {
  bool _busy = false;

  Future<void> _handle(FutureOr<void> Function()? action) async {
    if (action == null) return;
    setState(() => _busy = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedCard(
      onTap: widget.onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.title, style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  children: [
                    AppPill(label: widget.statusLabel, color: widget.statusColor),
                    const AppPill(
                      label: 'Details',
                      color: AppColors.surface,
                      outlined: false,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Semantics(
            label: 'Accept request',
            button: true,
            child: IconButton(
              onPressed: _busy ? null : () => _handle(widget.onAccept),
              icon: const Icon(Icons.check_circle_outline),
              tooltip: 'Accept request',
              autofocus: false,
            ),
          ),
          Semantics(
            label: 'Reject request',
            button: true,
            child: IconButton(
              onPressed: _busy ? null : () => _handle(widget.onReject),
              icon: const Icon(Icons.cancel_outlined),
              tooltip: 'Reject request',
              autofocus: false,
            ),
          ),
          if (_busy)
            const Padding(
              padding: EdgeInsets.only(left: AppSpacing.xs),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.title,
    required this.icon,
    required this.color,
    this.onTap,
  });

  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedCard(
      onTap: onTap,
      child: Row(
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
    );
  }
}

Future<void> _showRequestModal(
  BuildContext context, {
  required Future<void> Function(String title, DateTime? dueDate) onSubmit,
}) async {
  final titleController = TextEditingController();
  DateTime? dueDate;
  bool sending = false;
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Send request'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Semantics(
                  label: 'Task or project title',
                  textField: true,
                  child: TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Task/Project'),
                    textInputAction: TextInputAction.done,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        dueDate == null
                            ? 'No due date'
                            : 'Due: ${dueDate!.toLocal().toString().split(' ').first}',
                      ),
                    ),
                    Semantics(
                      label: 'Pick due date',
                      button: true,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final now = DateTime.now();
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: now,
                            firstDate: now.subtract(const Duration(days: 1)),
                            lastDate: now.add(const Duration(days: 365)),
                          );
                          if (picked != null) {
                            setState(() {
                              dueDate = picked;
                            });
                          }
                        },
                        icon: const Icon(Icons.event),
                        label: const Text('Pick date'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: sending
                    ? null
                    : () async {
                        final title = titleController.text.trim();
                        if (title.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Title is required')),
                          );
                          return;
                        }
                        setState(() => sending = true);
                        await onSubmit(title, dueDate);
                        if (context.mounted) Navigator.of(ctx).pop(true);
                      },
                child: sending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Send'),
              ),
            ],
          );
        },
      );
    },
  );

  titleController.dispose();
  if (result == true && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Request sent')),
    );
  }
}

Color _statusColor(RequestStatus status) {
  switch (status) {
    case RequestStatus.pending:
      return AppColors.warning;
    case RequestStatus.accepted:
      return AppColors.success;
    case RequestStatus.rejected:
      return AppColors.error;
    case RequestStatus.sent:
      return AppColors.surface;
  }
}

String _statusLabel(RequestStatus status) {
  switch (status) {
    case RequestStatus.pending:
      return 'Pending';
    case RequestStatus.accepted:
      return 'Accepted';
    case RequestStatus.rejected:
      return 'Rejected';
    case RequestStatus.sent:
      return 'Sent';
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
