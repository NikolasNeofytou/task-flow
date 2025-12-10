import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/feedback_providers.dart';
import '../../core/services/feedback_service.dart';
import '../../theme/tokens.dart';
import '../../theme/gradients.dart';

/// Swipeable card with complete and delete actions
class SwipeableCard extends ConsumerWidget {
  const SwipeableCard({
    super.key,
    required this.child,
    required this.onComplete,
    required this.onDelete,
    this.confirmDelete = true,
  });

  final Widget child;
  final VoidCallback onComplete;
  final VoidCallback onDelete;
  final bool confirmDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: UniqueKey(),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Complete action - no confirmation needed
          await ref.read(feedbackServiceProvider).trigger(FeedbackType.success);
          return true;
        } else {
          // Delete action - show confirmation if enabled
          if (!confirmDelete) return true;
          
          return await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Delete Item'),
              content: const Text('Are you sure you want to delete this item?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.error,
                  ),
                  child: const Text('Delete'),
                ),
              ],
            ),
          ) ?? false;
        }
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          onComplete();
        } else {
          onDelete();
        }
      },
      background: _buildSwipeBackground(
        alignment: Alignment.centerLeft,
        gradient: AppGradients.success,
        icon: Icons.check_circle,
        label: 'Complete',
      ),
      secondaryBackground: _buildSwipeBackground(
        alignment: Alignment.centerRight,
        gradient: AppGradients.error,
        icon: Icons.delete,
        label: 'Delete',
      ),
      child: child,
    );
  }

  Widget _buildSwipeBackground({
    required Alignment alignment,
    required Gradient gradient,
    required IconData icon,
    required String label,
  }) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

/// Swipeable list item with custom actions
class SwipeableListItem extends ConsumerStatefulWidget {
  const SwipeableListItem({
    super.key,
    required this.child,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.leftAction,
    this.rightAction,
  });

  final Widget child;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;
  final SwipeAction? leftAction;
  final SwipeAction? rightAction;

  @override
  ConsumerState<SwipeableListItem> createState() => _SwipeableListItemState();
}

class _SwipeableListItemState extends ConsumerState<SwipeableListItem> {
  double _dragExtent = 0;
  final double _threshold = 100;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        setState(() {
          _dragExtent += details.delta.dx;
          _dragExtent = _dragExtent.clamp(-200.0, 200.0);
        });
      },
      onHorizontalDragEnd: (details) async {
        if (_dragExtent.abs() > _threshold) {
          // Trigger haptic feedback
          await ref.read(feedbackServiceProvider).trigger(FeedbackType.selection);
          
          if (_dragExtent > 0 && widget.onSwipeRight != null) {
            widget.onSwipeRight!();
          } else if (_dragExtent < 0 && widget.onSwipeLeft != null) {
            widget.onSwipeLeft!();
          }
        }
        
        setState(() {
          _dragExtent = 0;
        });
      },
      child: Stack(
        children: [
          // Background actions
          Positioned.fill(
            child: Row(
              children: [
                if (widget.rightAction != null)
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: AppSpacing.lg),
                      decoration: BoxDecoration(
                        gradient: widget.rightAction!.gradient,
                        borderRadius: BorderRadius.circular(AppRadii.md),
                      ),
                      child: Icon(
                        widget.rightAction!.icon,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                if (widget.leftAction != null)
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: AppSpacing.lg),
                      decoration: BoxDecoration(
                        gradient: widget.leftAction!.gradient,
                        borderRadius: BorderRadius.circular(AppRadii.md),
                      ),
                      child: Icon(
                        widget.leftAction!.icon,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Draggable content
          Transform.translate(
            offset: Offset(_dragExtent, 0),
            child: widget.child,
          ),
        ],
      ),
    );
  }
}

/// Configuration for swipe actions
class SwipeAction {
  const SwipeAction({
    required this.icon,
    required this.gradient,
    required this.label,
  });

  final IconData icon;
  final Gradient gradient;
  final String label;
}
