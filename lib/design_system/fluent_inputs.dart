import 'package:flutter/material.dart';
import '../theme/fluent_tokens.dart';

/// Fluent UI Text Field
/// Text input with Fluent styling
class FluentTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final IconData? prefixIcon;
  final Widget? suffix;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int? maxLines;
  final int? maxLength;
  final bool enabled;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;

  const FluentTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.helperText,
    this.prefixIcon,
    this.suffix,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.errorText,
    this.onChanged,
    this.onTap,
  });

  @override
  State<FluentTextField> createState() => _FluentTextFieldState();
}

class _FluentTextFieldState extends State<FluentTextField> {
  bool _isFocused = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasError = widget.errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null) ...[
          Text(
            widget.labelText!,
            style: FluentTypography.caption.copyWith(
              color: FluentColors.gray90,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: FluentSpacing.xs),
        ],
        MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: Focus(
            onFocusChange: (focused) => setState(() => _isFocused = focused),
            child: AnimatedContainer(
              duration: FluentDuration.fast,
              curve: FluentCurves.standard,
              decoration: BoxDecoration(
                color: widget.enabled
                    ? (isDark ? FluentColors.gray120 : Colors.white)
                    : FluentColors.gray30,
                borderRadius: BorderRadius.circular(FluentBorderRadius.medium),
                border: Border.all(
                  color: hasError
                      ? FluentColors.error
                      : _isFocused
                          ? FluentColors.primary
                          : _isHovered
                              ? FluentColors.gray70
                              : FluentColors.gray60,
                  width: _isFocused ? 2 : 1,
                ),
              ),
              child: TextField(
                controller: widget.controller,
                obscureText: widget.obscureText,
                keyboardType: widget.keyboardType,
                maxLines: widget.maxLines,
                maxLength: widget.maxLength,
                enabled: widget.enabled,
                onChanged: widget.onChanged,
                onTap: widget.onTap,
                style: FluentTypography.body.copyWith(
                  color: widget.enabled ? FluentColors.gray100 : FluentColors.gray70,
                ),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: FluentTypography.body.copyWith(
                    color: FluentColors.gray70,
                  ),
                  prefixIcon: widget.prefixIcon != null
                      ? Icon(
                          widget.prefixIcon,
                          color: FluentColors.gray80,
                          size: 20,
                        )
                      : null,
                  suffixIcon: widget.suffix,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: FluentSpacing.md,
                    vertical: FluentSpacing.md,
                  ),
                  counterText: '',
                ),
              ),
            ),
          ),
        ),
        if (widget.helperText != null || hasError) ...[
          const SizedBox(height: FluentSpacing.xs),
          Text(
            hasError ? widget.errorText! : widget.helperText!,
            style: FluentTypography.caption.copyWith(
              color: hasError ? FluentColors.error : FluentColors.gray80,
            ),
          ),
        ],
      ],
    );
  }
}

/// Fluent UI Search Box
/// Search input with icon and clear button
class FluentSearchBox extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  const FluentSearchBox({
    super.key,
    this.controller,
    this.hintText,
    this.onChanged,
    this.onClear,
  });

  @override
  State<FluentSearchBox> createState() => _FluentSearchBoxState();
}

