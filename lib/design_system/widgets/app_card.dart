import 'package:flutter/material.dart';

import '../../theme/tokens.dart';

/// Standard card with consistent padding, radius, and shadow.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final content = Padding(padding: padding, child: child);
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadii.md),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.md),
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.md),
            boxShadow: AppShadows.level1,
            border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.surface.withValues(alpha: 0.9),
                colorScheme.surfaceContainerHighest.withValues(alpha: 0.9),
              ],
            ),
          ),
          child: content,
        ),
      ),
    );
  }
}
