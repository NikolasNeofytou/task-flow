import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/request.dart';
import '../application/requests_controller.dart';
import '../../../design_system/widgets/app_pill.dart';
import '../../../design_system/widgets/app_state.dart';
import '../../../design_system/widgets/shimmer_list.dart';
import '../../../design_system/widgets/animated_card.dart';
import '../../../design_system/widgets/empty_state.dart';
import '../../../design_system/widgets/app_snackbar.dart';
import '../../../theme/tokens.dart';
import '_action_background.dart';

class RequestsScreen extends ConsumerWidget {
  const RequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncRequests = ref.watch(requestsControllerProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text('Requests', style: Theme.of(context).textTheme.headlineLarge),
        ),
        const SizedBox(height: AppSpacing.lg),
        FilledButton.icon(
          onPressed: () => _showRequestModal(
            context,
            onSubmit: (title, dueDate) =>
                ref.read(requestsControllerProvider.notifier).send(title, dueDate: dueDate),
          ),
          icon: const Icon(Icons.send),
          label: const Text('Send request'),
        ),
        const SizedBox(height: AppSpacing.lg),
        Expanded(
          child: asyncRequests.when(
            data: (items) {
              if (items.isEmpty) {
                return EmptyState(
                  icon: Icons.inbox_outlined,
                  title: 'No requests',
                  subtitle: 'Send or receive task assignment requests',
                  actionLabel: 'Send Request',
                  onAction: () => _showRequestModal(
                    context,
                    onSubmit: (title, dueDate) => ref
                        .read(requestsControllerProvider.notifier)
                        .send(title, dueDate: dueDate),
                  ),
                );
              }
              return ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) {
                  final item = items[index];
                  final statusColor = _statusColor(item.status);
                  final snapshot = List<Request>.from(items);
                  return Dismissible(
                    key: ValueKey(item.id),
                    background: ActionBackground(
                      color: AppColors.success,
                      icon: Icons.check,
                      label: 'Accept',
                      alignment: Alignment.centerLeft,
                    ),
                    secondaryBackground: ActionBackground(
                      color: AppColors.error,
                      icon: Icons.close,
                      label: 'Reject',
                      alignment: Alignment.centerRight,
                    ),
                    confirmDismiss: (direction) async {
                      if (direction == DismissDirection.startToEnd) {
                        ref.read(requestsControllerProvider.notifier).accept(item.id);
                        _showUndo(
                          context,
                          message: 'Request accepted',
                          onUndo: () => ref
                              .read(requestsControllerProvider.notifier)
                              .restore(snapshot),
                        );
                      } else {
                        ref.read(requestsControllerProvider.notifier).reject(item.id);
                        _showUndo(
                          context,
                          message: 'Request rejected',
                          onUndo: () => ref
                              .read(requestsControllerProvider.notifier)
                              .restore(snapshot),
                        );
                      }
                      return false; // keep in list; state will refresh
                    },
                    child: _RequestCard(
                      title: item.title,
                      statusLabel: _statusLabel(item.status),
                      statusColor: statusColor,
                      onAccept: () => ref
                          .read(requestsControllerProvider.notifier)
                          .accept(item.id),
                      onReject: () => ref
                          .read(requestsControllerProvider.notifier)
                          .reject(item.id),
                      onTap: () =>
                          context.go('/requests/${item.id}', extra: item),
                    ),
                  );
                },
              );
            },
            loading: () => const AppStateView.loading(
              shimmer: ShimmerList(),
            ),
            error: (err, _) =>
                AppStateView.error(message: 'Failed to load requests: $err'),
          ),
        ),
      ],
    );
  }
}

void _showUndo(BuildContext context,
    {required String message, required VoidCallback onUndo}) {
  AppSnackbar.show(
    context,
    message: message,
    type: SnackbarType.success,
    actionLabel: 'Undo',
    onAction: onUndo,
  );
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
                          AppSnackbar.show(
                            context,
                            message: 'Title is required',
                            type: SnackbarType.warning,
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
    AppSnackbar.show(
      context,
      message: 'Request sent',
      type: SnackbarType.success,
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
