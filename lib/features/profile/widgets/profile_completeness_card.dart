import 'package:flutter/material.dart';

import '../../../theme/tokens.dart';
import '../models/user_profile_model.dart';

class ProfileCompletenessCard extends StatelessWidget {
  const ProfileCompletenessCard({
    super.key,
    required this.profile,
    required this.onAddPhoto,
    required this.onSetStatus,
    required this.onSelectBadge,
  });

  final UserProfile profile;
  final VoidCallback onAddPhoto;
  final VoidCallback onSetStatus;
  final VoidCallback onSelectBadge;

  bool get _hasPhoto => (profile.photoPath ?? '').trim().isNotEmpty;
  bool get _hasStatus =>
      (profile.customStatusMessage ?? '').trim().isNotEmpty ||
      profile.status != UserStatus.offline; 
  bool get _hasBadge => (profile.selectedBadgeId ?? '').trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final completed = (_hasPhoto ? 1 : 0) + (_hasStatus ? 1 : 0) + (_hasBadge ? 1 : 0);
    final total = 2;
    final progress = completed / total;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Complete Your Profile',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                  child: Text(
                    '$completed/$total',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${(progress * 100).round()}% complete',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: AppSpacing.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.pill),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            _RowItem(
              done: _hasStatus,
              icon: Icons.edit_note_outlined,
              title: 'Set a custom status',
              onTap: onSetStatus,
            ),
            const SizedBox(height: AppSpacing.sm),

            _RowItem(
              done: _hasBadge,
              icon: Icons.emoji_events_outlined,
              title: 'Select a showcase badge',
              onTap: onSelectBadge,
            ),
          ],
        ),
      ),
    );
  }
}

class _RowItem extends StatelessWidget {
  const _RowItem({
    required this.done,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final bool done;
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = done ? AppColors.success : Theme.of(context).colorScheme.primary;

    return InkWell(
      borderRadius: BorderRadius.circular(AppRadii.md),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(done ? Icons.check_circle : icon, color: color),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: done
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(context).colorScheme.primary,
                      fontWeight: done ? FontWeight.w600 : FontWeight.w500,
                    ),
              ),
            ),
            Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.outline),
          ],
        ),
      ),
    );
  }
}