import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/feedback_providers.dart';
import '../../core/services/feedback_service.dart';
import '../../theme/tokens.dart';
import '../../theme/gradients.dart';
import '../animations/micro_interactions.dart';

/// Expandable floating action button with quick actions
class ExpandableFab extends ConsumerStatefulWidget {
  const ExpandableFab({
    super.key,
    required this.actions,
    this.mainIcon = Icons.add,
    this.expandedIcon = Icons.close,
  });

  final List<FabAction> actions;
  final IconData mainIcon;
  final IconData expandedIcon;

  @override
  ConsumerState<ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends ConsumerState<ExpandableFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() async {
    setState(() => _isExpanded = !_isExpanded);
    await ref.read(feedbackServiceProvider).trigger(FeedbackType.selection);
    
    if (_isExpanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      clipBehavior: Clip.none,
      children: [
        // Backdrop
        if (_isExpanded)
          GestureDetector(
            onTap: _toggle,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Colors.black.withOpacity(0.5),
            ),
          ),
        
        // Action buttons
        ..._buildExpandingActions(),
        
        // Main FAB
        PressableScale(
          onTap: _toggle,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: AppGradients.primary,
              shape: BoxShape.circle,
              boxShadow: AppShadows.colored(AppColors.primary),
            ),
            child: Icon(
              _isExpanded ? widget.expandedIcon : widget.mainIcon,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildExpandingActions() {
    final children = <Widget>[];
    final count = widget.actions.length;
    
    for (var i = 0; i < count; i++) {
      final action = widget.actions[i];
      final offset = (i + 1) * 70.0;
      
      children.add(
        AnimatedBuilder(
          animation: _expandAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, -offset * _expandAnimation.value),
              child: Opacity(
                opacity: _expandAnimation.value,
                child: child,
              ),
            );
          },
          child: _FabActionButton(
            action: action,
            onTap: () async {
              _toggle();
              await Future.delayed(const Duration(milliseconds: 100));
              action.onTap();
            },
          ),
        ),
      );
    }
    
    return children;
  }
}

class _FabActionButton extends ConsumerWidget {
  const _FabActionButton({
    required this.action,
    required this.onTap,
  });

  final FabAction action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Label
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadii.sm),
            boxShadow: AppShadows.level1,
          ),
          child: Text(
            action.label,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        
        // Button
        PressableScale(
          onTap: onTap,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: action.color ?? AppColors.primary,
              shape: BoxShape.circle,
              boxShadow: AppShadows.level1,
            ),
            child: Icon(
              action.icon,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}

/// Configuration for FAB actions
class FabAction {
  const FabAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
}
