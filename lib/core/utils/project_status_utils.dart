import 'package:flutter/material.dart';
import '../../theme/tokens.dart';
import '../models/project.dart';

ProjectStatus effectiveProjectStatus(Project p) {
  if (p.status == ProjectStatus.done) return ProjectStatus.done;

  final d = p.deadline;
  if (d == null) return ProjectStatus.onTrack;

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final deadlineDay = DateTime(d.year, d.month, d.day);

  final diff = deadlineDay.difference(today).inDays;

  if (diff < 0) return ProjectStatus.blocked; // έληξε
  if (diff <= 5) return ProjectStatus.dueSoon; // <= 5 μέρες
  return ProjectStatus.onTrack; // > 5 μέρες
}

String projectStatusLabel(ProjectStatus s) {
  switch (s) {
    case ProjectStatus.onTrack:
      return 'On track';
    case ProjectStatus.dueSoon:
      return 'Due soon';
    case ProjectStatus.blocked:
      return 'Blocked';
    case ProjectStatus.done:
      return 'Done';
  }
}

Color projectStatusColor(ProjectStatus s) {
  switch (s) {
    case ProjectStatus.onTrack:
      return AppColors.success;
    case ProjectStatus.dueSoon:
      return AppColors.warning;
    case ProjectStatus.blocked:
      return AppColors.error;
    case ProjectStatus.done:
      return AppColors.success;
  }
}