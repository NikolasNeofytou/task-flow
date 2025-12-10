import 'package:flutter/material.dart';

class AsyncButton extends StatefulWidget {
  const AsyncButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.fullWidth = true,
    this.variant = _AsyncVariant.filled,
  });

  final String label;
  final Future<void> Function() onPressed;
  final IconData? icon;
  final bool fullWidth;
  final _AsyncVariant variant;

  @override
  State<AsyncButton> createState() => _AsyncButtonState();
}

class _AsyncButtonState extends State<AsyncButton> {
  bool _busy = false;

  Future<void> _handle() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await widget.onPressed();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isOutline = widget.variant == _AsyncVariant.outline;
    final child = _busy
        ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 16),
                const SizedBox(width: 8),
              ],
              Text(widget.label),
            ],
          );

    final button = isOutline
        ? OutlinedButton(
            onPressed: _busy ? null : _handle,
            child: child,
          )
        : FilledButton(
            onPressed: _busy ? null : _handle,
            child: child,
          );

    if (widget.fullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}

enum _AsyncVariant { filled, outline }
