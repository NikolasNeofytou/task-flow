import 'package:flutter/material.dart';
import '../../../theme/tokens.dart';
import '../models/user_profile_model.dart';

/// Card showing profile completion status with tips
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

  int get _completedSteps {
    int count = 0;
    if (profile.photoPath != null) count++;
    if (profile.customStatusMessage != null && profile.customStatusMessage!.isNotEmpty) count++;
    if (profile.selectedBadgeId != null) count++;
    return count;
  }

  double get _completionPercentage => (_completedSteps / 3) * 100;

  bool get _isComplete => _completedSteps == 3;

  @override
  Widget build(BuildContext context) {
    if (_isComplete) {
      return Card(
        color: Colors.green.shade50,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profile Complete! 🎉',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                    ),
                    Text(
                      'Your profile looks amazing!',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.green.shade600,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      color: AppColors.primary.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Complete Your Profile',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_completionPercentage.toStringAsFixed(0)}% complete',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.neutral,
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                  child: Text(
                    '$_completedSteps/3',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            LinearProgressIndicator(
              value: _completedSteps / 3,
              backgroundColor: Colors.grey.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              minHeight: 6,
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
            const SizedBox(height: AppSpacing.lg),
            
            // Completion checklist
            if (profile.photoPath == null)
              _CompletionItem(
                icon: Icons.add_a_photo,
                title: 'Add a profile photo',
                onTap: onAddPhoto,
              ),
            if (profile.customStatusMessage == null || profile.customStatusMessage!.isEmpty)
              _CompletionItem(
                icon: Icons.edit_note,
                title: 'Set a custom status',
                onTap: onSetStatus,
              ),
            if (profile.selectedBadgeId == null)
              _CompletionItem(
                icon: Icons.emoji_events,
                title: 'Select a showcase badge',
                onTap: onSelectBadge,
              ),
          ],
        ),
      ),
    );
  }
}

class _CompletionItem extends StatelessWidget {
  const _CompletionItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
            const Icon(Icons.chevron_right, size: 20, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
