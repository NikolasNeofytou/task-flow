import 'package:flutter/material.dart';
import '../../../theme/tokens.dart';

/// Card displaying user statistics
class ProfileStatsCard extends StatelessWidget {
  const ProfileStatsCard({
    super.key,
    required this.tasksCompleted,
    required this.projectsCreated,
    required this.teamMembers,
    required this.badgesEarned,
  });

  final int tasksCompleted;
  final int projectsCreated;
  final int teamMembers;
  final int badgesEarned;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Statistics',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    icon: Icons.check_circle_outline,
                    label: 'Tasks',
                    value: tasksCompleted.toString(),
                    color: Colors.green,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    icon: Icons.folder_outlined,
                    label: 'Projects',
                    value: projectsCreated.toString(),
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    icon: Icons.people_outline,
                    label: 'Team',
                    value: teamMembers.toString(),
                    color: Colors.purple,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    icon: Icons.emoji_events_outlined,
                    label: 'Badges',
                    value: badgesEarned.toString(),
                    color: Colors.amber,
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

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.neutral,
                ),
          ),
        ],
      ),
    );
  }
}
