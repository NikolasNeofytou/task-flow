import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/project.dart';
import '../../../core/models/request.dart';
import '../../../core/providers/data_providers.dart';
import '../models/badge_model.dart';

class _BadgeStats {
  const _BadgeStats({
    required this.totalProjects,
    required this.doneProjects,
    required this.acceptedIncomingRequests,
  });

  final int totalProjects;
  final int doneProjects;
  final int acceptedIncomingRequests;
}

final _badgeStatsProvider = Provider<_BadgeStats>((ref) {
  final projects = ref.watch(projectsProvider).valueOrNull ?? const <Project>[];
  final reqs = ref.watch(projectRequestsProvider).valueOrNull ?? const <ProjectRequest>[];

  final doneProjects = projects.where((p) => p.status == ProjectStatus.done).length;
  final acceptedIncomingRequests = reqs
      .where((r) => r.toUserId == kMeUserId && r.status == ProjectRequestStatus.accepted)
      .length;

  return _BadgeStats(
    totalProjects: projects.length,
    doneProjects: doneProjects,
    acceptedIncomingRequests: acceptedIncomingRequests,
  );
});

final badgesProvider = Provider<List<AppBadge>>((ref) {
  final s = ref.watch(_badgeStatsProvider);

  AppBadge mk({
    required String id,
    required String name,
    required String description,
    required IconData icon,
    required BadgeRarity rarity,
    required int value,
    required int max,
  }) {
    final clamped = math.min(value, max);
    final unlocked = value >= max;
    return AppBadge(
      id: id,
      name: name,
      description: description,
      icon: icon,
      rarity: rarity,
      progress: clamped,
      maxProgress: max,
      isUnlocked: unlocked,
    );
  }

  return [
    mk(
      id: 'first_steps',
      name: 'First Steps',
      description: 'Complete your first project',
      icon: Icons.flag_outlined,
      rarity: BadgeRarity.common,
      value: s.doneProjects,
      max: 1,
    ),
    mk(
      id: 'organizer',
      name: 'The Organizer',
      description: 'Create 5 projects',
      icon: Icons.star_outline,
      rarity: BadgeRarity.rare,
      value: s.totalProjects,
      max: 5,
    ),
    mk(
      id: 'steady_worker',
      name: 'Steady Worker',
      description: 'Complete 10 projects',
      icon: Icons.show_chart,
      rarity: BadgeRarity.rare,
      value: s.doneProjects,
      max: 10,
    ),
    mk(
      id: 'helper_hero',
      name: 'Helper Hero',
      description: 'Accept 5 requests',
      icon: Icons.volunteer_activism_outlined,
      rarity: BadgeRarity.rare,
      value: s.acceptedIncomingRequests,
      max: 5,
    ),
  ];
});