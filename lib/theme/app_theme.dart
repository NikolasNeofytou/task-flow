import 'package:flutter/material.dart';
import 'tokens.dart';

/// Basic ThemeData wiring to the Figma-derived color tokens.
ThemeData buildLightTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.light,
  ).copyWith(
    primary: AppColors.primary,
    onPrimary: Colors.white,
    secondary: AppColors.accent,
    onSecondary: Colors.white,
    error: AppColors.error,
    onError: Colors.white,
    surface: AppColors.surface,
    onSurface: AppColors.neutral,
    surfaceContainerHighest: AppColors.surface.withOpacity(0.9),
    tertiary: AppColors.info,
    onTertiary: Colors.white,
    outline: AppColors.neutral,
  );

  final textTheme = AppTextStyles.textTheme(colorScheme.onSurface);

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    fontFamily: AppTextStyles.fontFamily,
    scaffoldBackgroundColor: Colors.transparent,
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: const StadiumBorder(),
        textStyle: AppTextStyles.bodyLarge.copyWith(color: colorScheme.onPrimary),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shadowColor: colorScheme.primary.withOpacity(0.25),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: const StadiumBorder(),
        side: BorderSide(color: colorScheme.primary.withOpacity(0.6), width: 1.2),
        foregroundColor: colorScheme.primary,
        textStyle: AppTextStyles.bodyLarge.copyWith(color: colorScheme.primary),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      iconTheme: IconThemeData(color: colorScheme.onSurface),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: colorScheme.surfaceContainerHighest,
      selectedColor: colorScheme.primary.withOpacity(0.15),
      labelStyle: TextStyle(color: colorScheme.onSurface),
      secondaryLabelStyle: TextStyle(color: colorScheme.onSecondary),
      side: BorderSide(color: colorScheme.outline),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: colorScheme.onSurface,
      contentTextStyle: const TextStyle(color: Colors.white),
      actionTextColor: colorScheme.primary,
    ),
    navigationBarTheme: NavigationBarThemeData(
      indicatorColor: colorScheme.primary.withOpacity(0.12),
      labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      backgroundColor: Colors.white,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
    ),
    dialogTheme: DialogTheme(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
    ),
    cardTheme: CardTheme(
      color: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      elevation: 0,
      shadowColor: Colors.black12,
      margin: const EdgeInsets.all(AppSpacing.lg),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: colorScheme.primary,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        borderSide: BorderSide(color: colorScheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        borderSide: BorderSide(color: colorScheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        borderSide: BorderSide(color: colorScheme.error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
    ),
    textTheme: textTheme,
  );
}

/// Dark theme variant using the same token set.
ThemeData buildDarkTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.dark,
  ).copyWith(
    primary: AppColors.primary,
    onPrimary: Colors.white,
    secondary: AppColors.accent,
    onSecondary: Colors.white,
    error: AppColors.error,
    onError: Colors.white,
    surface: const Color(0xFF1F1F28),
    onSurface: Colors.white,
    surfaceContainerHighest: const Color(0xFF2A2A35),
    tertiary: AppColors.info,
    onTertiary: Colors.white,
    outline: Colors.white.withOpacity(0.25),
  );

  final textTheme = AppTextStyles.textTheme(colorScheme.onSurface);

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: colorScheme,
    fontFamily: AppTextStyles.fontFamily,
    scaffoldBackgroundColor: const Color(0xFF0F1117),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: const StadiumBorder(),
        textStyle: AppTextStyles.bodyLarge.copyWith(color: colorScheme.onPrimary),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shadowColor: Colors.black.withOpacity(0.35),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: const StadiumBorder(),
        side: BorderSide(color: colorScheme.primary.withOpacity(0.7), width: 1.2),
        foregroundColor: colorScheme.primary,
        textStyle: AppTextStyles.bodyLarge.copyWith(color: colorScheme.primary),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF141722),
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      iconTheme: IconThemeData(color: colorScheme.onSurface),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: colorScheme.surfaceContainerHighest,
      selectedColor: colorScheme.primary.withOpacity(0.18),
      labelStyle: TextStyle(color: colorScheme.onSurface),
      secondaryLabelStyle: TextStyle(color: colorScheme.onSecondary),
      side: BorderSide(color: colorScheme.outline),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: colorScheme.surfaceContainerHighest,
      contentTextStyle: const TextStyle(color: Colors.white),
      actionTextColor: colorScheme.primary,
    ),
    navigationBarTheme: NavigationBarThemeData(
      indicatorColor: colorScheme.primary.withOpacity(0.14),
      labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      backgroundColor: const Color(0xFF141722),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
    ),
    dialogTheme: DialogTheme(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
    ),
    cardTheme: CardTheme(
      color: const Color(0xFF1B1E28),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      elevation: 0,
      shadowColor: Colors.black45,
      margin: const EdgeInsets.all(AppSpacing.lg),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: colorScheme.primary,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        borderSide: BorderSide(color: colorScheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        borderSide: BorderSide(color: colorScheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        borderSide: BorderSide(color: colorScheme.error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
    ),
    textTheme: textTheme,
  );
}
