import 'package:flutter/material.dart';
import '../theme/fluent_tokens.dart';

/// Fluent UI Card with Standard Elevation
/// Basic card with subtle shadow and border
class FluentCard extends StatefulWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final bool withBorder;

  const FluentCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.backgroundColor,
    this.withBorder = true,
  });

  @override
  State<FluentCard> createState() => _FluentCardState();
}

class _FluentCardState extends State<FluentCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: widget.onTap != null ? (_) => setState(() => _isHovered = true) : null,
      onExit: widget.onTap != null ? (_) => setState(() => _isHovered = false) : null,
      child: AnimatedContainer(
        duration: FluentDuration.normal,
        curve: FluentCurves.standard,
        decoration: BoxDecoration(
          color: widget.backgroundColor ??
              (isDark ? FluentColors.gray120 : Colors.white),
          borderRadius: BorderRadius.circular(FluentBorderRadius.large),
          border: widget.withBorder
              ? Border.all(
                  color: isDark ? FluentColors.gray100 : FluentColors.gray40,
                  width: 1,
                )
              : null,
          boxShadow: _isHovered && widget.onTap != null
              ? [FluentElevation.shadow8]
              : [FluentElevation.shadow4],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(FluentBorderRadius.large),
            child: Padding(
              padding: widget.padding ?? const EdgeInsets.all(FluentSpacing.lg),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Fluent UI Card with Acrylic Effect
/// Card with translucent Acrylic background
class FluentAcrylicCard extends StatefulWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final bool useDarkAcrylic;

  const FluentAcrylicCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.useDarkAcrylic = false,
  });

  @override
  State<FluentAcrylicCard> createState() => _FluentAcrylicCardState();
}

class _FluentAcrylicCardState extends State<FluentAcrylicCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: widget.onTap != null ? (_) => setState(() => _isHovered = true) : null,
      onExit: widget.onTap != null ? (_) => setState(() => _isHovered = false) : null,
      child: AnimatedContainer(
        duration: FluentDuration.normal,
        curve: FluentCurves.standard,
        decoration: widget.useDarkAcrylic
            ? FluentAcrylic.dark()
            : FluentAcrylic.light(),
        child: AnimatedScale(
          duration: FluentDuration.normal,
          curve: FluentCurves.standard,
          scale: _isHovered && widget.onTap != null ? 1.02 : 1.0,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(FluentBorderRadius.large),
              child: Padding(
                padding: widget.padding ?? const EdgeInsets.all(FluentSpacing.lg),
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Fluent UI Card with Mica Effect
/// Card with Mica material background (Windows 11 style)
class FluentMicaCard extends StatefulWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final bool useAltMica;

  const FluentMicaCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.useAltMica = false,
  });

  @override
  State<FluentMicaCard> createState() => _FluentMicaCardState();
}

class _FluentMicaCardState extends State<FluentMicaCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: widget.onTap != null ? (_) => setState(() => _isHovered = true) : null,
      onExit: widget.onTap != null ? (_) => setState(() => _isHovered = false) : null,
      child: AnimatedContainer(
        duration: FluentDuration.normal,
        curve: FluentCurves.standard,
        decoration: widget.useAltMica ? FluentMica.alt() : FluentMica.base(),
        child: AnimatedScale(
          duration: FluentDuration.normal,
          curve: FluentCurves.standard,
          scale: _isHovered && widget.onTap != null ? 1.02 : 1.0,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(FluentBorderRadius.large),
              child: Padding(
                padding: widget.padding ?? const EdgeInsets.all(FluentSpacing.lg),
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Fluent UI Elevated Card
/// Card with more prominent elevation
class FluentElevatedCard extends StatefulWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;

  const FluentElevatedCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.backgroundColor,
  });

  @override
  State<FluentElevatedCard> createState() => _FluentElevatedCardState();
}

class _FluentElevatedCardState extends State<FluentElevatedCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: widget.onTap != null ? (_) => setState(() => _isHovered = true) : null,
      onExit: widget.onTap != null ? (_) => setState(() => _isHovered = false) : null,
      child: AnimatedContainer(
        duration: FluentDuration.normal,
        curve: FluentCurves.standard,
        decoration: BoxDecoration(
          color: widget.backgroundColor ??
              (isDark ? FluentColors.gray120 : Colors.white),
          borderRadius: BorderRadius.circular(FluentBorderRadius.large),
          boxShadow: _isHovered && widget.onTap != null
              ? [FluentElevation.shadow28]
              : [FluentElevation.shadow16],
        ),
        child: AnimatedScale(
          duration: FluentDuration.normal,
          curve: FluentCurves.standard,
          scale: _isHovered && widget.onTap != null ? 1.02 : 1.0,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(FluentBorderRadius.large),
              child: Padding(
                padding: widget.padding ?? const EdgeInsets.all(FluentSpacing.lg),
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Fluent UI Info Card
/// Card with colored border and icon
class FluentInfoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color accentColor;
  final IconData? icon;
  final String? title;

  const FluentInfoCard({
    super.key,
    required this.child,
    this.padding,
    this.accentColor = FluentColors.info,
    this.icon,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? FluentColors.gray120 : Colors.white,
        borderRadius: BorderRadius.circular(FluentBorderRadius.large),
        border: Border.all(
          color: accentColor,
          width: 2,
        ),
        boxShadow: [FluentElevation.shadow4],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null || title != null)
            Container(
              padding: const EdgeInsets.all(FluentSpacing.md),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(FluentBorderRadius.large - 2),
                  topRight: Radius.circular(FluentBorderRadius.large - 2),
                ),
              ),
              child: Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: accentColor, size: 20),
                    const SizedBox(width: FluentSpacing.sm),
                  ],
                  if (title != null)
                    Text(
                      title!,
                      style: FluentTypography.bodyStrong.copyWith(
                        color: accentColor,
                      ),
                    ),
                ],
              ),
            ),
          Padding(
            padding: padding ?? const EdgeInsets.all(FluentSpacing.lg),
            child: child,
          ),
        ],
      ),
    );
  }
}

