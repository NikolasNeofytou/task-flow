import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/models/project.dart';
import '../../../core/providers/data_providers.dart';
import '../../../core/providers/qr_providers.dart';
import '../../../core/providers/feedback_providers.dart';
import '../../../core/services/feedback_service.dart';
import '../../../theme/tokens.dart';
import '../../invite/presentation/qr_scan_screen.dart';
import '../../../core/utils/project_status_utils.dart';

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
    final projectsAsync = ref.watch(projectsProvider);

    return projectsAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Failed to load project: $e')),
      ),
      data: (projects) {
        // resolve project είτε από το passed-in project είτε από τη λίστα
        final Project? resolvedProject = project ??
            projects.where((p) => p.id == projectId).cast<Project?>().firstWhere(
                  (p) => p != null,
                  orElse: () => null,
                );

        if (resolvedProject == null) {
          return const Scaffold(
            body: Center(child: Text('Project not found')),
          );
        }

        final p = resolvedProject;
        final s = effectiveProjectStatus(p);

        final deadlineText = (p.deadline == null)
            ? 'No deadline'
            : 'Deadline: ${p.deadline!.toLocal().toString().split(' ').first}';

        return Scaffold(
          appBar: AppBar(
            title: Text(p.name),
          ),
          body: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.sm,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _StatusPill(
                      label: projectStatusLabel(s),
                      color: projectStatusColor(s),
                    ),
                    Text(
                      deadlineText,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                Row(
                  children: [
                    FilledButton.icon(
                      onPressed: () => _showInviteDialog(context, ref, projectId),
                      icon: const Icon(Icons.qr_code),
                      label: const Text('Invite'),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    OutlinedButton.icon(
                      onPressed: () => context.go('/projects'),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Back to projects'),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xl),

                Text(
                  'Team',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: AppSpacing.md),

                if (p.teamMembers.isEmpty)
                  Text(
                    'No team members',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  )
                else
                  Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.sm,
                    children: [
                      for (final member in p.teamMembers)
                        Chip(
                          avatar: CircleAvatar(
                            child: Text(member.isNotEmpty ? member[0].toUpperCase() : '?'),
                          ),
                          label: Text(member),
                        ),
                    ],
                  ),

                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        );
      },
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
        border: Border.all(color: color.withOpacity(0.6)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
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
    await _showQRCode(context, ref, projectId);
  } else if (result == 'qr_scan') {
    await _scanQRCode(context, ref);
  } else if (result == 'link') {
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
            QrImageView(
              data: inviteData.url,
              version: QrVersions.auto,
              size: 220.0,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(inviteData.url),
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
}

Future<void> _scanQRCode(BuildContext context, WidgetRef ref) async {
  await ref.read(feedbackServiceProvider).trigger(FeedbackType.lightTap);
  if (!context.mounted) return;

  await Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => const QRScanScreen()),
  );
}