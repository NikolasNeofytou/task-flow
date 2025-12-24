import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/models/project.dart';
import '../../../core/models/task_item.dart';
import '../../../core/providers/data_providers.dart';
import '../../../core/providers/qr_providers.dart';
import '../../../core/providers/feedback_providers.dart';
import '../../../core/services/feedback_service.dart';
import '../../../design_system/widgets/app_state.dart';
import '../../../design_system/widgets/shimmer_list.dart';
import '../../../design_system/widgets/animated_card.dart';
import '../../../design_system/widgets/app_snackbar.dart';
import '../../../theme/tokens.dart';
import '../../invite/presentation/qr_scan_screen.dart';

class ProjectDetailScreen extends ConsumerWidget {
  const ProjectDetailScreen({
    super.key,
    required this.projectId,
    this.project,
  });

  final String projectId;
  final Project? project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(projectTasksProvider(projectId));
    final projectsAsync = ref.watch(projectsProvider);
    final resolvedProject =
        project ?? projectsAsync.valueOrNull?.firstWhere((p) => p.id == projectId, orElse: () => const Project(id: '', name: 'Unknown', status: ProjectStatus.onTrack, tasks: 0));

    return Scaffold(
      appBar: AppBar(
        title: Text(resolvedProject?.name ?? 'Project'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.sm,
              children: [
                _StatusPill(
                  label: _statusLabel(resolvedProject?.status ?? ProjectStatus.onTrack),
                  color: _statusColor(resolvedProject?.status ?? ProjectStatus.onTrack),
                ),
                Text(
                  '${resolvedProject?.tasks ?? '-'} tasks',
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(color: AppColors.neutral),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Semantics(
                  label: 'Create new task',
                  button: true,
                  child: FilledButton.icon(
                    onPressed: () => context.go('/projects/$projectId/task/new'),
                    icon: const Icon(Icons.add),
                    label: const Text('New task'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Semantics(
                  label: 'Invite member',
                  button: true,
                  child: Consumer(
                    builder: (context, ref, _) {
                      return OutlinedButton.icon(
                        onPressed: () => _showInviteDialog(context, ref, projectId),
                        icon: const Icon(Icons.qr_code),
                        label: const Text('Invite'),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: tasksAsync.when(
                data: (tasks) {
                  if (tasks.isEmpty) {
                    return const AppStateView.empty(
                      message: 'No tasks for this project.',
                    );
                  }
                  return ListView.separated(
                    itemCount: tasks.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return _TaskTile(task: task, projectId: projectId);
                  },
                );
              },
                loading: () => const AppStateView.loading(
                  shimmer: ShimmerList(),
                ),
                error: (err, _) =>
                    AppStateView.error(message: 'Failed to load tasks: $err'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({required this.task, required this.projectId});

  final TaskItem task;
  final String projectId;

  @override
  Widget build(BuildContext context) {
    final color = _taskStatusColor(task.status);
    return AnimatedCard(
      onTap: () => context.go('/projects/$projectId/task/${task.id}', extra: task),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.title, style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Due: ${task.dueDate.toLocal().toString().split(' ').first}',
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(color: AppColors.neutral),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => context.go('/projects/${task.projectId}/task/${task.id}/edit', extra: task),
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit task',
          ),
          const Icon(Icons.chevron_right),
        ],
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
      ),
      child: Text(
        label,
        style: Theme.of(context)
            .textTheme
            .labelLarge
            ?.copyWith(color: AppColors.neutral),
      ),
    );
  }
}

String _statusLabel(ProjectStatus status) {
  switch (status) {
    case ProjectStatus.onTrack:
      return 'On track';
    case ProjectStatus.dueSoon:
      return 'Due soon';
    case ProjectStatus.blocked:
      return 'Blocked';
  }
}

Color _statusColor(ProjectStatus status) {
  switch (status) {
    case ProjectStatus.onTrack:
      return AppColors.success;
    case ProjectStatus.dueSoon:
      return AppColors.warning;
    case ProjectStatus.blocked:
      return AppColors.error;
  }
}

Color _taskStatusColor(TaskStatus status) {
  switch (status) {
    case TaskStatus.pending:
      return AppColors.warning;
    case TaskStatus.done:
      return AppColors.success;
    case TaskStatus.blocked:
      return AppColors.error;
  }
}

Future<void> _showInviteDialog(BuildContext context, WidgetRef ref, String projectId) async {
  final result = await showDialog<String>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: const Text('Invite member'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.qr_code),
              title: const Text('Show QR code'),
              subtitle: const Text('Let others scan to join'),
              onTap: () => Navigator.of(ctx).pop('qr_show'),
            ),
            ListTile(
              leading: const Icon(Icons.qr_code_scanner),
              title: const Text('Scan QR code'),
              subtitle: const Text('Join another project'),
              onTap: () => Navigator.of(ctx).pop('qr_scan'),
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Copy invite link'),
              subtitle: const Text('Share via message or email'),
              onTap: () => Navigator.of(ctx).pop('link'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      );
    },
  );

  if (result == null || !context.mounted) return;

  if (result == 'qr_show') {
    // Generate and show QR code
    await _showQRCode(context, ref, projectId);
  } else if (result == 'qr_scan') {
    // Open QR scanner
    await _scanQRCode(context, ref);
  } else if (result == 'link') {
    // Copy invite link
    final qrGenService = ref.read(qrGenerationServiceProvider);
    final projectIdInt = int.tryParse(projectId);
    if (projectIdInt == null) return;

    final inviteData = qrGenService.generateInvite(projectIdInt);
    await Clipboard.setData(ClipboardData(text: inviteData.url));

    await ref.read(feedbackServiceProvider).trigger(FeedbackType.success);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invite link copied to clipboard')),
    );
  }
}

Future<void> _showQRCode(BuildContext context, WidgetRef ref, String projectId) async {
  final qrGenService = ref.read(qrGenerationServiceProvider);
  final projectIdInt = int.tryParse(projectId);
  if (projectIdInt == null) return;

  final inviteData = qrGenService.generateInvite(projectIdInt);

  await ref.read(feedbackServiceProvider).trigger(FeedbackType.mediumImpact);

  if (!context.mounted) return;

  await showDialog(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: const Text('Project Invite QR Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // QR Code
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300, width: 2),
              ),
              child: QrImageView(
                data: inviteData.url,
                version: QrVersions.auto,
                size: 200,
                backgroundColor: Colors.white,
                errorCorrectionLevel: QrErrorCorrectLevel.H,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Others can scan this QR code to join the project',
              style: Theme.of(ctx).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Token: ${inviteData.token.substring(0, 8)}...',
              style: Theme.of(ctx).textTheme.labelSmall?.copyWith(
                    color: Colors.grey,
                    fontFamily: 'monospace',
                  ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: inviteData.url));
              await ref.read(feedbackServiceProvider).trigger(FeedbackType.lightTap);
              if (!ctx.mounted) return;
              AppSnackbar.show(
                ctx,
                message: 'Link copied to clipboard',
                type: SnackbarType.success,
              );
            },
            child: const Text('Copy Link'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(feedbackServiceProvider).trigger(FeedbackType.lightTap);
              Navigator.of(ctx).pop();
            },
            child: const Text('Done'),
          ),
        ],
      );
    },
  );
}

Future<void> _scanQRCode(BuildContext context, WidgetRef ref) async {
  // Check camera permission first
  final qrScanService = ref.read(qrScanServiceProvider);
  final hasPermission = await qrScanService.hasPermission();

  if (!hasPermission) {
    if (!context.mounted) return;
    final granted = await qrScanService.requestPermission();
    if (!granted) {
      if (!context.mounted) return;
      await ref.read(feedbackServiceProvider).trigger(FeedbackType.warning);
      AppSnackbar.show(
        context,
        message: 'Camera permission is required to scan QR codes',
        type: SnackbarType.warning,
      );
      return;
    }
  }

  if (!context.mounted) return;

  // Open QR scanner screen
  final inviteData = await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => const QRScanScreen(),
    ),
  );

  if (inviteData == null || !context.mounted) return;

  // TODO: Process invite (join project)
  // For now, just show success message
  await ref.read(feedbackServiceProvider).trigger(FeedbackType.success);

  if (!context.mounted) return;
  AppSnackbar.show(
    context,
    message: 'Scanned invite for project #${inviteData.projectId}',
    type: SnackbarType.success,
  );
}
