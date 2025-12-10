import 'package:flutter/material.dart';
import '../../theme/tokens.dart';

/// Button with built-in loading state and disabled state handling.
class LoadingButton extends StatelessWidget {
  const LoadingButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.isLoading = false,
    this.type = LoadingButtonType.filled,
  });

  final Future<void> Function()? onPressed;
  final String label;
  final IconData? icon;
  final bool isLoading;
  final LoadingButtonType type;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isLoading)
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        else if (icon != null)
          Icon(icon, size: 18),
        if (isLoading || icon != null) const SizedBox(width: AppSpacing.sm),
        Text(label),
      ],
    );

    switch (type) {
      case LoadingButtonType.filled:
        return FilledButton(
          onPressed: isDisabled ? null : onPressed,
          child: content,
        );
      case LoadingButtonType.outlined:
        return OutlinedButton(
          onPressed: isDisabled ? null : onPressed,
          child: content,
        );
      case LoadingButtonType.text:
        return TextButton(
          onPressed: isDisabled ? null : onPressed,
          child: content,
        );
    }
  }
}

/// Stateful version that manages loading state automatically.
class StatefulLoadingButton extends StatefulWidget {
  const StatefulLoadingButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.type = LoadingButtonType.filled,
  });

  final Future<void> Function() onPressed;
  final String label;
  final IconData? icon;
  final LoadingButtonType type;

  @override
  State<StatefulLoadingButton> createState() => _StatefulLoadingButtonState();
}

class _StatefulLoadingButtonState extends State<StatefulLoadingButton> {
  bool _isLoading = false;

  Future<void> _handlePressed() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    try {
      await widget.onPressed();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingButton(
      onPressed: _handlePressed,
      label: widget.label,
      icon: widget.icon,
      isLoading: _isLoading,
      type: widget.type,
    );
  }
}

enum LoadingButtonType { filled, outlined, text }
