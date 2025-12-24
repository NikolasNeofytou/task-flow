import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/feedback_providers.dart';
import '../../core/services/feedback_service.dart';
import '../../theme/tokens.dart';

/// Custom refresh indicator with haptic feedback
class CustomRefreshIndicator extends ConsumerWidget {
  const CustomRefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.child,
    this.color,
  });

  final Future<void> Function() onRefresh;
  final Widget child;
  final Color? color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(feedbackServiceProvider).trigger(FeedbackType.mediumImpact);
        await onRefresh();
        await ref.read(feedbackServiceProvider).trigger(FeedbackType.success);
      },
      displacement: 60,
      strokeWidth: 3,
      color: color ?? AppColors.primary,
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: child,
    );
  }
}

/// Animated pull-to-refresh with custom indicator
class AnimatedRefreshIndicator extends StatefulWidget {
  const AnimatedRefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.child,
  });

  final Future<void> Function() onRefresh;
  final Widget child;

  @override
  State<AnimatedRefreshIndicator> createState() => _AnimatedRefreshIndicatorState();
}

class _AnimatedRefreshIndicatorState extends State<AnimatedRefreshIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    _controller.repeat();
    
    await widget.onRefresh();
    
    _controller.stop();
    setState(() => _isRefreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      displacement: 60,
      child: widget.child,
      // Custom builder for the indicator
      notificationPredicate: (notification) {
        if (notification is ScrollStartNotification) {
          if (!_isRefreshing) {
            _controller.forward();
          }
        } else if (notification is ScrollEndNotification) {
          if (!_isRefreshing) {
            _controller.reverse();
          }
        }
        return true;
      },
    );
  }
}

/// Pull-to-refresh header widget
class RefreshHeader extends StatelessWidget {
  const RefreshHeader({
    super.key,
    required this.refreshing,
  });

  final bool refreshing;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      alignment: Alignment.center,
      child: refreshing
          ? const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Text(
                  'Refreshing...',
                  style: TextStyle(
                    color: AppColors.neutral,
                    fontSize: 14,
                  ),
                ),
              ],
            )
          : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.arrow_downward,
                  color: AppColors.primary,
                  size: 20,
                ),
                SizedBox(width: AppSpacing.sm),
                Text(
                  'Pull to refresh',
                  style: TextStyle(
                    color: AppColors.neutral,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
    );
  }
}
