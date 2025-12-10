import 'package:flutter/material.dart';

import '../../theme/tokens.dart';

class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    required this.label,
    this.backgroundColor = AppColors.primary,
    this.textColor = Colors.white,
    this.radius = 20,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final initials = _initials(label);
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      child: Text(
        initials,
        style: Theme.of(context)
            .textTheme
            .labelLarge
            ?.copyWith(color: textColor),
      ),
    );
  }
}

String _initials(String value) {
  final parts = value.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty) return '';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  final first = parts.first.substring(0, 1).toUpperCase();
  final last = parts.last.substring(0, 1).toUpperCase();
  return '$first$last';
}
