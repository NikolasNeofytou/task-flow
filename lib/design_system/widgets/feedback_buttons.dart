import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/feedback_providers.dart';
import '../../core/services/feedback_service.dart';

/// Button with haptic feedback on press
class FeedbackButton extends ConsumerWidget {
  const FeedbackButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.feedbackType = FeedbackType.lightTap,
    this.style,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final FeedbackType feedbackType;
  final ButtonStyle? style;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FilledButton(
      style: style,
      onPressed: onPressed == null
          ? null
          : () async {
              await ref.read(feedbackServiceProvider).trigger(feedbackType);
              onPressed!();
            },
      child: child,
    );
  }
}

/// IconButton with haptic feedback
class FeedbackIconButton extends ConsumerWidget {
  const FeedbackIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.feedbackType = FeedbackType.lightTap,
    this.tooltip,
  });

  final VoidCallback? onPressed;
  final Widget icon;
  final FeedbackType feedbackType;
  final String? tooltip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      tooltip: tooltip,
      icon: icon,
      onPressed: onPressed == null
          ? null
          : () async {
              await ref.read(feedbackServiceProvider).trigger(feedbackType);
              onPressed!();
            },
    );
  }
}

/// TextButton with haptic feedback
class FeedbackTextButton extends ConsumerWidget {
  const FeedbackTextButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.feedbackType = FeedbackType.lightTap,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final FeedbackType feedbackType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextButton(
      onPressed: onPressed == null
          ? null
          : () async {
              await ref.read(feedbackServiceProvider).trigger(feedbackType);
              onPressed!();
            },
      child: child,
    );
  }
}

/// OutlinedButton with haptic feedback
class FeedbackOutlinedButton extends ConsumerWidget {
  const FeedbackOutlinedButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.feedbackType = FeedbackType.lightTap,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final FeedbackType feedbackType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OutlinedButton(
      onPressed: onPressed == null
          ? null
          : () async {
              await ref.read(feedbackServiceProvider).trigger(feedbackType);
              onPressed!();
            },
      child: child,
    );
  }
}
