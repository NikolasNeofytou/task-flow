import 'package:flutter/material.dart';
import '../theme/fluent_tokens.dart';

/// Fluent UI Primary Button
/// Standard action button with primary color
class FluentButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool isLoading;
  final IconData? icon;

  const FluentButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.isLoading = false,
    this.icon,
  });

  @override
  State<FluentButton> createState() => _FluentButtonState();
}

class _FluentButtonState extends State<FluentButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: FluentDuration.normal,
        curve: FluentCurves.standard,
        decoration: BoxDecoration(
          color: widget.onPressed == null
              ? FluentColors.gray60
              : _isHovered
                  ? FluentColors.primaryDark
                  : FluentColors.primary,
          borderRadius: BorderRadius.circular(FluentBorderRadius.medium),
          boxShadow: _isHovered && widget.onPressed != null
              ? [FluentElevation.shadow4]
              : [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.isLoading ? null : widget.onPressed,
            borderRadius: BorderRadius.circular(FluentBorderRadius.medium),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: FluentSpacing.xl,
                vertical: FluentSpacing.md,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.isLoading)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  else if (widget.icon != null) ...[
                    Icon(widget.icon, size: 16, color: Colors.white),
                    const SizedBox(width: FluentSpacing.sm),
                  ],
                  DefaultTextStyle(
                    style: FluentTypography.body.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    child: widget.child,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Fluent UI Secondary Button (Outlined)
/// Secondary action button with border
class FluentSecondaryButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final IconData? icon;

  const FluentSecondaryButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.icon,
  });

  @override
  State<FluentSecondaryButton> createState() => _FluentSecondaryButtonState();
}

class _FluentSecondaryButtonState extends State<FluentSecondaryButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: FluentDuration.normal,
        curve: FluentCurves.standard,
        decoration: BoxDecoration(
          color: _isHovered && widget.onPressed != null
              ? FluentColors.gray30
              : Colors.transparent,
          borderRadius: BorderRadius.circular(FluentBorderRadius.medium),
          border: Border.all(
            color: widget.onPressed == null
                ? FluentColors.gray60
                : FluentColors.gray70,
            width: 1.5,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius: BorderRadius.circular(FluentBorderRadius.medium),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: FluentSpacing.xl,
                vertical: FluentSpacing.md,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      size: 16,
                      color: widget.onPressed == null
                          ? FluentColors.gray60
                          : FluentColors.gray100,
                    ),
                    const SizedBox(width: FluentSpacing.sm),
                  ],
                  DefaultTextStyle(
                    style: FluentTypography.body.copyWith(
                      color: widget.onPressed == null
                          ? FluentColors.gray60
                          : FluentColors.gray100,
                      fontWeight: FontWeight.w600,
                    ),
                    child: widget.child,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Fluent UI Subtle Button (Text)
/// Minimal action button without background
class FluentSubtleButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final IconData? icon;

  const FluentSubtleButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.icon,
  });

  @override
  State<FluentSubtleButton> createState() => _FluentSubtleButtonState();
}

class _FluentSubtleButtonState extends State<FluentSubtleButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: FluentDuration.normal,
        curve: FluentCurves.standard,
        decoration: BoxDecoration(
          color: _isHovered && widget.onPressed != null
              ? FluentColors.gray30
              : Colors.transparent,
          borderRadius: BorderRadius.circular(FluentBorderRadius.medium),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius: BorderRadius.circular(FluentBorderRadius.medium),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: FluentSpacing.lg,
                vertical: FluentSpacing.md,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      size: 16,
                      color: widget.onPressed == null
                          ? FluentColors.gray60
                          : FluentColors.primary,
                    ),
                    const SizedBox(width: FluentSpacing.sm),
                  ],
                  DefaultTextStyle(
                    style: FluentTypography.body.copyWith(
                      color: widget.onPressed == null
                          ? FluentColors.gray60
                          : FluentColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    child: widget.child,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Fluent UI Icon Button
/// Small square button with icon only
class FluentIconButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final double size;
  final Color? color;
  final String? tooltip;

  const FluentIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.size = 40,
    this.color,
    this.tooltip,
  });

  @override
  State<FluentIconButton> createState() => _FluentIconButtonState();
}

class _FluentIconButtonState extends State<FluentIconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final button = MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: FluentDuration.normal,
        curve: FluentCurves.standard,
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: _isHovered && widget.onPressed != null
              ? FluentColors.gray30
              : Colors.transparent,
          borderRadius: BorderRadius.circular(FluentBorderRadius.medium),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius: BorderRadius.circular(FluentBorderRadius.medium),
            child: Icon(
              widget.icon,
              size: 20,
              color: widget.onPressed == null
                  ? FluentColors.gray60
                  : widget.color ?? FluentColors.gray90,
            ),
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      return Tooltip(
        message: widget.tooltip!,
        child: button,
      );
    }

    return button;
  }
}

/// Fluent UI FAB (Floating Action Button)
/// Primary action button with elevation
class FluentFab extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String? label;
  final bool extended;

  const FluentFab({
    super.key,
    required this.onPressed,
    required this.icon,
    this.label,
    this.extended = false,
  });

  @override
  State<FluentFab> createState() => _FluentFabState();
}

class _FluentFabState extends State<FluentFab> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: FluentDuration.normal,
        curve: FluentCurves.standard,
        decoration: BoxDecoration(
          color: _isHovered ? FluentColors.primaryDark : FluentColors.primary,
          borderRadius: BorderRadius.circular(
            widget.extended
                ? FluentBorderRadius.large
                : FluentBorderRadius.circular,
          ),
          boxShadow: [
            _isHovered ? FluentElevation.shadow16 : FluentElevation.shadow8,
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius: BorderRadius.circular(
              widget.extended
                  ? FluentBorderRadius.large
                  : FluentBorderRadius.circular,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: widget.extended ? FluentSpacing.xl : FluentSpacing.md,
                vertical: FluentSpacing.md,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(widget.icon, size: 24, color: Colors.white),
                  if (widget.extended && widget.label != null) ...[
                    const SizedBox(width: FluentSpacing.md),
                    Text(
                      widget.label!,
                      style: FluentTypography.body.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Fluent UI Accent Button
/// Primary action button with accent color
class FluentAccentButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final IconData? icon;

  const FluentAccentButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.icon,
  });

  @override
  State<FluentAccentButton> createState() => _FluentAccentButtonState();
}

class _FluentAccentButtonState extends State<FluentAccentButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: FluentDuration.normal,
        curve: FluentCurves.standard,
        decoration: BoxDecoration(
          color: widget.onPressed == null
              ? FluentColors.gray60
              : _isHovered
                  ? FluentColors.accentDark
                  : FluentColors.accent,
          borderRadius: BorderRadius.circular(FluentBorderRadius.medium),
          boxShadow: _isHovered && widget.onPressed != null
              ? [FluentElevation.shadow4]
              : [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius: BorderRadius.circular(FluentBorderRadius.medium),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: FluentSpacing.xl,
                vertical: FluentSpacing.md,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, size: 16, color: Colors.white),
                    const SizedBox(width: FluentSpacing.sm),
                  ],
                  DefaultTextStyle(
                    style: FluentTypography.body.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    child: widget.child,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
