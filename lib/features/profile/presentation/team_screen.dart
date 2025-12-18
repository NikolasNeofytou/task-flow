import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../theme/tokens.dart';
import '../../../core/services/team_service.dart';
import '../../../core/services/haptics_service.dart';

/// Provider for team members list
final teamMembersProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final teamService = TeamService();
  return await teamService.getTeamMembers();
});

/// Screen displaying current user's team members
class TeamScreen extends ConsumerWidget {
  const TeamScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamAsync = ref.watch(teamMembersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Team'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Scan QR Code',
            onPressed: () => context.push('/profile/scan'),
          ),
        ],
      ),
      body: teamAsync.when(
        data: (team) {
          if (team.isEmpty) {
            return _EmptyTeamView(
              onScanQR: () => context.push('/profile/scan'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(teamMembersProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: team.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _TeamHeader(memberCount: team.length);
                }

                final member = team[index - 1];
                return _TeamMemberCard(
                  member: member,
                  onRemove: () => _showRemoveDialog(context, ref, member),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _ErrorView(
          error: error.toString(),
          onRetry: () => ref.invalidate(teamMembersProvider),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/profile/scan'),
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('Scan QR Code'),
      ),
    );
  }

  Future<void> _showRemoveDialog(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> member,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Team Member'),
        content: Text(
          'Are you sure you want to remove ${member['displayName']} from your team?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await HapticsService().trigger(HapticFeedbackType.light);
        
        final teamService = TeamService();
        await teamService.removeTeammate(member['id']);

        await HapticsService().trigger(HapticFeedbackType.success);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${member['displayName']} removed from team'),
              backgroundColor: Colors.orange,
            ),
          );

          // Refresh team list
          ref.invalidate(teamMembersProvider);
        }
      } catch (e) {
        await HapticsService().trigger(HapticFeedbackType.error);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to remove: ${e.toString().replaceAll('Exception: ', '')}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

class _TeamHeader extends StatelessWidget {
  const _TeamHeader({required this.memberCount});

  final int memberCount;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                  child: Icon(
                    Icons.groups,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$memberCount ${memberCount == 1 ? 'Member' : 'Members'}',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        'Connected via QR code',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.neutral,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TeamMemberCard extends StatelessWidget {
  const _TeamMemberCard({
    required this.member,
    required this.onRemove,
  });

  final Map<String, dynamic> member;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final displayName = member['displayName'] ?? 'Unknown User';
    final email = member['email'] ?? '';
    final status = member['status'] ?? 'offline';

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppSpacing.md),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text(
                displayName.substring(0, 2).toUpperCase(),
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: _getStatusColor(status),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
        title: Text(
          displayName,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(email),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(status),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () => _showOptionsMenu(context, onRemove),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'online':
        return Colors.green;
      case 'busy':
        return Colors.red;
      case 'away':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _showOptionsMenu(BuildContext context, VoidCallback onRemove) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.message),
              title: const Text('Send Message'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to chat
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_remove, color: Colors.red),
              title: const Text('Remove from Team', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                onRemove();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyTeamView extends StatelessWidget {
  const _EmptyTeamView({required this.onScanQR});

  final VoidCallback onScanQR;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.groups_outlined,
              size: 120,
              color: AppColors.neutral.withOpacity(0.3),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'No Team Members Yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Scan a teammate\'s QR code to add them to your team and collaborate together',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.neutral,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxl),
            FilledButton.icon(
              onPressed: onScanQR,
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Scan QR Code'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.md,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.error,
    required this.onRetry,
  });

  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red.withOpacity(0.5),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Failed to Load Team',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              error.replaceAll('Exception: ', ''),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.neutral,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
