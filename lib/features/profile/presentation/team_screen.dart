import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/data_providers.dart';
import '../../../theme/tokens.dart';
import '../../invite/presentation/qr_scan_screen.dart';

class TeamScreen extends ConsumerWidget {
  const TeamScreen({super.key});

String _generateTeamInviteLink() {
  final token = DateTime.now().millisecondsSinceEpoch.toString();
  return 'taskflow://team-invite?owner=$kMeUserId&token=$token';
}

Future<void> _showAndCopyInviteLink(BuildContext context) async {
  final link = _generateTeamInviteLink();

  await Clipboard.setData(ClipboardData(text: link));
  if (!context.mounted) return;

  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Invite link'),
      content: SelectableText(link),
      actions: [
        TextButton(
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: link));
            if (ctx.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Invite link copied')),
              );
            }
          },
          child: const Text('Copy again'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

  Future<void> _joinFromLink(BuildContext context, WidgetRef ref) async {
    final ctrl = TextEditingController();

    final link = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Join via invite link'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            hintText: 'Paste invite link…',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(ctrl.text.trim()),
            child: const Text('Join'),
          ),
        ],
      ),
    );

    if (link == null || link.isEmpty || !context.mounted) return;

    await _applyInvite(ref, link);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invite processed')),
    );
  }

  Future<void> _scanQr(BuildContext context, WidgetRef ref) async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const QRScanScreen()),
    );

    if (result == null || result.trim().isEmpty) return;

    await _applyInvite(ref, result.trim());

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('QR processed')),
    );
  }

  Future<void> _applyInvite(WidgetRef ref, String raw) async {
    final notifier = ref.read(usersProvider.notifier);

    try {
      await (notifier as dynamic).addTeammateFromInvite(raw);
      return;
    } catch (_) {}
    try {
      await (notifier as dynamic).joinTeamFromLink(raw);
      return;
    } catch (_) {}
    try {
      await (notifier as dynamic).applyInvite(raw);
      return;
    } catch (_) {}

    final uri = Uri.tryParse(raw);
    final maybeUserId = uri?.queryParameters['userId'];

    if (maybeUserId != null && maybeUserId.isNotEmpty) {
      try {
        await (notifier as dynamic).addTeammate(maybeUserId);
        return;
      } catch (_) {}
      try {
        await (notifier as dynamic).addUserById(maybeUserId);
        return;
      } catch (_) {}
    }
  }

  Future<void> _openAddTeammateSheet(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;

        return SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg + bottomInset, 
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.qr_code_scanner),
                  title: const Text('Via QR code'),
                  subtitle: const Text('Scan someone’s QR to add them'),
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    await _scanQr(context, ref);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.link),
                  title: const Text('Via invite link'),
                  subtitle: const Text('Copy a link to invite someone'),
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    await _showAndCopyInviteLink(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.input),
                  title: const Text('Join via link (test)'),
                  subtitle: const Text('Paste an invite link to add teammate'),
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    await _joinFromLink(context, ref);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncUsers = ref.watch(usersProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('My Team', style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: AppSpacing.lg),

        Expanded(
          child: asyncUsers.when(
            loading: () => const Center(child: CircularProgressIndicator.adaptive()),
            error: (e, _) => Center(child: Text('Failed to load team: $e')),
            data: (users) {
              final others = users.where((u) => u.id != kMeUserId).toList()
                ..sort((a, b) => a.name.compareTo(b.name));

              return ListView(
                padding: EdgeInsets.zero,
                children: [
                  Card(
                    child: ListTile(
                      leading: const CircleAvatar(child: Text('Me')),
                      title: const Text('Me'),
                      subtitle: Text(
                        'You',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  for (final u in others)
                    Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(u.name.isNotEmpty ? u.name[0].toUpperCase() : '?'),
                        ),
                        title: Text(u.name),
                        subtitle: Text(
                          u.email,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 90), 
                ],
              );
            },
          ),
        ),

        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              bottom: AppSpacing.lg,
              top: AppSpacing.sm,
            ),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _openAddTeammateSheet(context, ref),
                icon: const Icon(Icons.person_add_alt_1),
                label: const Text('Add teammate'),
              ),
            ),
          ),
        ),
      ],
    );
  }
}