import 'package:flutter/material.dart';

/// High contrast theme definitions for improved visibility
/// Meets WCAG AAA standards with 7:1 contrast ratios

class HighContrastThemes {
  /// High contrast light theme
  static ThemeData lightHighContrast() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Primary colors with maximum contrast
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF000000),           // Pure black
        onPrimary: Color(0xFFFFFFFF),        // Pure white
        primaryContainer: Color(0xFF000000),
        onPrimaryContainer: Color(0xFFFFFFFF),
        
        secondary: Color(0xFF000000),
        onSecondary: Color(0xFFFFFFFF),
        secondaryContainer: Color(0xFFE0E0E0),
        onSecondaryContainer: Color(0xFF000000),
        
        error: Color(0xFF8B0000),            // Dark red
        onError: Color(0xFFFFFFFF),
        errorContainer: Color(0xFF8B0000),
        onErrorContainer: Color(0xFFFFFFFF),
        
        surface: Color(0xFFFFFFFF),
        onSurface: Color(0xFF000000),
        surfaceContainerHighest: Color(0xFFF0F0F0),
        onSurfaceVariant: Color(0xFF000000),
        
        outline: Color(0xFF000000),
        shadow: Color(0xFF000000),
      ),
      
      // Typography with increased weight
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 57,
          fontWeight: FontWeight.bold,
          color: Color(0xFF000000),
        ),
        displayMedium: TextStyle(
          fontSize: 45,
          fontWeight: FontWeight.bold,
          color: Color(0xFF000000),
        ),
        displaySmall: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: Color(0xFF000000),
        ),
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Color(0xFF000000),
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Color(0xFF000000),
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xFF000000),
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: Color(0xFF000000),
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Color(0xFF000000),
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Color(0xFF000000),
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF000000),
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF000000),
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF000000),
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Color(0xFF000000),
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF000000),
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFF000000),
        ),
      ),
      
      // Enhanced component themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF000000),
          foregroundColor: const Color(0xFFFFFFFF),
          minimumSize: const Size(48, 48),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF000000),
          side: const BorderSide(color: Color(0xFF000000), width: 2),
          minimumSize: const Size(48, 48),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      
      iconTheme: const IconThemeData(
        color: Color(0xFF000000),
        size: 28,
      ),
      
      dividerTheme: const DividerThemeData(
        color: Color(0xFF000000),
        thickness: 2,
      ),
    );
  }
  
  /// High contrast dark theme
  static ThemeData darkHighContrast() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // Primary colors with maximum contrast
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFFFFFFF),           // Pure white
        onPrimary: Color(0xFF000000),        // Pure black
        primaryContainer: Color(0xFFFFFFFF),
        onPrimaryContainer: Color(0xFF000000),
        
        secondary: Color(0xFFFFFFFF),
        onSecondary: Color(0xFF000000),
        secondaryContainer: Color(0xFF2A2A2A),
        onSecondaryContainer: Color(0xFFFFFFFF),
        
        error: Color(0xFFFF6B6B),            // Bright red
        onError: Color(0xFF000000),
        errorContainer: Color(0xFFFF6B6B),
        onErrorContainer: Color(0xFF000000),     // Pure white
        
        surface: Color(0xFF000000),
        onSurface: Color(0xFFFFFFFF),
        surfaceContainerHighest: Color(0xFF1A1A1A),
        onSurfaceVariant: Color(0xFFFFFFFF),
        
        outline: Color(0xFFFFFFFF),
        shadow: Color(0xFFFFFFFF),
      ),
      
      // Typography with increased weight
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 57,
          fontWeight: FontWeight.bold,
          color: Color(0xFFFFFFFF),
        ),
        displayMedium: TextStyle(
          fontSize: 45,
          fontWeight: FontWeight.bold,
          color: Color(0xFFFFFFFF),
        ),
        displaySmall: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: Color(0xFFFFFFFF),
        ),
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Color(0xFFFFFFFF),
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Color(0xFFFFFFFF),
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xFFFFFFFF),
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: Color(0xFFFFFFFF),
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Color(0xFFFFFFFF),
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Color(0xFFFFFFFF),
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFFFFFFFF),
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFFFFFFFF),
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFFFFFFFF),
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Color(0xFFFFFFFF),
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFFFFFFFF),
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFFFFFFFF),
        ),
      ),
      
      // Enhanced component themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFFFFF),
          foregroundColor: const Color(0xFF000000),
          minimumSize: const Size(48, 48),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFFFFFFF),
          side: const BorderSide(color: Color(0xFFFFFFFF), width: 2),
          minimumSize: const Size(48, 48),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      
      iconTheme: const IconThemeData(
        color: Color(0xFFFFFFFF),
        size: 28,
      ),
      
      dividerTheme: const DividerThemeData(
        color: Color(0xFFFFFFFF),
        thickness: 2,
      ),
    );
  }
}

/// Color blind friendly palettes
class ColorBlindPalettes {
  /// Deuteranopia (red-green color blindness) friendly colors
  static const deuteranopia = ColorBlindPalette(
    primary: Color(0xFF0077BB),      // Blue
    secondary: Color(0xFFEE7733),    // Orange
    success: Color(0xFF009988),      // Teal
    warning: Color(0xFFEE7733),      // Orange
    error: Color(0xFFCC3311),        // Red
    info: Color(0xFF0077BB),         // Blue
    neutral: Color(0xFF999999),      // Gray
  );
  
