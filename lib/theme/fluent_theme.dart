import 'package:flutter/material.dart';
import 'fluent_tokens.dart';

/// Fluent UI Theme Generator
class FluentTheme {
  FluentTheme._();

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Color scheme based on Fluent colors
      colorScheme: ColorScheme.light(
        primary: FluentColors.primary,
        onPrimary: Colors.white,
        primaryContainer: FluentColors.primaryLight,
        onPrimaryContainer: Colors.white,
        secondary: FluentColors.accent,
        onSecondary: Colors.white,
        secondaryContainer: FluentColors.accentLight,
        onSecondaryContainer: Colors.white,
        error: FluentColors.error,
        onError: Colors.white,
        surface: Colors.white,
        onSurface: FluentColors.gray100,
        surfaceContainerHighest: FluentColors.gray30,
        outline: FluentColors.gray60,
        outlineVariant: FluentColors.gray40,
      ),
      
      // Scaffold background with Mica effect
      scaffoldBackgroundColor: FluentColors.gray20,
      
      // Card theme with Fluent elevation
      cardTheme: CardThemeData(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        shadowColor: Colors.black.withOpacity(0.07),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FluentBorderRadius.large),
          side: BorderSide(
            color: FluentColors.gray40,
            width: 1,
          ),
        ),
      ),
      
      // App bar with Fluent styling
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.white.withOpacity(0.7),
        foregroundColor: FluentColors.gray100,
        titleTextStyle: FluentTypography.title.copyWith(
          color: FluentColors.gray100,
        ),
        iconTheme: const IconThemeData(
          color: FluentColors.gray90,
        ),
        shadowColor: Colors.black.withOpacity(0.06),
      ),
      
      // Navigation bar with Fluent design
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: Colors.white.withOpacity(0.9),
        indicatorColor: FluentColors.gray30,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return FluentTypography.caption.copyWith(
              color: FluentColors.primary,
              fontWeight: FontWeight.w600,
            );
          }
          return FluentTypography.caption.copyWith(
            color: FluentColors.gray80,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: FluentColors.primary);
          }
          return const IconThemeData(color: FluentColors.gray80);
        }),
      ),
      
      // Buttons with Fluent styling
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: FluentColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: FluentSpacing.xl,
            vertical: FluentSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(FluentBorderRadius.medium),
          ),
          textStyle: FluentTypography.body.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          backgroundColor: FluentColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: FluentSpacing.xl,
            vertical: FluentSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(FluentBorderRadius.medium),
          ),
          textStyle: FluentTypography.body.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          elevation: 0,
          foregroundColor: FluentColors.gray100,
          side: const BorderSide(color: FluentColors.gray60),
          padding: const EdgeInsets.symmetric(
            horizontal: FluentSpacing.xl,
            vertical: FluentSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(FluentBorderRadius.medium),
          ),
          textStyle: FluentTypography.body.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: FluentColors.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: FluentSpacing.lg,
            vertical: FluentSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(FluentBorderRadius.medium),
          ),
          textStyle: FluentTypography.body.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: FluentColors.gray90,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(FluentBorderRadius.medium),
          ),
        ),
      ),
      
      // Input decoration with Fluent style
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: FluentSpacing.md,
          vertical: FluentSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FluentBorderRadius.medium),
          borderSide: const BorderSide(color: FluentColors.gray60),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FluentBorderRadius.medium),
          borderSide: const BorderSide(color: FluentColors.gray60),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FluentBorderRadius.medium),
          borderSide: const BorderSide(color: FluentColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FluentBorderRadius.medium),
          borderSide: const BorderSide(color: FluentColors.error),
        ),
        hintStyle: FluentTypography.body.copyWith(
          color: FluentColors.gray70,
        ),
        labelStyle: FluentTypography.body.copyWith(
          color: FluentColors.gray80,
        ),
      ),
      
      // List tile with Fluent styling
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: FluentSpacing.lg,
          vertical: FluentSpacing.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FluentBorderRadius.medium),
        ),
        titleTextStyle: FluentTypography.body.copyWith(
          color: FluentColors.gray100,
        ),
        subtitleTextStyle: FluentTypography.caption.copyWith(
          color: FluentColors.gray80,
        ),
      ),
      
      // Chip with Fluent design
      chipTheme: ChipThemeData(
        backgroundColor: FluentColors.gray30,
        selectedColor: FluentColors.primary.withOpacity(0.1),
        labelStyle: FluentTypography.caption.copyWith(
          color: FluentColors.gray100,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FluentBorderRadius.xLarge),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: FluentSpacing.md,
          vertical: FluentSpacing.xs,
        ),
      ),
      
      // Dialog with Fluent elevation
      dialogTheme: DialogThemeData(
        elevation: 0,
        backgroundColor: Colors.white,
        shadowColor: Colors.black.withOpacity(0.11),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FluentBorderRadius.large),
          side: BorderSide(
            color: FluentColors.gray40,
            width: 1,
          ),
        ),
        titleTextStyle: FluentTypography.title.copyWith(
          color: FluentColors.gray100,
        ),
        contentTextStyle: FluentTypography.body.copyWith(
          color: FluentColors.gray90,
        ),
      ),
      
      // Snackbar with Fluent design
      snackBarTheme: SnackBarThemeData(
        elevation: 0,
        backgroundColor: FluentColors.gray110,
        contentTextStyle: FluentTypography.body.copyWith(
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FluentBorderRadius.medium),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      
      // Divider with Fluent styling
      dividerTheme: const DividerThemeData(
        color: FluentColors.gray40,
        thickness: 1,
        space: 1,
      ),
      
      // Switch with Fluent colors
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return FluentColors.gray70;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return FluentColors.primary;
          }
          return FluentColors.gray50;
        }),
      ),
      
      // Checkbox with Fluent design
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return FluentColors.primary;
          }
          return Colors.transparent;
        }),
        side: const BorderSide(color: FluentColors.gray70, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FluentBorderRadius.small),
        ),
      ),
      
      // Radio with Fluent colors
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return FluentColors.primary;
          }
          return FluentColors.gray70;
        }),
      ),
      
      // Slider with Fluent styling
      sliderTheme: SliderThemeData(
        activeTrackColor: FluentColors.primary,
        inactiveTrackColor: FluentColors.gray50,
        thumbColor: Colors.white,
        overlayColor: FluentColors.primary.withOpacity(0.1),
        trackHeight: 4,
      ),
      
      // Progress indicator with Fluent colors
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: FluentColors.primary,
        linearTrackColor: FluentColors.gray40,
        circularTrackColor: FluentColors.gray40,
      ),
      
      // Tooltip with Fluent design
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: FluentColors.gray110,
          borderRadius: BorderRadius.circular(FluentBorderRadius.medium),
          boxShadow: [FluentElevation.shadow8],
        ),
        textStyle: FluentTypography.caption.copyWith(
          color: Colors.white,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: FluentSpacing.md,
          vertical: FluentSpacing.sm,
        ),
      ),
      
      // Bottom sheet with Fluent styling
      bottomSheetTheme: BottomSheetThemeData(
        elevation: 0,
        backgroundColor: Colors.white,
        shadowColor: Colors.black.withOpacity(0.11),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(FluentBorderRadius.xLarge),
          ),
        ),
      ),
      
      // Fluent motion
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
      
      // Typography
      textTheme: TextTheme(
        displayLarge: FluentTypography.display,
        displayMedium: FluentTypography.titleLarge,
        displaySmall: FluentTypography.title,
        headlineMedium: FluentTypography.subtitle,
        titleLarge: FluentTypography.title,
        titleMedium: FluentTypography.subtitle,
        titleSmall: FluentTypography.bodyStrong,
        bodyLarge: FluentTypography.body,
        bodyMedium: FluentTypography.body,
        bodySmall: FluentTypography.caption,
        labelLarge: FluentTypography.bodyStrong,
        labelMedium: FluentTypography.body,
        labelSmall: FluentTypography.caption,
      ).apply(
        bodyColor: FluentColors.gray100,
        displayColor: FluentColors.gray100,
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // Dark color scheme
      colorScheme: ColorScheme.dark(
        primary: FluentColors.primaryLight,
        onPrimary: Colors.black,
        primaryContainer: FluentColors.primary,
        onPrimaryContainer: Colors.white,
        secondary: FluentColors.accentLight,
        onSecondary: Colors.black,
        secondaryContainer: FluentColors.accent,
        onSecondaryContainer: Colors.white,
        error: FluentColors.error,
        onError: Colors.white,
        surface: FluentColors.gray120,
        onSurface: FluentColors.gray20,
        surfaceContainerHighest: FluentColors.gray110,
        outline: FluentColors.gray80,
        outlineVariant: FluentColors.gray100,
      ),
      
      scaffoldBackgroundColor: FluentColors.gray130,
      
      // Apply similar theme properties for dark mode
      // (abbreviated for brevity - follows same pattern as light theme)
      
      textTheme: TextTheme(
        displayLarge: FluentTypography.display,
        displayMedium: FluentTypography.titleLarge,
        displaySmall: FluentTypography.title,
        headlineMedium: FluentTypography.subtitle,
        titleLarge: FluentTypography.title,
        titleMedium: FluentTypography.subtitle,
        titleSmall: FluentTypography.bodyStrong,
        bodyLarge: FluentTypography.body,
        bodyMedium: FluentTypography.body,
        bodySmall: FluentTypography.caption,
        labelLarge: FluentTypography.bodyStrong,
        labelMedium: FluentTypography.body,
        labelSmall: FluentTypography.caption,
      ).apply(
        bodyColor: FluentColors.gray20,
        displayColor: FluentColors.gray20,
      ),
    );
  }
}
