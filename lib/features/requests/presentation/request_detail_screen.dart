import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/request.dart';
import '../../../core/providers/data_providers.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/services/haptics_service.dart';
import '../../../design_system/widgets/app_snackbar.dart';
import '../../../design_system/widgets/loading_button.dart';
import '../../../theme/tokens.dart';

class RequestDetailScreen extends ConsumerWidget {
  const RequestDetailScreen({
    super.key,
    required this.requestId,
    this.request,
  });

  final String requestId;
  final Request? request;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(requestsProvider);
    final list = requestsAsync.valueOrNull;
    Request? resolved = request;
    if (resolved == null && list != null) {
      try {
        resolved = list.firstWhere((r) => r.id == requestId);
      } catch (_) {}
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Request Detail')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: resolved == null
            ? requestsAsync.when(
                data: (_) => const Text('Request not found'),
                loading: () => const Center(child: CircularProgressIndicator.adaptive()),
                error: (err, _) => Text('Failed to load: $err'),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    header: true,
                    child: Text(resolved.title, style: Theme.of(context).textTheme.titleLarge),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _StatusPill(
                    label: _statusLabel(resolved.status),
                    color: _statusColor(resolved.status),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Created: ${resolved.createdAt.toLocal().toString().split(' ').first}',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.neutral),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  FilledButton.icon(
                    onPressed: resolved.status == RequestStatus.pending
                        ? () async {
                            await HapticsService().trigger(HapticFeedbackType.success);
                            await AudioService().play(SoundEffect.success);
                            
                            if (context.mounted) {
                              AppSnackbar.show(
                                context,
                                message: 'Request accepted',
                                type: SnackbarType.success,
                              );
                              context.pop();
                            }
                          }
                        : null,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Accept'),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  OutlinedButton.icon(
                    onPressed: resolved.status == RequestStatus.pending
                        ? () async {
                            await HapticsService().trigger(HapticFeedbackType.error);
                            await AudioService().play(SoundEffect.error);
                            
                            if (context.mounted) {
                              AppSnackbar.show(
                                context,
                                message: 'Request declined',
                                type: SnackbarType.error,
                              );
                              context.pop();
                            }
                          }
                        : null,
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text('Decline'),
                  ),
                ],
              ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.neutral),
      ),
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
