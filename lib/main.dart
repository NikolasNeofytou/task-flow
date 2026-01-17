import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'app_router.dart';
import 'core/providers/feedback_providers.dart';
import 'core/providers/deep_link_providers.dart';
import 'core/services/deep_link_service.dart';

import 'theme/fluent_theme.dart';
import 'theme/accessible_themes.dart' show HighContrastThemes, TextSizePreset;

import 'features/settings/presentation/theme_customization_screen.dart'
    show themeCustomizationProvider, ThemeCustomization;
import 'features/settings/presentation/accessibility_settings_screen.dart'
    show accessibilitySettingsProvider;

void main() {
  runApp(const ProviderScope(child: TaskflowApp()));
}

class TaskflowApp extends ConsumerStatefulWidget {
  const TaskflowApp({super.key});

  @override
  ConsumerState<TaskflowApp> createState() => _TaskflowAppState();
}

class _TaskflowAppState extends ConsumerState<TaskflowApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();

    _router = createRouter();

    // Initialize services
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Feedback services
      await ref.read(feedbackServiceProvider).initialize();
      ref.read(feedbackSettingsProvider);

      // Deep link handling
      final deepLinkService = ref.read(deepLinkServiceProvider);

      final initialUri = await deepLinkService.initialize();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }

      deepLinkService.startListening(_handleDeepLink);
    });
  }

  void _handleDeepLink(Uri uri) {
    final deepLinkService = ref.read(deepLinkServiceProvider);
    final linkData = deepLinkService.parseDeepLink(uri);

    if (linkData == null) {
      debugPrint('❌ Failed to parse deep link: $uri');
      return;
    }

    debugPrint('✅ Handling deep link: $linkData');

    switch (linkData.type) {
      case DeepLinkType.invite:
        _router.push(
          '/invite/accept',
          extra: {
            'projectId': linkData.projectId,
            'token': linkData.token,
          },
        );
        break;

      case DeepLinkType.project:
        _router.go('/projects/${linkData.projectId}');
        break;

      case DeepLinkType.notification:
        // Full path is /inbox/notification/:id in your router
        _router.push('/inbox/notification/${linkData.notificationId}');
        break;

      case DeepLinkType.task:
        // Your router needs projectId to open task details (nested route)
        debugPrint('ℹ️ Task deep link received, but route is nested (needs projectId).');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Theme (colors + Light/Dark/Auto)
    final customization = ref.watch(themeCustomizationProvider);

    // Accessibility (text size, bold, high contrast, reduce animations, etc.)
    final a11y = ref.watch(accessibilitySettingsProvider);

    // Base themes
    ThemeData lightTheme =
        a11y.highContrastMode ? HighContrastThemes.lightHighContrast() : FluentTheme.light();
    ThemeData darkTheme =
        a11y.highContrastMode ? HighContrastThemes.darkHighContrast() : FluentTheme.dark();

    // Apply custom colors (skip when in High Contrast for max readability)
    if (!a11y.highContrastMode) {
      lightTheme = _applyThemeCustomization(lightTheme, customization);
      darkTheme = _applyThemeCustomization(darkTheme, customization);
    }

    // Bold globally
    if (a11y.boldText) {
      lightTheme = _boldifyTheme(lightTheme);
      darkTheme = _boldifyTheme(darkTheme);
    }

    // Bigger touch targets
    if (a11y.increaseTouchTargets) {
      lightTheme = lightTheme.copyWith(materialTapTargetSize: MaterialTapTargetSize.padded);
      darkTheme = darkTheme.copyWith(materialTapTargetSize: MaterialTapTargetSize.padded);
    }

    return MaterialApp.router(
      title: 'GroupUp',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: customization.themeMode,
      routerConfig: _router,
      builder: (context, child) {
        final mq = MediaQuery.of(context);

        return MediaQuery(
          data: mq.copyWith(
            textScaler: TextScaler.linear(_textScaleFromPreset(a11y.textSizePreset)),
            boldText: a11y.boldText,
            highContrast: a11y.highContrastMode,
            disableAnimations: a11y.reduceAnimations,
            accessibleNavigation: a11y.screenReaderOptimized,
          ),
          child: TickerMode(
            enabled: !a11y.reduceAnimations,
            child: child!,
          ),
        );
      },
    );
  }
}

/* -------------------- Helpers -------------------- */

double _textScaleFromPreset(TextSizePreset preset) {
  switch (preset) {
    case TextSizePreset.small:
      return 0.90;
    case TextSizePreset.medium:
      return 1.00;
    case TextSizePreset.large:
      return 1.15;
    case TextSizePreset.extraLarge:
      return 1.30;
  }
}