  /// Protanopia (red color blindness) friendly colors
  static const protanopia = ColorBlindPalette(
    primary: Color(0xFF0077BB),      // Blue
    secondary: Color(0xFFCC79A7),    // Pink
    success: Color(0xFF009988),      // Teal
    warning: Color(0xFFEE7733),      // Orange
    error: Color(0xFF882255),        // Purple
    info: Color(0xFF0077BB),         // Blue
    neutral: Color(0xFF999999),      // Gray
  );
  
  /// Tritanopia (blue-yellow color blindness) friendly colors
  static const tritanopia = ColorBlindPalette(
    primary: Color(0xFFCC3311),      // Red
    secondary: Color(0xFF009988),    // Teal
    success: Color(0xFF009988),      // Teal
    warning: Color(0xFFEE7733),      // Orange
    error: Color(0xFFCC3311),        // Red
    info: Color(0xFF44AA99),         // Aqua
    neutral: Color(0xFF999999),      // Gray
  );
}

class ColorBlindPalette {
  final Color primary;
  final Color secondary;
  final Color success;
  final Color warning;
  final Color error;
  final Color info;
  final Color neutral;
  
  const ColorBlindPalette({
    required this.primary,
    required this.secondary,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
    required this.neutral,
  });
}

/// Accessible text size presets
enum TextSizePreset {
  small,
  medium,
  large,
  extraLarge,
}

class AccessibleTextSizes {
  static TextTheme getTextTheme(TextSizePreset preset) {
    switch (preset) {
      case TextSizePreset.small:
        return _smallTextTheme;
      case TextSizePreset.medium:
        return _mediumTextTheme;
      case TextSizePreset.large:
        return _largeTextTheme;
      case TextSizePreset.extraLarge:
        return _extraLargeTextTheme;
    }
  }
  
  static const _smallTextTheme = TextTheme(
    displayLarge: TextStyle(fontSize: 48),
    displayMedium: TextStyle(fontSize: 38),
    displaySmall: TextStyle(fontSize: 30),
    headlineLarge: TextStyle(fontSize: 27),
    headlineMedium: TextStyle(fontSize: 23),
    headlineSmall: TextStyle(fontSize: 20),
    titleLarge: TextStyle(fontSize: 18),
    titleMedium: TextStyle(fontSize: 14),
    titleSmall: TextStyle(fontSize: 12),
    bodyLarge: TextStyle(fontSize: 14),
    bodyMedium: TextStyle(fontSize: 12),
    bodySmall: TextStyle(fontSize: 10),
    labelLarge: TextStyle(fontSize: 12),
    labelMedium: TextStyle(fontSize: 10),
    labelSmall: TextStyle(fontSize: 9),
  );
  
  static const _mediumTextTheme = TextTheme(
    displayLarge: TextStyle(fontSize: 57),
    displayMedium: TextStyle(fontSize: 45),
    displaySmall: TextStyle(fontSize: 36),
    headlineLarge: TextStyle(fontSize: 32),
    headlineMedium: TextStyle(fontSize: 28),
    headlineSmall: TextStyle(fontSize: 24),
    titleLarge: TextStyle(fontSize: 22),
    titleMedium: TextStyle(fontSize: 16),
    titleSmall: TextStyle(fontSize: 14),
    bodyLarge: TextStyle(fontSize: 16),
    bodyMedium: TextStyle(fontSize: 14),
    bodySmall: TextStyle(fontSize: 12),
    labelLarge: TextStyle(fontSize: 14),
    labelMedium: TextStyle(fontSize: 12),
    labelSmall: TextStyle(fontSize: 11),
  );
  
  static const _largeTextTheme = TextTheme(
    displayLarge: TextStyle(fontSize: 68),
    displayMedium: TextStyle(fontSize: 54),
    displaySmall: TextStyle(fontSize: 43),
    headlineLarge: TextStyle(fontSize: 38),
    headlineMedium: TextStyle(fontSize: 34),
    headlineSmall: TextStyle(fontSize: 29),
    titleLarge: TextStyle(fontSize: 26),
    titleMedium: TextStyle(fontSize: 19),
    titleSmall: TextStyle(fontSize: 17),
    bodyLarge: TextStyle(fontSize: 19),
    bodyMedium: TextStyle(fontSize: 17),
    bodySmall: TextStyle(fontSize: 14),
    labelLarge: TextStyle(fontSize: 17),
    labelMedium: TextStyle(fontSize: 14),
    labelSmall: TextStyle(fontSize: 13),
  );
  
  static const _extraLargeTextTheme = TextTheme(
    displayLarge: TextStyle(fontSize: 80),
    displayMedium: TextStyle(fontSize: 63),
    displaySmall: TextStyle(fontSize: 50),
    headlineLarge: TextStyle(fontSize: 45),
    headlineMedium: TextStyle(fontSize: 39),
    headlineSmall: TextStyle(fontSize: 34),
    titleLarge: TextStyle(fontSize: 31),
    titleMedium: TextStyle(fontSize: 22),
    titleSmall: TextStyle(fontSize: 20),
    bodyLarge: TextStyle(fontSize: 22),
    bodyMedium: TextStyle(fontSize: 20),
    bodySmall: TextStyle(fontSize: 17),
    labelLarge: TextStyle(fontSize: 20),
    labelMedium: TextStyle(fontSize: 17),
    labelSmall: TextStyle(fontSize: 15),
  );
}
