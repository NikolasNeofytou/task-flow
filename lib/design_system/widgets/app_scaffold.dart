import 'package:flutter/material.dart';

/// Backdrop that adapts to theme brightness.
class AppScaffold extends StatelessWidget {
  const AppScaffold({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: isDark ? const Color(0xFF0F1117) : const Color(0xFFF5F7FA),
      child: child,
    );
  }
}
