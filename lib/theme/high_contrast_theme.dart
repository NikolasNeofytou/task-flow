import 'package:flutter/material.dart';
import 'tokens.dart';

/// High-contrast theme for better accessibility
/// Meets WCAG AAA standards (7:1 contrast ratio)
class HighContrastTheme {
  /// High-contrast light theme
  static ThemeData buildLightTheme() {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      // Maximum contrast colors
      primary: const Color(0xFF000080), // Dark blue
      onPrimary: Colors.white,
      secondary: const Color(0xFF006400), // Dark green
      onSecondary: Colors.white,
      error: const Color(0xFF8B0000), // Dark red
      onError: Colors.white,
      surface: Colors.white,
      onSurface: Colors.black,
      surfaceContainerHighest: const Color(0xFFF5F5F5),
      outline: Colors.black,
      outlineVariant: const Color(0xFF424242),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: AppTextStyles.fontFamily,
      scaffoldBackgroundColor: Colors.white,

      // Buttons with strong contrast
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.sm),
            side: const BorderSide(color: Colors.black, width: 2),
          ),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          textStyle: AppTextStyles.bodyLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          elevation: 0,
          minimumSize: const Size(48, 48),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.sm),
          ),
          side: const BorderSide(color: Colors.black, width: 2),
          foregroundColor: Colors.black,
          textStyle: AppTextStyles.bodyLarge.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
          minimumSize: const Size(48, 48),
        ),
      ),

      // High contrast app bar
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black, size: 28),
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      // High contrast cards
      cardTheme: CardThemeData(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          side: const BorderSide(color: Colors.black, width: 2),
        ),
        elevation: 0,
        color: Colors.white,
        margin: const EdgeInsets.all(AppSpacing.lg),
      ),

      // High contrast inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          borderSide: const BorderSide(color: Colors.black, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          borderSide: const BorderSide(color: Colors.black, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          borderSide: const BorderSide(color: Colors.black, width: 3),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          borderSide: const BorderSide(color: Color(0xFF8B0000), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        labelStyle: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Navigation with high contrast
      navigationBarTheme: const NavigationBarThemeData(
        indicatorColor: Colors.black,
        backgroundColor: Colors.white,
        iconTheme: WidgetStatePropertyAll(
          IconThemeData(color: Colors.black, size: 28),
        ),
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // High contrast icons
      iconTheme: const IconThemeData(
        color: Colors.black,
        size: 28,
      ),

      // High contrast text
      textTheme: AppTextStyles.textTheme(Colors.black)
          .apply(
            displayColor: Colors.black,
            bodyColor: Colors.black,
            decorationColor: Colors.black,
          )
          .copyWith(
            headlineLarge: AppTextStyles.h1.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            headlineMedium: AppTextStyles.h2.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            titleLarge: AppTextStyles.titleLarge.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            titleMedium: AppTextStyles.titleMedium.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            bodyLarge: AppTextStyles.bodyLarge.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            bodyMedium: AppTextStyles.bodyMedium.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            labelLarge: AppTextStyles.labelLarge.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),

      // Dividers with high contrast
      dividerTheme: const DividerThemeData(
        color: Colors.black,
        thickness: 2,
      ),

      // List tiles
      listTileTheme: const ListTileThemeData(
        iconColor: Colors.black,
        textColor: Colors.black,
        minVerticalPadding: 16,
      ),
    );
  }

  /// High-contrast dark theme
  static ThemeData buildDarkTheme() {
    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      // Maximum contrast colors for dark mode
      primary: const Color(0xFF00BFFF), // Bright blue
      onPrimary: Colors.black,
      secondary: const Color(0xFF00FF7F), // Bright green
      onSecondary: Colors.black,
      error: const Color(0xFFFF4444), // Bright red
      onError: Colors.black,
      surface: Colors.black,
      onSurface: Colors.white,
      surfaceContainerHighest: const Color(0xFF1A1A1A),
      outline: Colors.white,
      outlineVariant: const Color(0xFFCCCCCC),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: AppTextStyles.fontFamily,
      scaffoldBackgroundColor: Colors.black,
      brightness: Brightness.dark,

      // Buttons with strong contrast
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.sm),
            side: const BorderSide(color: Colors.white, width: 2),
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          textStyle: AppTextStyles.bodyLarge.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
          elevation: 0,
          minimumSize: const Size(48, 48),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.sm),
          ),
          side: const BorderSide(color: Colors.white, width: 2),
          foregroundColor: Colors.white,
          textStyle: AppTextStyles.bodyLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          minimumSize: const Size(48, 48),
        ),
      ),

      // High contrast app bar
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white, size: 28),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      // High contrast cards
      cardTheme: CardThemeData(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          side: const BorderSide(color: Colors.white, width: 2),
        ),
        elevation: 0,
        color: Colors.black,
        margin: const EdgeInsets.all(AppSpacing.lg),
      ),

      // High contrast inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.black,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          borderSide: const BorderSide(color: Colors.white, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          borderSide: const BorderSide(color: Colors.white, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          borderSide: const BorderSide(color: Colors.white, width: 3),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          borderSide: const BorderSide(color: Color(0xFFFF4444), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        labelStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Navigation with high contrast
      navigationBarTheme: const NavigationBarThemeData(
        indicatorColor: Colors.white,
        backgroundColor: Colors.black,
        iconTheme: WidgetStatePropertyAll(
          IconThemeData(color: Colors.white, size: 28),
        ),
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // High contrast icons
      iconTheme: const IconThemeData(
        color: Colors.white,
        size: 28,
      ),

      // High contrast text
      textTheme: AppTextStyles.textTheme(Colors.white)
          .apply(
            displayColor: Colors.white,
            bodyColor: Colors.white,
            decorationColor: Colors.white,
          )
          .copyWith(
            headlineLarge: AppTextStyles.h1.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            headlineMedium: AppTextStyles.h2.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            titleLarge: AppTextStyles.titleLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            titleMedium: AppTextStyles.titleMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            bodyLarge: AppTextStyles.bodyLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            bodyMedium: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            labelLarge: AppTextStyles.labelLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

      // Dividers with high contrast
      dividerTheme: const DividerThemeData(
        color: Colors.white,
        thickness: 2,
      ),

      // List tiles
      listTileTheme: const ListTileThemeData(
        iconColor: Colors.white,
        textColor: Colors.white,
        minVerticalPadding: 16,
      ),
    );
  }
}