class _FluentSearchBoxState extends State<FluentSearchBox> {
  late TextEditingController _controller;
  bool _isFocused = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _handleClear() {
    _controller.clear();
    widget.onClear?.call();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Focus(
        onFocusChange: (focused) => setState(() => _isFocused = focused),
        child: AnimatedContainer(
          duration: FluentDuration.fast,
          curve: FluentCurves.standard,
          decoration: BoxDecoration(
            color: isDark ? FluentColors.gray120 : Colors.white,
            borderRadius: BorderRadius.circular(FluentBorderRadius.medium),
            border: Border.all(
              color: _isFocused
                  ? FluentColors.primary
                  : _isHovered
                      ? FluentColors.gray70
                      : FluentColors.gray60,
              width: _isFocused ? 2 : 1,
            ),
          ),
          child: TextField(
            controller: _controller,
            onChanged: widget.onChanged,
            style: FluentTypography.body.copyWith(
              color: FluentColors.gray100,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText ?? 'Search...',
              hintStyle: FluentTypography.body.copyWith(
                color: FluentColors.gray70,
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: FluentColors.gray80,
                size: 20,
              ),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: FluentColors.gray80,
                        size: 16,
                      ),
                      onPressed: _handleClear,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: FluentSpacing.md,
                vertical: FluentSpacing.md,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Fluent UI Switch
/// Toggle switch with Fluent styling
class FluentSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? label;

  const FluentSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
  });

  @override
  State<FluentSwitch> createState() => _FluentSwitchState();
}

class _FluentSwitchState extends State<FluentSwitch> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => widget.onChanged(!widget.value),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: FluentDuration.fast,
              curve: FluentCurves.standard,
              width: 40,
              height: 20,
              decoration: BoxDecoration(
                color: widget.value
                    ? (_isHovered ? FluentColors.primaryDark : FluentColors.primary)
                    : FluentColors.gray50,
                borderRadius: BorderRadius.circular(FluentBorderRadius.circular),
              ),
              child: AnimatedAlign(
                duration: FluentDuration.fast,
                curve: FluentCurves.standard,
                alignment: widget.value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.all(2),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [FluentElevation.shadow4],
                  ),
                ),
              ),
            ),
            if (widget.label != null) ...[
              const SizedBox(width: FluentSpacing.sm),
              Text(
                widget.label!,
                style: FluentTypography.body.copyWith(
                  color: FluentColors.gray100,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Fluent UI Checkbox
/// Checkbox with Fluent styling
class FluentCheckbox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? label;

  const FluentCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
  });

  @override
  State<FluentCheckbox> createState() => _FluentCheckboxState();
}

class _FluentCheckboxState extends State<FluentCheckbox> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => widget.onChanged(!widget.value),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: FluentDuration.fast,
              curve: FluentCurves.standard,
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: widget.value
                    ? (_isHovered ? FluentColors.primaryDark : FluentColors.primary)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(FluentBorderRadius.small),
                border: Border.all(
                  color: widget.value ? Colors.transparent : FluentColors.gray70,
                  width: 1.5,
                ),
              ),
              child: widget.value
                  ? const Icon(
                      Icons.check,
                      size: 14,
                      color: Colors.white,
                    )
                  : null,
            ),
            if (widget.label != null) ...[
              const SizedBox(width: FluentSpacing.sm),
              Text(
                widget.label!,
                style: FluentTypography.body.copyWith(
                  color: FluentColors.gray100,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Fluent UI Radio Button
/// Radio button with Fluent styling
class FluentRadio<T> extends StatefulWidget {
  final T value;
  final T groupValue;
  final ValueChanged<T> onChanged;
  final String? label;

  const FluentRadio({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.label,
  });

  @override
  State<FluentRadio<T>> createState() => _FluentRadioState<T>();
}

class _FluentRadioState<T> extends State<FluentRadio<T>> {
  bool _isHovered = false;

  bool get _isSelected => widget.value == widget.groupValue;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => widget.onChanged(widget.value),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: FluentDuration.fast,
              curve: FluentCurves.standard,
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: _isSelected
                      ? (_isHovered ? FluentColors.primaryDark : FluentColors.primary)
                      : FluentColors.gray70,
                  width: _isSelected ? 2 : 1.5,
                ),
              ),
              child: _isSelected
                  ? Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _isHovered
                              ? FluentColors.primaryDark
                              : FluentColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            if (widget.label != null) ...[
              const SizedBox(width: FluentSpacing.sm),
              Text(
                widget.label!,
                style: FluentTypography.body.copyWith(
                  color: FluentColors.gray100,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Fluent UI Slider
/// Slider with Fluent styling
class FluentSlider extends StatefulWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final double min;
  final double max;
  final int? divisions;
  final String? label;

  const FluentSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.label,
  });

  @override
  State<FluentSlider> createState() => _FluentSliderState();
}

class _FluentSliderState extends State<FluentSlider> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.label != null) ...[
            Text(
              widget.label!,
              style: FluentTypography.caption.copyWith(
                color: FluentColors.gray90,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: FluentSpacing.xs),
          ],
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: FluentColors.primary,
              inactiveTrackColor: FluentColors.gray50,
              thumbColor: Colors.white,
              overlayColor: FluentColors.primary.withOpacity(0.1),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: _isHovered ? 8 : 6,
              ),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            ),
            child: Slider(
              value: widget.value,
              onChanged: widget.onChanged,
              min: widget.min,
              max: widget.max,
              divisions: widget.divisions,
            ),
          ),
        ],
      ),
    );
  }
}
