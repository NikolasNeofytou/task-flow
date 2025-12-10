import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/feedback_providers.dart';
import '../../core/services/feedback_service.dart';
import '../../theme/tokens.dart';

/// Card with press scale animation and hover/press visual feedback.
class AnimatedCard extends ConsumerStatefulWidget {
  const AnimatedCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.backgroundGradient,
    this.enableFeedback = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final Gradient? backgroundGradient;
  final bool enableFeedback;

  @override
  ConsumerState<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends ConsumerState<AnimatedCard>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  void _setPressed(bool pressed) {
    setState(() {
      _scale = pressed ? 0.97 : 1.0;
    });
  }

  void _handleTap() async {
    if (widget.onTap == null) return;

    if (widget.enableFeedback) {
      await ref.read(feedbackServiceProvider).trigger(FeedbackType.selection);
    }

    widget.onTap!();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final content = Padding(padding: widget.padding, child: widget.child);

    return MouseRegion(
      onEnter: (_) => _setPressed(true),
      onExit: (_) => _setPressed(false),
      child: GestureDetector(
        onTapDown: (_) => _setPressed(true),
        onTapCancel: () => _setPressed(false),
        onTapUp: (_) => _setPressed(false),
        onTap: _handleTap,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 120),
          scale: _scale,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: widget.backgroundGradient == null
                  ? colorScheme.surface
                  : null,
              borderRadius: BorderRadius.circular(AppRadii.md),
              boxShadow: AppShadows.level1,
              border: Border.all(color: colorScheme.outline.withOpacity(0.12)),
              gradient: widget.backgroundGradient,
            ),
            child: content,
          ),
        ),
      ),
    );
  }
}
