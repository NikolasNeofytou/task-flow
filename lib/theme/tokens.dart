import 'package:flutter/material.dart';

/// Color tokens mapped from the shared Figma variables screenshot.
class AppColors {
  /// Brand primary (buttons, highlights).
  static const primary = Color(0xFF2563EB); // Solid blue for better contrast

  /// Success / accepted states.
  static const success = Color(0xFF9FFF7F);

  /// Error / destructive.
  static const error = Color(0xFFFF1E1E);

  /// Warning / caution.
  static const warning = Color(0xFFFFF239);

  /// Accent / secondary emphasis (badges, highlights).
  static const accent = Color(0xFFFD32E5);

  /// Info / tertiary emphasis.
  static const info = Color(0xFFF97B49);

  /// Surface / subtle background (cards, panels).
  static const surface = Color(0xFFCAE1F0);

  /// Neutral text and borders.
  static const neutral = Color(0xFF79747E);
}

/// Spacing scale (8pt-derived) for consistent layout rhythm.
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double pill = 999;
  static const double xxl = 24;
  static const double xxxl = 32;
}

/// Corner radii scale for cards, inputs, chips.
class AppRadii {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double pill = 999;
}

/// Elevation shadows tuned for a light theme.
class AppShadows {
  static const level1 = [
    BoxShadow(
      color: Colors.black12,
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  static const level2 = [
    BoxShadow(
      color: Colors.black26,
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];

  /// Premium soft shadow for elevated cards
  static const soft = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 24,
      offset: Offset(0, 8),
      spreadRadius: -8,
    ),
  ];

  /// Colored shadow for primary elements
  static List<BoxShadow> colored(Color color) => [
        BoxShadow(
          color: color.withOpacity(0.3),
          blurRadius: 20,
          offset: const Offset(0, 8),
          spreadRadius: -4,
        ),
      ];

  /// Inner shadow effect
  static const inner = [
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 4,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  /// Glow effect for focus states
  static List<BoxShadow> glow(Color color) => [
        BoxShadow(
          color: color.withOpacity(0.4),
          blurRadius: 16,
          offset: Offset.zero,
          spreadRadius: 2,
        ),
      ];
}

/// Modern sans typography system; add the font if bundling "Inter".
class AppTextStyles {
  static const fontFamily = 'Inter';
  static const fontFamilyFallback = [
    'Inter',
    'SF Pro Text',
    'Segoe UI',
    'Roboto',
    'Arial',
  ];

  static const h1 = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontWeight: FontWeight.w700,
    fontSize: 28,
    height: 34 / 28,
    letterSpacing: -0.2,
  );

  static const h2 = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontWeight: FontWeight.w700,
    fontSize: 24,
    height: 30 / 24,
    letterSpacing: -0.1,
  );

  static const titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontWeight: FontWeight.w700,
    fontSize: 20,
    height: 26 / 20,
  );

  static const titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontWeight: FontWeight.w600,
    fontSize: 18,
    height: 24 / 18,
  );

  static const bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontWeight: FontWeight.w500,
    fontSize: 16,
    height: 24 / 16,
  );

  static const bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontWeight: FontWeight.w500,
    fontSize: 14,
    height: 20 / 14,
  );

  static const labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontWeight: FontWeight.w600,
    fontSize: 14,
    height: 16 / 14,
  );

  static const labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontWeight: FontWeight.w600,
    fontSize: 12,
    height: 16 / 12,
  );

  static TextTheme textTheme(Color color) {
    return TextTheme(
      headlineLarge: h1.copyWith(color: color),
      headlineMedium: h2.copyWith(color: color),
      titleLarge: titleLarge.copyWith(color: color),
      titleMedium: titleMedium.copyWith(color: color),
      bodyLarge: bodyLarge.copyWith(color: color),
      bodyMedium: bodyMedium.copyWith(color: color),
      labelLarge: labelLarge.copyWith(color: color),
      labelMedium: labelMedium.copyWith(color: color),
    );
  }
}
