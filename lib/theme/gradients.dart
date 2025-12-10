import 'package:flutter/material.dart';
import 'tokens.dart';

/// Premium gradient presets for visual excellence
class AppGradients {
  /// Primary gradient for hero sections and important cards
  static const primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.primary,
      Color(0xFF7B2FE0),
      Color(0xFFB356FF),
    ],
    stops: [0.0, 0.5, 1.0],
  );

  /// Success gradient for completed states
  static const success = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.success,
      Color(0xFF7FE7C4),
      Color(0xFF5DD4A8),
    ],
    stops: [0.0, 0.5, 1.0],
  );

  /// Error gradient for alerts and destructive actions
  static const error = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.error,
      Color(0xFFFF4444),
      Color(0xFFFF6B6B),
    ],
    stops: [0.0, 0.5, 1.0],
  );

  /// Warning gradient for caution states
  static const warning = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.warning,
      Color(0xFFFFE066),
      Color(0xFFFFC933),
    ],
    stops: [0.0, 0.5, 1.0],
  );

  /// Info gradient for informational states
  static const info = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.info,
      Color(0xFFFF9366),
      Color(0xFFFFAB7A),
    ],
    stops: [0.0, 0.5, 1.0],
  );

  /// Accent gradient for highlights and special elements
  static const accent = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.accent,
      Color(0xFFFF4ECF),
      Color(0xFFFF70DB),
    ],
    stops: [0.0, 0.5, 1.0],
  );

  /// Subtle surface gradient for backgrounds
  static const surface = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFAFAFA),
      Color(0xFFFFFFFF),
    ],
  );

  /// Dark surface gradient for elevated cards
  static const surfaceElevated = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFF5F5F7),
    ],
  );

  /// Shimmer gradient for loading states
  static const shimmer = LinearGradient(
    begin: Alignment(-1.0, 0.0),
    end: Alignment(1.0, 0.0),
    colors: [
      Color(0xFFE0E0E0),
      Color(0xFFF0F0F0),
      Color(0xFFE0E0E0),
    ],
    stops: [0.0, 0.5, 1.0],
  );

  /// Task status gradients with tonal variations
  static Map<String, LinearGradient> taskStatus = {
    'todo': const LinearGradient(
      colors: [Color(0xFF9CA3AF), Color(0xFF6B7280)],
    ),
    'in_progress': const LinearGradient(
      colors: [Color(0xFF60A5FA), Color(0xFF3B82F6)],
    ),
    'done': const LinearGradient(
      colors: [Color(0xFF34D399), Color(0xFF10B981)],
    ),
    'blocked': const LinearGradient(
      colors: [Color(0xFFF87171), Color(0xFFEF4444)],
    ),
  };

  /// Create a custom gradient with opacity fade
  static LinearGradient withOpacityFade(
    Color color, {
    AlignmentGeometry begin = Alignment.topCenter,
    AlignmentGeometry end = Alignment.bottomCenter,
    double startOpacity = 1.0,
    double endOpacity = 0.0,
  }) {
    return LinearGradient(
      begin: begin,
      end: end,
      colors: [
        color.withOpacity(startOpacity),
        color.withOpacity(endOpacity),
      ],
    );
  }

  /// Create a subtle card background gradient
  static LinearGradient cardBackground(Color baseColor) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        baseColor.withOpacity(0.08),
        baseColor.withOpacity(0.04),
      ],
    );
  }

  /// Glass morphism gradient overlay
  static LinearGradient glass({Color tint = Colors.white}) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        tint.withOpacity(0.2),
        tint.withOpacity(0.1),
      ],
    );
  }

  /// Radial gradient for spotlight effects
  static RadialGradient spotlight(Color color) {
    return RadialGradient(
      center: Alignment.center,
      radius: 1.0,
      colors: [
        color.withOpacity(0.3),
        color.withOpacity(0.1),
        color.withOpacity(0.0),
      ],
      stops: const [0.0, 0.5, 1.0],
    );
  }
}
