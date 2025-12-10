import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../theme/tokens.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Semantics(
          header: true,
          child: Row(
            children: [
              const CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.primary,
                child: Text('DP', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(width: AppSpacing.lg),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Display Name',
                      style: Theme.of(context).textTheme.titleLarge),
                  Text('edit profile',
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge
                          ?.copyWith(color: AppColors.neutral)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          child: const Column(
            children: [
              _ProfileTile(
                icon: Icons.chat_outlined,
                title: 'Chat',
                subtitle: 'Team conversations',
                route: '/chat',
              ),
              _ProfileTile(
                icon: Icons.vibration,
                title: 'Haptics & Sound',
                subtitle: 'Feedback settings',
                route: '/settings/feedback',
              ),
              _ProfileTile(
                icon: Icons.accessibility_new,
                title: 'Accessibility',
                subtitle: 'High contrast, text size, color blind mode',
                route: '/settings/accessibility',
              ),
              _ProfileTile(
                icon: Icons.color_lens_outlined,
                title: 'Theme Customization',
                subtitle: 'Colors, gradients, and visual effects',
                route: '/settings/theme',
              ),
              _ProfileTile(
                icon: Icons.group_outlined,
                title: 'Group settings',
                subtitle: 'Manage members and invites',
              ),
              _ProfileTile(
                icon: Icons.lock_outline,
                title: 'Password',
                subtitle: 'Update credentials',
              ),
              _ProfileTile(
                icon: Icons.emoji_events_outlined,
                title: 'My Prizes',
                subtitle: 'Track unlocked badges',
              ),
              _ProfileTile(
                icon: Icons.logout,
                title: 'Logout',
                subtitle: 'Sign out safely',
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Semantics(
          header: true,
          child: Text('Badges', style: Theme.of(context).textTheme.titleLarge),
        ),
        const SizedBox(height: AppSpacing.md),
        const Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            _BadgeChip(label: 'Steady Worker', unlocked: true),
            _BadgeChip(label: 'The Organizer', unlocked: true),
            _BadgeChip(label: 'Helper Hero', unlocked: true),
            _BadgeChip(label: 'Task Legend', unlocked: false),
            _BadgeChip(label: 'Speed Worker', unlocked: false),
            _BadgeChip(label: 'Consistency King/Queen', unlocked: false),
          ],
        ),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.route,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? route;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$title. $subtitle',
      button: true,
      child: ListTile(
        leading: Icon(icon, color: AppColors.neutral),
        title: Text(title),
        subtitle: Text(
          subtitle,
          style: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(color: AppColors.neutral),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: route == null ? null : () => context.go(route!),
      ),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  const _BadgeChip({required this.label, required this.unlocked});

  final String label;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    final color = unlocked ? AppColors.success : AppColors.neutral.withOpacity(0.4);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: color),
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
