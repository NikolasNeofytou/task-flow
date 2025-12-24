import 'package:flutter/material.dart';

/// Badge rarity levels (like Clash Royale card rarities)
enum BadgeRarity {
  common,
  rare,
  epic,
  legendary,
}

/// Achievement badge model
class AppBadge {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final BadgeRarity rarity;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int progress;
  final int maxProgress;

  const AppBadge({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.rarity,
    this.isUnlocked = false,
    this.unlockedAt,
    this.progress = 0,
    this.maxProgress = 1,
  });

  AppBadge copyWith({
    String? id,
    String? name,
    String? description,
    IconData? icon,
    BadgeRarity? rarity,
    bool? isUnlocked,
    DateTime? unlockedAt,
    int? progress,
    int? maxProgress,
  }) {
    return AppBadge(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      rarity: rarity ?? this.rarity,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      progress: progress ?? this.progress,
      maxProgress: maxProgress ?? this.maxProgress,
    );
  }

  /// Get color based on rarity
  Color get rarityColor {
    switch (rarity) {
      case BadgeRarity.common:
        return Colors.grey;
      case BadgeRarity.rare:
        return Colors.blue;
      case BadgeRarity.epic:
        return Colors.purple;
      case BadgeRarity.legendary:
        return Colors.amber;
    }
  }

  /// Get display name for rarity
  String get rarityName {
    switch (rarity) {
      case BadgeRarity.common:
        return 'Common';
      case BadgeRarity.rare:
        return 'Rare';
      case BadgeRarity.epic:
        return 'Epic';
      case BadgeRarity.legendary:
        return 'Legendary';
    }
  }

  /// Progress percentage
  double get progressPercentage => maxProgress > 0 ? progress / maxProgress : 0.0;
}

/// Sample badges collection
class BadgeCollection {
  static final List<AppBadge> all = [
    // Common badges
    const AppBadge(
      id: 'first_task',
      name: 'First Steps',
      description: 'Complete your first task',
      icon: Icons.flag,
      rarity: BadgeRarity.common,
      maxProgress: 1,
    ),
    const AppBadge(
      id: 'team_player',
      name: 'Team Player',
      description: 'Join a team project',
      icon: Icons.group,
      rarity: BadgeRarity.common,
      maxProgress: 1,
    ),
    const AppBadge(
      id: 'early_bird',
      name: 'Early Bird',
      description: 'Complete a task before 9 AM',
      icon: Icons.wb_sunny,
      rarity: BadgeRarity.common,
      maxProgress: 1,
    ),
    
    // Rare badges
    const AppBadge(
      id: 'steady_worker',
      name: 'Steady Worker',
      description: 'Complete 10 tasks',
      icon: Icons.trending_up,
      rarity: BadgeRarity.rare,
      maxProgress: 10,
    ),
    const AppBadge(
      id: 'helper_hero',
      name: 'Helper Hero',
      description: 'Help 5 teammates',
      icon: Icons.volunteer_activism,
      rarity: BadgeRarity.rare,
      maxProgress: 5,
    ),
    const AppBadge(
      id: 'organizer',
      name: 'The Organizer',
      description: 'Create 5 projects',
      icon: Icons.folder_special,
      rarity: BadgeRarity.rare,
      maxProgress: 5,
    ),
    
    // Epic badges
    const AppBadge(
      id: 'speed_demon',
      name: 'Speed Demon',
      description: 'Complete 5 tasks in one day',
      icon: Icons.flash_on,
      rarity: BadgeRarity.epic,
      maxProgress: 5,
    ),
    const AppBadge(
      id: 'streak_master',
      name: 'Streak Master',
      description: 'Work 7 days in a row',
      icon: Icons.local_fire_department,
      rarity: BadgeRarity.epic,
      maxProgress: 7,
    ),
    const AppBadge(
      id: 'perfectionist',
      name: 'Perfectionist',
      description: 'Complete 20 tasks without missing a deadline',
      icon: Icons.star,
      rarity: BadgeRarity.epic,
      maxProgress: 20,
    ),
    
    // Legendary badges
    const AppBadge(
      id: 'task_legend',
      name: 'Task Legend',
      description: 'Complete 100 tasks',
      icon: Icons.emoji_events,
      rarity: BadgeRarity.legendary,
      maxProgress: 100,
    ),
    const AppBadge(
      id: 'consistency_king',
      name: 'Consistency King',
      description: 'Work 30 days in a row',
      icon: Icons.stars,
      rarity: BadgeRarity.legendary,
      maxProgress: 30,
    ),
    const AppBadge(
      id: 'team_leader',
      name: 'Team Leader',
      description: 'Lead 10 successful projects',
      icon: Icons.military_tech,
      rarity: BadgeRarity.legendary,
      maxProgress: 10,
    ),
  ];
}
