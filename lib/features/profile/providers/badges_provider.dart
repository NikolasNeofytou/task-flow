import 'package:flutter/material.dart' hide Badge;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/data_providers.dart';
import '../models/badge_model.dart';
import '../../../core/models/project.dart';

class BadgeCollection {
  static List<AppBadge> base() {
    return [
      const AppBadge(
        id: 'first_steps',
        name: 'First Steps',
        description: 'Complete your first project',
        icon: Icons.flag_outlined,

        rarity: BadgeRarity.common,
        progress: 0,
        maxProgress: 1,
        isUnlocked: false,
      ),
      const AppBadge(
        id: 'the_organizer',
        name: 'The Organizer',
        description: 'Create 5 projects',
        icon: Icons.star_border,
        rarity: BadgeRarity.rare,
        progress: 0,
        maxProgress: 5,
        isUnlocked: false,
      ),
      const AppBadge(
        id: 'steady_worker',
        name: 'Steady Worker',
        description: 'Have 10 projects assigned to you',
        icon: Icons.trending_up,
        rarity: BadgeRarity.rare,
        progress: 0,
        maxProgress: 10,
        isUnlocked: false,
      ),
      const AppBadge(
        id: 'helper_hero',
        name: 'Helper Hero',
        description: 'Accept 5 requests',
        icon: Icons.volunteer_activism_outlined,
        rarity: BadgeRarity.legendary,
        progress: 0,
        maxProgress: 5,
        isUnlocked: false,
      ),
    ];
  }
}

final badgesProvider = Provider<List<AppBadge>>((ref) {
  final projectsAsync = ref.watch(projectsProvider);
  final reqsAsync = ref.watch(projectRequestsProvider);

  final projects = projectsAsync.value ?? const [];
  final reqs = reqsAsync.value ?? const [];

  final doneProjects = projects.where((p) => p.status == ProjectStatus.done).length;

  final createdByMeCount = ref.watch(userCreatedProjectIdsProvider).length;

final assignedToMeCount = projects.where((p) {
  final assigneeId = p.teamMembers.isNotEmpty ? p.teamMembers.first : null;
  return assigneeId == kMeUserId;
}).length;

  final acceptedIncoming = reqs
      .where((r) => r.toUserId == kMeUserId && r.status == ProjectRequestStatus.accepted)
      .length;

 
  final base = BadgeCollection.base();

  AppBadge setProgress(AppBadge b, int progress) {
    final p = progress.clamp(0, b.maxProgress);
    final unlocked = p >= b.maxProgress;
    return b.copyWith(
      progress: p,
      isUnlocked: unlocked,
    );
  }

  return base.map((b) {
    switch (b.id) {
      case 'first_steps':
        return setProgress(b, doneProjects >= 1 ? 1 : 0);

      case 'the_organizer':

        return setProgress(b, createdByMeCount >= 5 ? 5 :0);

      case 'steady_worker':
        return setProgress(b, assignedToMeCount >=10 ? 10 :0);

      case 'helper_hero':
        return setProgress(b, acceptedIncoming);

      default:
        return b;
    }
  }).toList();
});