import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// iOS 18 Glass Design Theme
/// Features glassmorphism, dynamic island aesthetics, and modern iOS design
class iOSGlassTheme {
  iOSGlassTheme._();

  // iOS 18 Color Palette
  static const _systemBlue = Color(0xFF007AFF);
  static const _systemGray = Color(0xFF8E8E93);
  static const _systemGray2 = Color(0xFFAEAEB2);
  static const _systemGray3 = Color(0xFFC7C7CC);
  static const _systemGray4 = Color(0xFFD1D1D6);
  static const _systemGray5 = Color(0xFFE5E5EA);
  static const _systemGray6 = Color(0xFFF2F2F7);
  
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // iOS-inspired color scheme
      colorScheme: const ColorScheme.light(
        primary: _systemBlue,
        onPrimary: Colors.white,
        secondary: _systemBlue,
        onSecondary: Colors.white,
        surface: _systemGray6,
        onSurface: Colors.black,
        error: Color(0xFFFF3B30),
        onError: Colors.white,
      ),
      
      scaffoldBackgroundColor: _systemGray6,
      
      // iOS-style app bar
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        scrolledUnderElevation: 0,
      ),
      
      // iOS-style cards with glass effect
      cardTheme: CardTheme(
        elevation: 0,
        color: Colors.white.withOpacity(0.7),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // iOS navigation bar
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: Colors.white.withOpacity(0.8),
        indicatorColor: _systemGray5,
        height: 65,
      ),
      
      // iOS buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: _systemBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      
      // iOS text styles
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.25,
        ),
        titleLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        labelLarge: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
      
      // iOS input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _systemGray6,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }
  
  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF0A84FF),
        onPrimary: Colors.white,
        secondary: Color(0xFF0A84FF),
        onSecondary: Colors.white,
        surface: Color(0xFF1C1C1E),
        onSurface: Colors.white,
        error: Color(0xFFFF453A),
        onError: Colors.white,
      ),
      
      scaffoldBackgroundColor: Colors.black,
      
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        scrolledUnderElevation: 0,
      ),
      
      cardTheme: CardTheme(
        elevation: 0,
        color: const Color(0xFF1C1C1E).withOpacity(0.8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: const Color(0xFF1C1C1E).withOpacity(0.9),
        indicatorColor: const Color(0xFF2C2C2E),
        height: 65,
      ),
    );
  }
}

/// iOS Glass Effect Widget
/// Creates a frosted glass blur effect like iOS 18
class iOSGlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final Color? color;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final Border? border;

  const iOSGlassContainer({
    super.key,
    required this.child,
    this.blur = 20.0,
    this.opacity = 0.7,
    this.color,
    this.borderRadius,
    this.padding,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveColor = color ?? 
        (isDark ? Colors.black : Colors.white).withOpacity(opacity);
    
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: effectiveColor,
            borderRadius: borderRadius ?? BorderRadius.circular(16),
            border: border ?? Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

/// iOS Card with Glass Effect
class iOSGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;

  const iOSGlassCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: iOSGlassContainer(
        blur: 20,
        opacity: 0.7,
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}

/// iOS List Tile with Glass Effect
class iOSGlassListTile extends StatelessWidget {
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const iOSGlassListTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return iOSGlassContainer(
      blur: 20,
      opacity: 0.7,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DefaultTextStyle(
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                  child: title,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  DefaultTextStyle(
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[600],
                    ),
                    child: subtitle!,
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 12),
            trailing!,
          ],
        ],
      ),
    );
  }
}

/// iOS Button with Glass Effect
class iOSGlassButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color? color;
  final bool isPrimary;

  const iOSGlassButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.color,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isPrimary) {
      return CupertinoButton(
        onPressed: onPressed,
        color: color ?? const Color(0xFF007AFF),
        borderRadius: BorderRadius.circular(12),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: child,
      );
    }
    
    return CupertinoButton(
      onPressed: onPressed,
      borderRadius: BorderRadius.circular(12),
      padding: EdgeInsets.zero,
      child: iOSGlassContainer(
        blur: 20,
        opacity: 0.7,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: child,
      ),
    );
  }
}

/// iOS Navigation Bar with Glass Effect
class iOSGlassNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<iOSNavigationItem> items;

  const iOSGlassNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 65,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            border: Border(
              top: BorderSide(
                color: Colors.black.withOpacity(0.1),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = currentIndex == index;
              
              return Expanded(
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => onDestinationSelected(index),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSelected ? item.selectedIcon : item.icon,
                        color: isSelected 
                            ? const Color(0xFF007AFF) 
                            : Colors.grey[600],
                        size: 28,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 10,
                          color: isSelected 
                              ? const Color(0xFF007AFF) 
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class iOSNavigationItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const iOSNavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

/// iOS Search Bar with Glass Effect
class iOSGlassSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final String? placeholder;
  final ValueChanged<String>? onChanged;

  const iOSGlassSearchBar({
    super.key,
    this.controller,
    this.placeholder,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return iOSGlassContainer(
      blur: 20,
      opacity: 0.7,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Icon(CupertinoIcons.search, color: Colors.grey[600], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: CupertinoTextField(
              controller: controller,
              placeholder: placeholder ?? 'Search',
              decoration: const BoxDecoration(),
              style: const TextStyle(fontSize: 17),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
