import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Accessibility utilities for WCAG compliance and inclusive design
/// Provides semantic labels, announcements, and assistive technology support

/// Semantic label builder for consistent a11y labels
class A11yLabels {
  /// Create label for task item
  static String taskLabel({
    required String title,
    required String status,
    String? dueDate,
    String? projectName,
  }) {
    final parts = <String>[title];
    parts.add('Status: $status');
    if (dueDate != null) parts.add('Due: $dueDate');
    if (projectName != null) parts.add('Project: $projectName');
    return parts.join(', ');
  }
  
  /// Create label for project item
  static String projectLabel({
    required String name,
    required String status,
    required int taskCount,
  }) {
    return '$name, Status: $status, $taskCount ${taskCount == 1 ? 'task' : 'tasks'}';
  }
  
  /// Create label for button with action
  static String buttonLabel({
    required String text,
    String? hint,
  }) {
    return hint != null ? '$text, $hint' : text;
  }
  
  /// Create label for date picker
  static String dateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);
    
    if (targetDate == today) return 'Today, ${_formatDate(date)}';
    if (targetDate == today.add(const Duration(days: 1))) {
      return 'Tomorrow, ${_formatDate(date)}';
    }
    if (targetDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday, ${_formatDate(date)}';
    }
    
    return _formatDate(date);
  }
  
  static String _formatDate(DateTime date) {
    final months = ['January', 'February', 'March', 'April', 'May', 'June',
                    'July', 'August', 'September', 'October', 'November', 'December'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
  
  /// Create label for progress indicator
  static String progressLabel(int current, int total) {
    final percentage = total > 0 ? (current / total * 100).round() : 0;
    return '$current of $total completed, $percentage percent';
  }
  
  /// Create label for tab
  static String tabLabel({
    required String name,
    required int index,
    required int total,
    bool selected = false,
  }) {
    final position = 'Tab ${index + 1} of $total';
    final status = selected ? 'selected' : 'not selected';
    return '$name, $position, $status';
  }
  
  /// Create label for notification badge
  static String notificationBadge(int count) {
    if (count == 0) return 'No notifications';
    if (count == 1) return '1 notification';
    return '$count notifications';
  }
}

/// Semantic hint builder for action descriptions
class A11yHints {
  static const String tapToOpen = 'Double tap to open';
  static const String tapToSelect = 'Double tap to select';
  static const String tapToToggle = 'Double tap to toggle';
  static const String tapToEdit = 'Double tap to edit';
  static const String tapToDelete = 'Double tap to delete';
  static const String tapToComplete = 'Double tap to mark as complete';
  static const String swipeToDelete = 'Swipe left to delete';
  static const String swipeToComplete = 'Swipe right to complete';
  static const String longPressForOptions = 'Long press for more options';
  
  /// Create hint for navigation
  static String navigateTo(String destination) => 'Double tap to navigate to $destination';
  
  /// Create hint for form input
  static String inputHint(String fieldName) => 'Enter $fieldName';
  
  /// Create hint for selection
  static String selectionHint(int currentIndex, int total) {
    return 'Item $currentIndex of $total, swipe to navigate';
  }
}

/// Live region announcer for screen readers
class A11yAnnouncer {
  /// Announce a message to screen readers
  static void announce(
    BuildContext context,
    String message, {
    Assertiveness assertiveness = Assertiveness.polite,
  }) {
    SemanticsService.announce(message, TextDirection.ltr);
  }
  
  /// Announce success
  static void announceSuccess(BuildContext context, String message) {
    announce(context, '✓ $message', assertiveness: Assertiveness.polite);
  }
  
  /// Announce error
  static void announceError(BuildContext context, String message) {
    announce(context, 'Error: $message', assertiveness: Assertiveness.assertive);
  }
  
  /// Announce warning
  static void announceWarning(BuildContext context, String message) {
    announce(context, 'Warning: $message', assertiveness: Assertiveness.polite);
  }
  
  /// Announce loading state
  static void announceLoading(BuildContext context) {
    announce(context, 'Loading...', assertiveness: Assertiveness.polite);
  }
  
  /// Announce completion
  static void announceComplete(BuildContext context, String action) {
    announce(context, '$action completed', assertiveness: Assertiveness.polite);
  }
}

/// Focus management utilities
class A11yFocus {
  /// Request focus on a node
  static void requestFocus(FocusNode node) {
    node.requestFocus();
  }
  
  /// Move focus to next focusable element
  static void focusNext(BuildContext context) {
    FocusScope.of(context).nextFocus();
  }
  
  /// Move focus to previous focusable element
  static void focusPrevious(BuildContext context) {
    FocusScope.of(context).previousFocus();
  }
  
  /// Unfocus current element
  static void unfocus(BuildContext context) {
    FocusScope.of(context).unfocus();
  }
  
  /// Check if element has focus
  static bool hasFocus(FocusNode node) {
    return node.hasFocus;
  }
}

/// Semantic widget wrappers for common patterns
class A11ySemantics {
  /// Wrap button with proper semantics
  static Widget button({
    required Widget child,
    required VoidCallback onTap,
    String? label,
    String? hint,
    bool enabled = true,
  }) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      hint: hint ?? A11yHints.tapToOpen,
      onTap: enabled ? onTap : null,
      child: child,
    );
  }
  
  /// Wrap checkbox with proper semantics
  static Widget checkbox({
    required Widget child,
    required bool checked,
    required VoidCallback onToggle,
    String? label,
    bool enabled = true,
  }) {
    return Semantics(
      checked: checked,
      enabled: enabled,
      label: label,
      hint: A11yHints.tapToToggle,
      onTap: enabled ? onToggle : null,
      child: child,
    );
  }
  
  /// Wrap link with proper semantics
  static Widget link({
    required Widget child,
    required VoidCallback onTap,
    String? label,
    bool enabled = true,
  }) {
    return Semantics(
      link: true,
      enabled: enabled,
      label: label,
      hint: A11yHints.tapToOpen,
      onTap: enabled ? onTap : null,
      child: child,
    );
  }
  
  /// Wrap header with proper semantics
  static Widget header({
    required Widget child,
    required String text,
    int level = 1,
  }) {
    return Semantics(
      header: true,
      label: text,
      child: child,
    );
  }
  
  /// Wrap image with proper semantics
  static Widget image({
    required Widget child,
    required String description,
    bool decorative = false,
  }) {
    return Semantics(
      image: true,
      label: decorative ? null : description,
      excludeSemantics: decorative,
      child: child,
    );
  }
  
  /// Wrap list with proper semantics
  static Widget list({
    required Widget child,
    required int itemCount,
  }) {
    return Semantics(
      label: '$itemCount items',
      child: child,
    );
  }
  
  /// Create live region for dynamic content
  static Widget liveRegion({
    required Widget child,
    required String announcement,
    bool assertive = false,
  }) {
    return Semantics(
      liveRegion: true,
      label: announcement,
      child: child,
    );
  }
}

