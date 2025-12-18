import 'dart:io';
import 'package:flutter/material.dart' hide Badge;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../theme/tokens.dart';
import '../models/badge_model.dart';
import '../models/user_profile_model.dart';
import '../providers/profile_provider.dart';
import '../widgets/profile_stats_card.dart';
import '../widgets/profile_completeness_card.dart';
import '../widgets/quick_actions_card.dart';

class EnhancedProfileScreen extends ConsumerWidget {
  const EnhancedProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final badges = ref.watch(badgesProvider);

    if (profile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        // Profile header with photo
        _ProfileHeader(profile: profile),
        const SizedBox(height: AppSpacing.xl),

        // Profile completeness card
        ProfileCompletenessCard(
          profile: profile,
          onAddPhoto: () => ref.read(userProfileProvider.notifier).updateProfilePicture(),
          onSetStatus: () => _showStatusPicker(context, ref, profile.status),
          onSelectBadge: () => _showBadgesSheet(context, ref, badges),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Statistics card
        ProfileStatsCard(
          tasksCompleted: 12,
          projectsCreated: 3,
          teamMembers: 8,
          badgesEarned: badges.where((b) => b.isUnlocked).length,
        ),
        const SizedBox(height: AppSpacing.lg),

        // Quick actions
        const QuickActionsCard(),
        const SizedBox(height: AppSpacing.lg),

        // Status section
        _StatusSection(
          profile: profile,
          onStatusChange: () => _showStatusPicker(context, ref, profile.status),
        ),
        const SizedBox(height: AppSpacing.xl),

        // Selected badge showcase
        if (profile.selectedBadgeId != null)
          _SelectedBadgeShowcase(
            badge: badges.firstWhere((b) => b.id == profile.selectedBadgeId),
          ),
        
        const SizedBox(height: AppSpacing.lg),

        // QR Code & Team actions
        Card(
          child: Column(
            children: [
              _ProfileTile(
                icon: Icons.groups,
                title: 'My Team',
                subtitle: 'View team members',
                onTap: () => context.push('/profile/team'),
              ),
              _ProfileTile(
                icon: Icons.qr_code,
                title: 'My QR Code',
                subtitle: 'Share your profile',
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                  child: Text(
                    'NEW',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                onTap: () => context.push('/profile/qr'),
              ),
              _ProfileTile(
                icon: Icons.qr_code_scanner,
                title: 'Scan Teammate',
                subtitle: 'Add team members via QR',
                onTap: () => context.push('/profile/scan'),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Quick actions
        Card(
          child: Column(
            children: [
              _ProfileTile(
                icon: Icons.edit_outlined,
                title: 'Edit Profile',
                subtitle: 'Update your information',
                onTap: () => context.push('/profile/edit'),
              ),
              _ProfileTile(
                icon: Icons.emoji_events_outlined,
                title: 'My Badges',
                subtitle: '${badges.where((b) => b.isUnlocked).length}/${badges.length} unlocked',
                onTap: () => _showBadgesSheet(context, ref, badges),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Settings tiles
        Card(
          child: Column(
            children: [
              _ProfileTile(
                icon: Icons.chat_outlined,
                title: 'Chat',
                subtitle: 'Team conversations',
                onTap: () => context.go('/chat'),
              ),
              _ProfileTile(
                icon: Icons.vibration,
                title: 'Haptics & Sound',
                subtitle: 'Feedback settings',
                onTap: () => context.go('/settings/feedback'),
              ),
              _ProfileTile(
                icon: Icons.accessibility_new,
                title: 'Accessibility',
                subtitle: 'High contrast, text size',
                onTap: () => context.go('/settings/accessibility'),
              ),
              _ProfileTile(
                icon: Icons.color_lens_outlined,
                title: 'Theme',
                subtitle: 'Colors and visual effects',
                onTap: () => context.go('/settings/theme'),
              ),
              _ProfileTile(
                icon: Icons.lightbulb_outline,
                title: 'Design Patterns',
                subtitle: '11 HCI patterns demonstrated',
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                  child: Text(
                    'NEW',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade700,
                    ),
                  ),
                ),
                onTap: () => context.go('/settings/patterns'),
              ),
              _ProfileTile(
                icon: Icons.logout,
                title: 'Logout',
                subtitle: 'Sign out safely',
                onTap: () => _showLogoutDialog(context, ref),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showBadgesSheet(BuildContext context, WidgetRef ref, List<AppBadge> badgesList) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BadgesSheet(badges: badgesList),
    );
  }

  void _showStatusPicker(BuildContext context, WidgetRef ref, UserStatus currentStatus) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _StatusPickerSheet(currentStatus: currentStatus),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              await ref.read(userProfileProvider.notifier).logout();
              if (context.mounted) {
                context.go('/signup');
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends ConsumerWidget {
  const _ProfileHeader({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        // Profile picture with edit button
        Stack(
          children: [
            GestureDetector(
              onTap: () => ref.read(userProfileProvider.notifier).updateProfilePicture(),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.1),
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: profile.photoPath != null
                    ? ClipOval(
                        child: Image.file(
                          File(profile.photoPath!),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _defaultAvatar(),
                        ),
                      )
                    : _defaultAvatar(),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                padding: const EdgeInsets.all(4),
                child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(width: AppSpacing.lg),
        
        // Name and email
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile.displayName,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                profile.email,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.neutral,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _defaultAvatar() {
    return Center(
      child: Text(
        profile.displayName.substring(0, 2).toUpperCase(),
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _StatusSection extends ConsumerWidget {
  const _StatusSection({
    required this.profile,
    required this.onStatusChange,
  });

  final UserProfile profile;
  final VoidCallback onStatusChange;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(profile.statusIcon, size: 20, color: profile.statusColor),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  profile.statusName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: onStatusChange,
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Change'),
                ),
              ],
            ),
            if (profile.customStatusMessage != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                profile.customStatusMessage!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.neutral,
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusPickerSheet extends ConsumerStatefulWidget {
  const _StatusPickerSheet({required this.currentStatus});

  final UserStatus currentStatus;

  @override
  ConsumerState<_StatusPickerSheet> createState() => _StatusPickerSheetState();
}

class _StatusPickerSheetState extends ConsumerState<_StatusPickerSheet> {
  late UserStatus _selectedStatus;
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.currentStatus;
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Set Status',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppSpacing.lg),
          
          // Status options
          ...UserStatus.values.map((status) {
            final profile = UserProfile(
              id: '',
              email: '',
              displayName: '',
              status: status,
              createdAt: DateTime.now(),
              lastActiveAt: DateTime.now(),
            );
            
            return RadioListTile<UserStatus>(
              value: status,
              groupValue: _selectedStatus,
              onChanged: (value) {
                setState(() => _selectedStatus = value!);
              },
              title: Text(profile.statusName),
              secondary: Icon(profile.statusIcon, color: profile.statusColor),
            );
          }),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Custom message
          TextField(
            controller: _messageController,
            decoration: InputDecoration(
              labelText: 'Custom Status Message (optional)',
              hintText: 'What are you up to?',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
            ),
            maxLength: 100,
          ),
          const SizedBox(height: AppSpacing.lg),
          
          // Save button
          FilledButton(
            onPressed: () async {
              await ref.read(userProfileProvider.notifier).updateStatus(
                    _selectedStatus,
                    customMessage: _messageController.text.trim().isEmpty
                        ? null
                        : _messageController.text.trim(),
                  );
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('Save Status'),
          ),
        ],
      ),
    );
  }
}

class _SelectedBadgeShowcase extends StatelessWidget {
  const _SelectedBadgeShowcase({required this.badge});

  final AppBadge badge;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: badge.rarityColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: badge.rarityColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              child: Icon(badge.icon, size: 32, color: badge.rarityColor),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        badge.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: badge.rarityColor,
                          borderRadius: BorderRadius.circular(AppRadii.pill),
                        ),
                        child: Text(
                          badge.rarityName.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    badge.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.neutral,
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
}

class _BadgesSheet extends ConsumerWidget {
  const _BadgesSheet({required this.badges});

  final List<AppBadge> badges;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final unlockedBadges = badges.where((b) => b.isUnlocked).toList();
    final lockedBadges = badges.where((b) => !b.isUnlocked).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadii.xxl)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Row(
              children: [
                Text(
                  'Badge Collection',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                Text(
                  '${unlockedBadges.length}/${badges.length}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          
          // Badges grid
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              children: [
                if (unlockedBadges.isNotEmpty) ...[
                  Text(
                    'Unlocked Badges',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ...unlockedBadges.map((badge) => _BadgeTile(
                        badge: badge,
                        isSelected: badge.id == profile?.selectedBadgeId,
                        onTap: () async {
                          final newSelection = badge.id == profile?.selectedBadgeId ? null : badge.id;
                          await ref.read(userProfileProvider.notifier).selectBadge(newSelection);
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                      )),
                  const SizedBox(height: AppSpacing.xl),
                ],
                
                if (lockedBadges.isNotEmpty) ...[
                  Text(
                    'Locked Badges',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.neutral,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ...lockedBadges.map((badge) => _BadgeTile(
                        badge: badge,
                        isSelected: false,
                        onTap: null,
                      )),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({
    required this.badge,
    required this.isSelected,
    this.onTap,
  });

  final AppBadge badge;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isLocked = !badge.isUnlocked;
    
    return Card(
      color: isSelected ? badge.rarityColor.withOpacity(0.1) : null,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: isLocked
                ? Colors.grey.withOpacity(0.1)
                : badge.rarityColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(AppRadii.sm),
          ),
          child: Icon(
            badge.icon,
            color: isLocked ? Colors.grey : badge.rarityColor,
          ),
        ),
        title: Row(
          children: [
            Text(
              badge.name,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isLocked ? Colors.grey : null,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: isLocked ? Colors.grey : badge.rarityColor,
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
              child: Text(
                badge.rarityName.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              badge.description,
              style: TextStyle(color: isLocked ? Colors.grey : AppColors.neutral),
            ),
            if (!isLocked && badge.progressPercentage < 1.0) ...[
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: badge.progressPercentage,
                backgroundColor: Colors.grey.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation(badge.rarityColor),
              ),
              const SizedBox(height: 2),
              Text(
                '${badge.progress}/${badge.maxProgress}',
                style: const TextStyle(fontSize: 10),
              ),
            ],
          ],
        ),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: AppColors.primary)
            : (isLocked ? const Icon(Icons.lock, color: Colors.grey) : null),
        onTap: onTap,
        enabled: !isLocked,
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.neutral),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.neutral,
            ),
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
