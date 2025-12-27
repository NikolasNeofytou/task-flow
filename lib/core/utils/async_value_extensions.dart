import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/error_display.dart';

/// Extension on AsyncValue to simplify error handling
extension AsyncValueUI on AsyncValue {
  /// Build widget with standardized loading and error handling
  Widget when2({
    required Widget Function(dynamic data) data,
    Widget Function()? loading,
    Widget Function(Object error, VoidCallback? retry)? error,
    VoidCallback? onRetry,
  }) {
    return when(
      data: data,
      loading: () =>
          loading?.call() ?? const Center(child: CircularProgressIndicator()),
      error: (err, stack) =>
          error?.call(err, onRetry) ??
          ErrorDisplay(error: err, onRetry: onRetry),
    );
  }

  /// Show error as snackbar
  void showErrorSnackbar(BuildContext context, {VoidCallback? onRetry}) {
    whenOrNull(
      error: (error, _) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            showErrorSnackbar(context, error: error, onRetry: onRetry);
          }
        });
      },
    );
  }
}

/// Helper widget for AsyncValue with retry
class AsyncValueWidget<T> extends StatelessWidget {
  const AsyncValueWidget({
    super.key,
    required this.value,
    required this.data,
    this.loading,
    this.error,
    this.onRetry,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final Widget Function()? loading;
  final Widget Function(Object error, VoidCallback? retry)? error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      loading: () =>
          loading?.call() ?? const Center(child: CircularProgressIndicator()),
      error: (err, _) =>
          error?.call(err, onRetry) ??
          ErrorDisplay(error: err, onRetry: onRetry),
    );
  }
}