/// Fluent UI List Tile
/// Fluent-styled list item
class FluentListTile extends StatefulWidget {
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsets? padding;

  const FluentListTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.padding,
  });

  @override
  State<FluentListTile> createState() => _FluentListTileState();
}

class _FluentListTileState extends State<FluentListTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: widget.onTap != null ? (_) => setState(() => _isHovered = true) : null,
      onExit: widget.onTap != null ? (_) => setState(() => _isHovered = false) : null,
      child: AnimatedContainer(
        duration: FluentDuration.fast,
        curve: FluentCurves.standard,
        decoration: BoxDecoration(
          color: _isHovered && widget.onTap != null
              ? FluentColors.gray30
              : Colors.transparent,
          borderRadius: BorderRadius.circular(FluentBorderRadius.medium),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(FluentBorderRadius.medium),
            child: Padding(
              padding: widget.padding ??
                  const EdgeInsets.symmetric(
                    horizontal: FluentSpacing.lg,
                    vertical: FluentSpacing.md,
                  ),
              child: Row(
                children: [
                  if (widget.leading != null) ...[
                    widget.leading!,
                    const SizedBox(width: FluentSpacing.md),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DefaultTextStyle(
                          style: FluentTypography.body.copyWith(
                            color: FluentColors.gray100,
                          ),
                          child: widget.title,
                        ),
                        if (widget.subtitle != null) ...[
                          const SizedBox(height: FluentSpacing.xxs),
                          DefaultTextStyle(
                            style: FluentTypography.caption.copyWith(
                              color: FluentColors.gray80,
                            ),
                            child: widget.subtitle!,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (widget.trailing != null) ...[
                    const SizedBox(width: FluentSpacing.md),
                    widget.trailing!,
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

/// Fluent UI Chip
/// Tag or filter chip with Fluent styling
class FluentChip extends StatefulWidget {
  final Widget label;
  final IconData? icon;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final Color? color;
  final bool selected;

  const FluentChip({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.onDelete,
    this.color,
    this.selected = false,
  });

  @override
  State<FluentChip> createState() => _FluentChipState();
}

class _FluentChipState extends State<FluentChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = widget.color ?? FluentColors.primary;
    final backgroundColor = widget.selected
        ? effectiveColor.withOpacity(0.1)
        : FluentColors.gray30;

    return MouseRegion(
      onEnter: widget.onTap != null ? (_) => setState(() => _isHovered = true) : null,
      onExit: widget.onTap != null ? (_) => setState(() => _isHovered = false) : null,
      child: AnimatedContainer(
        duration: FluentDuration.fast,
        curve: FluentCurves.standard,
        decoration: BoxDecoration(
          color: _isHovered && widget.onTap != null
              ? (widget.selected
                  ? effectiveColor.withOpacity(0.15)
                  : FluentColors.gray40)
              : backgroundColor,
          borderRadius: BorderRadius.circular(FluentBorderRadius.xLarge),
          border: widget.selected
              ? Border.all(color: effectiveColor, width: 1)
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(FluentBorderRadius.xLarge),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: FluentSpacing.md,
                vertical: FluentSpacing.xs,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      size: 14,
                      color: widget.selected ? effectiveColor : FluentColors.gray90,
                    ),
                    const SizedBox(width: FluentSpacing.xs),
                  ],
                  DefaultTextStyle(
                    style: FluentTypography.caption.copyWith(
                      color: widget.selected ? effectiveColor : FluentColors.gray100,
                      fontWeight: widget.selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                    child: widget.label,
                  ),
                  if (widget.onDelete != null) ...[
                    const SizedBox(width: FluentSpacing.xs),
                    GestureDetector(
                      onTap: widget.onDelete,
                      child: Icon(
                        Icons.close,
                        size: 14,
                        color: widget.selected ? effectiveColor : FluentColors.gray90,
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
