import 'package:flutter/material.dart';
import '../../theme/tokens.dart';

/// Helper class for showing bottom sheets with consistent styling.
class AppBottomSheet {
  /// Show a modal bottom sheet with standard styling.
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
    double? height,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: height,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadii.xxl),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.neutral.withOpacity(0.3),
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Flexible(child: child),
          ],
        ),
      ),
    );
  }

  /// Show an action sheet with a list of options.
  static Future<T?> showActions<T>({
    required BuildContext context,
    required String title,
    String? subtitle,
    required List<BottomSheetAction<T>> actions,
    bool showCancel = true,
  }) {
    return show<T>(
      context: context,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.neutral,
                      ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              ...actions.map((action) => _ActionTile<T>(action: action)),
              if (showCancel) ...[
                const SizedBox(height: AppSpacing.sm),
                _CancelTile(),
              ],
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  /// Show a confirmation bottom sheet with custom actions.
  static Future<bool?> showConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDestructive = false,
  }) {
    return show<bool>(
      context: context,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isDestructive ? Icons.warning_rounded : Icons.help_outline,
                size: 48,
                color: isDestructive
                    ? const Color(0xFFEF4444)
                    : AppColors.primary,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.neutral,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxl),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(cancelLabel),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: isDestructive
                          ? FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFEF4444),
                            )
                          : null,
                      child: Text(confirmLabel),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Action item for bottom sheet.
class BottomSheetAction<T> {
  final IconData icon;
  final String label;
  final T value;
  final bool isDestructive;

  const BottomSheetAction({
    required this.icon,
    required this.label,
    required this.value,
    this.isDestructive = false,
  });
}

class _ActionTile<T> extends StatelessWidget {
  const _ActionTile({required this.action});

  final BottomSheetAction<T> action;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).pop(action.value),
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Icon(
              action.icon,
              color: action.isDestructive
                  ? const Color(0xFFEF4444)
                  : AppColors.neutral,
            ),
            const SizedBox(width: AppSpacing.lg),
            Text(
              action.label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: action.isDestructive
                        ? const Color(0xFFEF4444)
                        : null,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CancelTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).pop(),
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.neutral.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        child: Text(
          'Cancel',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
