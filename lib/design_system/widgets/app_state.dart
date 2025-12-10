import 'package:flutter/material.dart';

class AppStateView extends StatelessWidget {
  const AppStateView.loading({super.key, this.shimmer})
      : _state = _State.loading,
        message = null,
        onRetry = null;

  const AppStateView.empty({super.key, this.message = 'Nothing here yet.', this.onRetry})
      : shimmer = null,
        _state = _State.empty;

  const AppStateView.error({super.key, this.message = 'Something went wrong.', this.onRetry})
      : shimmer = null,
        _state = _State.error;

  final _State _state;
  final String? message;
  final VoidCallback? onRetry;
  final Widget? shimmer;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    switch (_state) {
      case _State.loading:
        if (shimmer != null) return shimmer!;
        return Center(
          child: CircularProgressIndicator.adaptive(
            valueColor: AlwaysStoppedAnimation(onSurface),
          ),
        );
      case _State.empty:
        return _StateBody(
          icon: Icons.inbox_outlined,
          label: message ?? 'Nothing here yet.',
          onRetry: onRetry,
        );
      case _State.error:
        return _StateBody(
          icon: Icons.error_outline,
          label: message ?? 'Something went wrong.',
          onRetry: onRetry,
        );
    }
  }
}

class _StateBody extends StatelessWidget {
  const _StateBody({
    required this.icon,
    required this.label,
    this.onRetry,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface.withOpacity(0.85);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 36, color: color),
          const SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center, style: TextStyle(color: color)),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ],
      ),
    );
  }
}

enum _State { loading, empty, error }