/// Accessibility checker for WCAG compliance
class A11yChecker {
  /// Check if color contrast meets WCAG AA standard (4.5:1)
  static bool hasGoodContrast(Color foreground, Color background) {
    final ratio = _calculateContrastRatio(foreground, background);
    return ratio >= 4.5;
  }
  
  /// Check if color contrast meets WCAG AAA standard (7:1)
  static bool hasExcellentContrast(Color foreground, Color background) {
    final ratio = _calculateContrastRatio(foreground, background);
    return ratio >= 7.0;
  }
  
  /// Calculate contrast ratio between two colors
  static double _calculateContrastRatio(Color color1, Color color2) {
    final l1 = _relativeLuminance(color1);
    final l2 = _relativeLuminance(color2);
    final lighter = l1 > l2 ? l1 : l2;
    final darker = l1 > l2 ? l2 : l1;
    return (lighter + 0.05) / (darker + 0.05);
  }
  
  /// Calculate relative luminance
  static double _relativeLuminance(Color color) {
    final r = _srgbToLinear(color.red / 255.0);
    final g = _srgbToLinear(color.green / 255.0);
    final b = _srgbToLinear(color.blue / 255.0);
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }
  
  /// Convert sRGB to linear RGB
  static double _srgbToLinear(double value) {
    if (value <= 0.03928) {
      return value / 12.92;
    }
    return ((value + 0.055) / 1.055).pow(2.4).toDouble();
  }
  
  /// Check if touch target meets minimum size (48x48 dp)
  static bool hasValidTouchTarget(double width, double height) {
    return width >= 48.0 && height >= 48.0;
  }
  
  /// Get recommended touch target size
  static Size get recommendedTouchTarget => const Size(48.0, 48.0);
  
  /// Get minimum touch target size for WCAG compliance
  static Size get minimumTouchTarget => const Size(44.0, 44.0);
}

/// Accessible text scaling utilities
class A11yTextScale {
  /// Get current text scale factor
  static double getTextScaleFactor(BuildContext context) {
    return MediaQuery.of(context).textScaleFactor;
  }
  
  /// Check if user has large text enabled
  static bool hasLargeText(BuildContext context) {
    return getTextScaleFactor(context) > 1.3;
  }
  
  /// Clamp text scale factor to prevent overflow
  static double clampTextScale(BuildContext context, {
    double min = 0.8,
    double max = 2.0,
  }) {
    final scale = getTextScaleFactor(context);
    return scale.clamp(min, max);
  }
  
  /// Get scaled font size
  static double scaledFontSize(BuildContext context, double baseSize) {
    return baseSize * getTextScaleFactor(context);
  }
}

/// Screen reader detection
class A11yScreenReader {
  /// Check if screen reader is enabled
  static bool isEnabled(BuildContext context) {
    return MediaQuery.of(context).accessibleNavigation;
  }
  
  /// Check if bold text is enabled
  static bool isBoldTextEnabled(BuildContext context) {
    return MediaQuery.of(context).boldText;
  }
  
  /// Check if high contrast is enabled
  static bool isHighContrastEnabled(BuildContext context) {
    return MediaQuery.of(context).highContrast;
  }
  
  /// Check if animations should be disabled
  static bool shouldDisableAnimations(BuildContext context) {
    return MediaQuery.of(context).disableAnimations;
  }
}

extension IntPow on double {
  double pow(num exponent) {
    return this * this;
  }
}
