import 'package:flutter/material.dart';
import '../../theme/tokens.dart';

/// Type of snackbar message.
enum SnackbarType { success, error, info, warning }

/// Custom styled snackbar with icon and type-specific colors.
class AppSnackbar {
  static void show(
    BuildContext context, {
    required String message,
    SnackbarType type = SnackbarType.info,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final config = _getConfig(type);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              config.icon,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: config.color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        margin: const EdgeInsets.all(AppSpacing.lg),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        duration: duration,
        action: actionLabel != null && onAction != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: Colors.white,
                onPressed: onAction,
              )
            : null,
        elevation: 6,
      ),
    );
  }

  static _SnackbarConfig _getConfig(SnackbarType type) {
    switch (type) {
      case SnackbarType.success:
        return _SnackbarConfig(
          color: const Color(0xFF22C55E),
          icon: Icons.check_circle,
        );
      case SnackbarType.error:
        return _SnackbarConfig(
          color: const Color(0xFFEF4444),
          icon: Icons.error,
        );
      case SnackbarType.warning:
        return _SnackbarConfig(
          color: const Color(0xFFF59E0B),
          icon: Icons.warning,
        );
      case SnackbarType.info:
        return _SnackbarConfig(
          color: AppColors.primary,
          icon: Icons.info,
        );
    }
  }
}

class _SnackbarConfig {
  final Color color;
  final IconData icon;

  _SnackbarConfig({required this.color, required this.icon});
}