ThemeData _applyThemeCustomization(ThemeData base, ThemeCustomization c) {
  final brightness = base.brightness;
  final primary = c.primaryColor;
  final secondary = c.secondaryColor;

  final primaryContainer =
      brightness == Brightness.light ? _tint(primary, 0.80) : _shade(primary, 0.40);
  final secondaryContainer =
      brightness == Brightness.light ? _tint(secondary, 0.80) : _shade(secondary, 0.40);

  final cs = base.colorScheme.copyWith(
    primary: primary,
    onPrimary: _onColor(primary),
    primaryContainer: primaryContainer,
    onPrimaryContainer: _onColor(primaryContainer),
    secondary: secondary,
    onSecondary: _onColor(secondary),
    secondaryContainer: secondaryContainer,
    onSecondaryContainer: _onColor(secondaryContainer),
  );

  // Override FluentTheme hardcoded colors (buttons / nav / focused inputs)
  final navTheme = base.navigationBarTheme.copyWith(
    indicatorColor: primary.withOpacity(brightness == Brightness.light ? 0.12 : 0.24),
    labelTextStyle: WidgetStateProperty.resolveWith((states) {
      final isSel = states.contains(WidgetState.selected);
      final ts = base.navigationBarTheme.labelTextStyle?.resolve(states);
      return (ts ?? const TextStyle(fontSize: 12)).copyWith(
        color: isSel ? primary : cs.onSurface.withOpacity(0.65),
      );
    }),
    iconTheme: WidgetStateProperty.resolveWith((states) {
      final isSel = states.contains(WidgetState.selected);
      return IconThemeData(color: isSel ? primary : cs.onSurface.withOpacity(0.65));
    }),
  );

  final inputTheme = base.inputDecorationTheme.copyWith(
    focusedBorder: _borderWithColor(base.inputDecorationTheme.focusedBorder, primary, width: 2),
  );

  return base.copyWith(
    colorScheme: cs,
    primaryColor: primary,
    navigationBarTheme: navTheme,
    inputDecorationTheme: inputTheme,
    progressIndicatorTheme: base.progressIndicatorTheme.copyWith(color: primary),
    floatingActionButtonTheme: base.floatingActionButtonTheme.copyWith(
      backgroundColor: primary,
      foregroundColor: _onColor(primary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: _filledButtonStyle(base.elevatedButtonTheme.style, primary, _onColor(primary)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: _filledButtonStyle(base.filledButtonTheme.style, primary, _onColor(primary)),
    ),
    textButtonTheme: TextButtonThemeData(
      style: _textButtonStyle(base.textButtonTheme.style, primary),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: _outlinedButtonStyle(base.outlinedButtonTheme.style, primary),
    ),
  );
}

ButtonStyle _filledButtonStyle(ButtonStyle? base, Color bg, Color fg) {
  final s = base ?? const ButtonStyle();
  return s.copyWith(
    backgroundColor: WidgetStatePropertyAll(bg),
    foregroundColor: WidgetStatePropertyAll(fg),
  );
}

ButtonStyle _textButtonStyle(ButtonStyle? base, Color fg) {
  final s = base ?? const ButtonStyle();
  return s.copyWith(foregroundColor: WidgetStatePropertyAll(fg));
}

ButtonStyle _outlinedButtonStyle(ButtonStyle? base, Color fg) {
  final s = base ?? const ButtonStyle();
  return s.copyWith(
    foregroundColor: WidgetStatePropertyAll(fg),
    side: WidgetStatePropertyAll(BorderSide(color: fg)),
  );
}

InputBorder? _borderWithColor(InputBorder? border, Color color, {double width = 1}) {
  if (border is OutlineInputBorder) {
    return border.copyWith(borderSide: BorderSide(color: color, width: width));
  }
  if (border == null) {
    return OutlineInputBorder(borderSide: BorderSide(color: color, width: width));
  }
  return border;
}

Color _onColor(Color bg) => bg.computeLuminance() > 0.55 ? Colors.black : Colors.white;
Color _tint(Color c, double amount) => Color.lerp(c, Colors.white, amount) ?? c;
Color _shade(Color c, double amount) => Color.lerp(c, Colors.black, amount) ?? c;

ThemeData _boldifyTheme(ThemeData base) {
  TextStyle? b(TextStyle? s) => s?.copyWith(fontWeight: FontWeight.bold);

  TextTheme bt(TextTheme t) => t.copyWith(
        displayLarge: b(t.displayLarge),
        displayMedium: b(t.displayMedium),
        displaySmall: b(t.displaySmall),
        headlineLarge: b(t.headlineLarge),
        headlineMedium: b(t.headlineMedium),
        headlineSmall: b(t.headlineSmall),
        titleLarge: b(t.titleLarge),
        titleMedium: b(t.titleMedium),
        titleSmall: b(t.titleSmall),
        bodyLarge: b(t.bodyLarge),
        bodyMedium: b(t.bodyMedium),
        bodySmall: b(t.bodySmall),
        labelLarge: b(t.labelLarge),
        labelMedium: b(t.labelMedium),
        labelSmall: b(t.labelSmall),
      );

  return base.copyWith(
    textTheme: bt(base.textTheme),
    primaryTextTheme: bt(base.primaryTextTheme),
  );
}
