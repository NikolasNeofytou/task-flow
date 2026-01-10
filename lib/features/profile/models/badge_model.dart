import 'package:flutter/material.dart';

enum BadgeRarity { common, rare, epic, legendary }

class AppBadge {
  const AppBadge({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.rarity,
    required this.progress,
    required this.maxProgress,
    required this.isUnlocked,
  });

  final String id;
  final String name;
  final String description;
  final IconData icon;
  final BadgeRarity rarity;

  final int progress;
  final int maxProgress;
  final bool isUnlocked;

  double get progressPercentage {
    if (maxProgress <= 0) return 0;
    final v = progress / maxProgress;
    return v.clamp(0.0, 1.0);
  }

  String get rarityName {
    switch (rarity) {
      case BadgeRarity.common:
        return 'C';
      case BadgeRarity.rare:
        return 'R';
      case BadgeRarity.epic:
        return 'E';
      case BadgeRarity.legendary:
        return 'L';
    }
  }

  Color get rarityColor {
    switch (rarity) {
      case BadgeRarity.common:
        return Colors.blueGrey;
      case BadgeRarity.rare:
        return Colors.blue;
      case BadgeRarity.epic:
        return Colors.purple;
      case BadgeRarity.legendary:
        return Colors.amber;
    }
  }

  AppBadge copyWith({
    int? progress,
    int? maxProgress,
    bool? isUnlocked,
  }) {
    return AppBadge(
      id: id,
      name: name,
      description: description,
      icon: icon,
      rarity: rarity,
      progress: progress ?? this.progress,
      maxProgress: maxProgress ?? this.maxProgress,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }
}