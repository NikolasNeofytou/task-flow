import 'package:flutter/material.dart';

import '../../theme/tokens.dart';

/// Small status dot, optionally with label.
class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.color,
    this.label,
    this.size = 10,
  });

  final Color color;
  final String? label;
  final double size;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final dot = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1),
      ),
    );

    if (label == null) return dot;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        dot,
        const SizedBox(width: AppSpacing.xs),
        Text(
          label!,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(color: onSurface.withOpacity(0.8)),
        ),
      ],
    );
  }
}
