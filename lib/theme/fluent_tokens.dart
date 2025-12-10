import 'package:flutter/material.dart';

/// Fluent UI Design System - Microsoft Design Language
/// Based on Fluent 2 Design System principles
class FluentColors {
  FluentColors._();

  // Fluent primary colors (blue spectrum)
  static const primary = Color(0xFF0078D4);
  static const primaryLight = Color(0xFF2B88D8);
  static const primaryDark = Color(0xFF005A9E);
  
  // Fluent accent colors
  static const accent = Color(0xFF8764B8);
  static const accentLight = Color(0xFF9B7BBF);
  static const accentDark = Color(0xFF744DA9);
  
  // Semantic colors
  static const success = Color(0xFF107C10);
  static const warning = Color(0xFFF7630C);
  static const error = Color(0xFFD13438);
  static const info = Color(0xFF0078D4);
  
  // Neutral colors (Fluent gray palette)
  static const gray10 = Color(0xFFFAFAFA);
  static const gray20 = Color(0xFFF5F5F5);
  static const gray30 = Color(0xFFF0F0F0);
  static const gray40 = Color(0xFFEBEBEB);
  static const gray50 = Color(0xFFE1E1E1);
  static const gray60 = Color(0xFFC8C8C8);
  static const gray70 = Color(0xFFB3B3B3);
  static const gray80 = Color(0xFF8A8A8A);
  static const gray90 = Color(0xFF616161);
  static const gray100 = Color(0xFF3B3B3B);
  static const gray110 = Color(0xFF2E2E2E);
  static const gray120 = Color(0xFF1F1F1F);
  static const gray130 = Color(0xFF141414);
}

class FluentSpacing {
  FluentSpacing._();
  
  static const xxs = 2.0;
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
  static const xxxl = 32.0;
  static const huge = 40.0;
}

class FluentBorderRadius {
  FluentBorderRadius._();
  
  static const none = 0.0;
  static const small = 2.0;
  static const medium = 4.0;
  static const large = 8.0;
  static const xLarge = 12.0;
  static const circular = 999.0;
}

class FluentElevation {
  FluentElevation._();
  
  // Shadow definitions
  static BoxShadow shadow2 = BoxShadow(
    color: Colors.black.withOpacity(0.06),
    blurRadius: 2,
    offset: const Offset(0, 0.3),
  );
  
  static BoxShadow shadow4 = BoxShadow(
    color: Colors.black.withOpacity(0.07),
    blurRadius: 4,
    offset: const Offset(0, 0.9),
  );
  
  static BoxShadow shadow8 = BoxShadow(
    color: Colors.black.withOpacity(0.09),
    blurRadius: 8,
    offset: const Offset(0, 1.6),
  );
  
  static BoxShadow shadow16 = BoxShadow(
    color: Colors.black.withOpacity(0.11),
    blurRadius: 16,
    offset: const Offset(0, 3.2),
  );
  
  static BoxShadow shadow28 = BoxShadow(
    color: Colors.black.withOpacity(0.13),
    blurRadius: 28,
    offset: const Offset(0, 6.4),
  );
  
  static BoxShadow shadow64 = BoxShadow(
    color: Colors.black.withOpacity(0.17),
    blurRadius: 64,
    offset: const Offset(0, 12.8),
  );
  
  // Preset shadow combinations
  static List<BoxShadow> get card => [shadow4];
  static List<BoxShadow> get dialogShadow => [shadow16];
  static List<BoxShadow> get appBar => [shadow2];
}

class FluentTypography {
  FluentTypography._();
  
  // Fluent typography scale
  static const String fontFamily = 'Segoe UI';
  
  static const caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.33,
  );
  
  static const body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.43,
  );
  
  static const bodyStrong = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.43,
  );
  
  static const subtitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );
  
  static const title = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );
  
  static const titleLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.33,
  );
  
  static const display = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    height: 1.25,
  );
}

/// Fluent motion/animation durations
class FluentDuration {
  FluentDuration._();
  
  static const ultraFast = Duration(milliseconds: 50);
  static const faster = Duration(milliseconds: 100);
  static const fast = Duration(milliseconds: 150);
  static const normal = Duration(milliseconds: 200);
  static const slow = Duration(milliseconds: 300);
  static const slower = Duration(milliseconds: 400);
  static const ultraSlow = Duration(milliseconds: 500);
}

/// Fluent motion curves
class FluentCurves {
  FluentCurves._();
  
  static const linear = Curves.linear;
  static const accelerate = Cubic(0.7, 0.0, 1.0, 1.0);
  static const decelerate = Cubic(0.1, 0.9, 0.2, 1.0);
  static const standard = Cubic(0.8, 0.0, 0.2, 1.0);
  static const entrance = Cubic(0.0, 0.0, 0.0, 1.0);
  static const exit = Cubic(0.1, 0.0, 1.0, 1.0);
}

/// Acrylic material effect (Fluent design signature)
class FluentAcrylic {
  FluentAcrylic._();
  
  static BoxDecoration light({double opacity = 0.9}) {
    return BoxDecoration(
      color: Colors.white.withOpacity(opacity),
      border: Border.all(
        color: Colors.white.withOpacity(0.2),
        width: 1,
      ),
      boxShadow: FluentElevation.card,
    );
  }
  
  static BoxDecoration dark({double opacity = 0.7}) {
    return BoxDecoration(
      color: FluentColors.gray120.withOpacity(opacity),
      border: Border.all(
        color: Colors.white.withOpacity(0.08),
        width: 1,
      ),
      boxShadow: FluentElevation.card,
    );
  }
  
  static BoxDecoration accentLight({double opacity = 0.9}) {
    return BoxDecoration(
      color: FluentColors.primary.withOpacity(opacity),
      border: Border.all(
        color: Colors.white.withOpacity(0.3),
        width: 1,
      ),
      boxShadow: FluentElevation.card,
    );
  }
}

/// Mica material effect (Windows 11 style)
class FluentMica {
  FluentMica._();
  
  static BoxDecoration base({bool isDark = false}) {
    return BoxDecoration(
      color: isDark ? FluentColors.gray130 : FluentColors.gray20,
      backgroundBlendMode: BlendMode.luminosity,
    );
  }
  
  static BoxDecoration alt({bool isDark = false}) {
    return BoxDecoration(
      color: isDark ? FluentColors.gray120 : FluentColors.gray10,
      backgroundBlendMode: BlendMode.luminosity,
    );
  }
}

/// Fluent reveal effect (hover highlight)
class FluentReveal {
  FluentReveal._();
  
  static BoxDecoration light({bool isHovered = false}) {
    return BoxDecoration(
      color: isHovered
          ? Colors.black.withOpacity(0.03)
          : Colors.transparent,
      border: Border.all(
        color: isHovered
            ? Colors.black.withOpacity(0.08)
            : Colors.transparent,
      ),
      borderRadius: BorderRadius.circular(FluentBorderRadius.medium),
    );
  }
  
  static BoxDecoration dark({bool isHovered = false}) {
    return BoxDecoration(
      color: isHovered
          ? Colors.white.withOpacity(0.06)
          : Colors.transparent,
      border: Border.all(
        color: isHovered
            ? Colors.white.withOpacity(0.1)
            : Colors.transparent,
      ),
      borderRadius: BorderRadius.circular(FluentBorderRadius.medium),
    );
  }
}

/// Fluent layer depths (z-index equivalents)
class FluentLayers {
  FluentLayers._();
  
  static const background = 0;
  static const content = 1;
  static const card = 2;
  static const flyout = 4;
  static const dialog = 8;
  static const tooltip = 16;
}
