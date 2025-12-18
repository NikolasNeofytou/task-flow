import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/tokens.dart';

/// Quick actions card for common profile tasks
class QuickActionsCard extends StatelessWidget {
  const QuickActionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                _QuickActionChip(
                  icon: Icons.add_task,
                  label: 'New Task',
                  color: Colors.blue,
                  onTap: () => context.push('/projects/new-task'),
                ),
                _QuickActionChip(
                  icon: Icons.create_new_folder,
                  label: 'New Project',
                  color: Colors.green,
                  onTap: () => context.push('/projects'),
                ),
                _QuickActionChip(
                  icon: Icons.qr_code_scanner,
                  label: 'QR Invite',
                  color: Colors.purple,
                  onTap: () => context.push('/profile/invite'),
                ),
                _QuickActionChip(
                  icon: Icons.calendar_today,
                  label: 'View Calendar',
                  color: Colors.orange,
                  onTap: () => context.go('/schedule'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
