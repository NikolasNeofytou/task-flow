import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Accessibility utilities for improving app usability
class AccessibilityUtils {
  /// Minimum touch target size (48x48 dp) per Material Design guidelines
  static const double minTouchTargetSize = 48.0;

  /// Recommended touch target size for better accessibility
  static const double recommendedTouchTargetSize = 56.0;

  /// Check if accessibility features are enabled
  static bool isAccessibilityEnabled(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.accessibleNavigation ||
        mediaQuery.boldText ||
        mediaQuery.highContrast;
  }

  /// Check if high contrast mode is enabled
  static bool isHighContrastEnabled(BuildContext context) {
    return MediaQuery.of(context).highContrast;
  }

  /// Check if large text is enabled
  static bool isLargeTextEnabled(BuildContext context) {
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    return textScaleFactor > 1.3;
  }

  /// Check if bold text is enabled
  static bool isBoldTextEnabled(BuildContext context) {
    return MediaQuery.of(context).boldText;
  }

  /// Get text scale factor with accessibility support
  static double getTextScaleFactor(BuildContext context, {double max = 2.0}) {
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    return textScaleFactor.clamp(1.0, max);
  }

  /// Ensure minimum touch target size
  static Widget ensureTouchTarget({
    required Widget child,
    double minSize = minTouchTargetSize,
  }) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: minSize,
        minHeight: minSize,
      ),
      child: child,
    );
  }

  /// Create accessible button with semantic label
  static Widget accessibleButton({
    required Widget child,
    required VoidCallback? onPressed,
    required String semanticLabel,
    String? tooltip,
    bool enabled = true,
  }) {
    Widget button = child;

    if (tooltip != null) {
      button = Tooltip(
        message: tooltip,
        child: button,
      );
    }

    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: enabled,
      child: ensureTouchTarget(child: button),
    );
  }

  /// Announce message to screen readers
  static void announce(BuildContext context, String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }

  /// Create accessible text field
  static Widget accessibleTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    String? error,
    TextInputType? keyboardType,
    bool obscureText = false,
    bool enabled = true,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      textField: true,
      enabled: enabled,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          errorText: error,
        ),
      ),
    );
  }

  /// Get contrast ratio between two colors
  static double getContrastRatio(Color color1, Color color2) {
    final luminance1 = color1.computeLuminance();
    final luminance2 = color2.computeLuminance();

    final lighter = luminance1 > luminance2 ? luminance1 : luminance2;
    final darker = luminance1 > luminance2 ? luminance2 : luminance1;

    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Check if color contrast meets WCAG AA standards (4.5:1 for normal text)
  static bool meetsContrastAA(Color foreground, Color background) {
    return getContrastRatio(foreground, background) >= 4.5;
  }

  /// Check if color contrast meets WCAG AAA standards (7:1 for normal text)
  static bool meetsContrastAAA(Color foreground, Color background) {
    return getContrastRatio(foreground, background) >= 7.0;
  }

  /// Get recommended color for sufficient contrast
  static Color getContrastingColor(Color background) {
    final luminance = background.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}

/// Extension methods for accessibility
extension AccessibilityExtension on Widget {
  /// Wrap widget with semantic label
  Widget withSemantics({
    String? label,
    String? hint,
    String? value,
    bool? button,
    bool? header,
    bool? link,
    bool? selected,
    bool? enabled,
    bool? focusable,
    bool? hidden,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      value: value,
      button: button,
      header: header,
      link: link,
      selected: selected,
      enabled: enabled,
      focusable: focusable,
      excludeSemantics: hidden ?? false,
      child: this,
    );
  }

  /// Wrap widget with minimum touch target size
  Widget withTouchTarget(
      {double minSize = AccessibilityUtils.minTouchTargetSize}) {
    return AccessibilityUtils.ensureTouchTarget(
      child: this,
      minSize: minSize,
    );
  }

  /// Make widget excludeFromSemantics (hide from screen readers)
  Widget excludeFromSemantics() {
    return ExcludeSemantics(child: this);
  }

  /// Make widget merge semantics
  Widget mergeSemantics() {
    return MergeSemantics(child: this);
  }
}

/// Accessible icon button with proper sizing and semantics
class AccessibleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String semanticLabel;
  final String? tooltip;
  final double size;
  final Color? color;
  final EdgeInsetsGeometry? padding;

  const AccessibleIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.semanticLabel,
    this.tooltip,
    this.size = 24.0,
    this.color,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    Widget button = IconButton(
      icon: Icon(icon, size: size, color: color),
      onPressed: onPressed,
      padding: padding ?? const EdgeInsets.all(12),
      constraints: const BoxConstraints(
        minWidth: AccessibilityUtils.minTouchTargetSize,
        minHeight: AccessibilityUtils.minTouchTargetSize,
      ),
      tooltip: tooltip ?? semanticLabel,
    );

    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: onPressed != null,
      child: button,
    );
  }
}

/// Accessible list tile with proper semantics
class AccessibleListTile extends StatelessWidget {
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final bool selected;
  final bool enabled;

  const AccessibleListTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.semanticLabel,
    this.selected = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      button: onTap != null,
      selected: selected,
      enabled: enabled,
      child: ListTile(
        leading: leading,
        title: title,
        subtitle: subtitle,
        trailing: trailing,
        onTap: enabled ? onTap : null,
        selected: selected,
        enabled: enabled,
        minVerticalPadding: 12,
      ),
    );
  }
}

/// Skip to content link for keyboard navigation
class SkipToContent extends StatelessWidget {
  final GlobalKey contentKey;
  final String label;

  const SkipToContent({
    super.key,
    required this.contentKey,
    this.label = 'Skip to content',
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      child: InkWell(
        onTap: () {
          final context = contentKey.currentContext;
          if (context != null) {
            Scrollable.ensureVisible(
              context,
              duration: const Duration(milliseconds: 300),
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          color: Theme.of(context).colorScheme.primary,
          child: Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

/// Live region for announcing dynamic content changes
class LiveRegion extends StatelessWidget {
  final String text;
  final LiveRegionPriority priority;
  final Widget child;

  const LiveRegion({
    super.key,
    required this.text,
    this.priority = LiveRegionPriority.polite,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: text,
      child: child,
    );
  }
}

enum LiveRegionPriority {
  polite,
  assertive,
}

/// Focus management utilities
class FocusUtils {
  /// Request focus on a node
  static void requestFocus(BuildContext context, FocusNode node) {
    FocusScope.of(context).requestFocus(node);
  }

  /// Move focus to next field
  static void nextFocus(BuildContext context) {
    FocusScope.of(context).nextFocus();
  }

  /// Move focus to previous field
  static void previousFocus(BuildContext context) {
    FocusScope.of(context).previousFocus();
  }

  /// Unfocus current field
  static void unfocus(BuildContext context) {
    FocusScope.of(context).unfocus();
  }
}
