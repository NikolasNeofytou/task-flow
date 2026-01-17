import 'package:flutter/material.dart';
import '../../theme/tokens.dart';

/// Enhanced text field with character counter, validation, and better UX.
class EnhancedTextField extends StatefulWidget {
  const EnhancedTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helperText,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLength,
    this.maxLines = 1,
    this.minLines,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
    this.enabled = true,
    this.obscureText = false,
    this.showCharacterCount = false,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? helperText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLength;
  final int? maxLines;
  final int? minLines;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final bool autofocus;
  final bool enabled;
  final bool obscureText;
  final bool showCharacterCount;

  @override
  State<EnhancedTextField> createState() => _EnhancedTextFieldState();
}

class _EnhancedTextFieldState extends State<EnhancedTextField> {
  late TextEditingController _controller;
  bool _isFocused = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    if (widget.validator != null) {
      setState(() {
        _errorText = widget.validator!(_controller.text);
      });
    }
    widget.onChanged?.call(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentLength = _controller.text.length;
    final hasError = _errorText != null && _errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Focus(
          onFocusChange: (focused) => setState(() => _isFocused = focused),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.md),
              boxShadow: _isFocused && !hasError
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: TextFormField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: widget.label,
                hintText: widget.hint,
                helperText: widget.helperText,
                prefixIcon: widget.prefixIcon,
                suffixIcon: widget.suffixIcon,
                errorText: _errorText,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  borderSide: BorderSide(
                    color: hasError
                        ? theme.colorScheme.error
                        : AppColors.neutral.withOpacity(0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  borderSide: BorderSide(
                    color: hasError
                        ? theme.colorScheme.error
                        : AppColors.neutral.withOpacity(0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  borderSide: BorderSide(
                    color:
                        hasError ? theme.colorScheme.error : AppColors.primary,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  borderSide: BorderSide(
                    color: theme.colorScheme.error,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  borderSide: BorderSide(
                    color: theme.colorScheme.error,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: widget.enabled
                    ? Colors.white
                    : AppColors.surface.withOpacity(0.3),
              ),
              maxLength: widget.maxLength,
              maxLines: widget.maxLines,
              minLines: widget.minLines,
              keyboardType: widget.keyboardType,
              textCapitalization: widget.textCapitalization,
              onFieldSubmitted: widget.onSubmitted,
              autofocus: widget.autofocus,
              enabled: widget.enabled,
              obscureText: widget.obscureText,
              buildCounter: widget.showCharacterCount && widget.maxLength != null
                  ? (context,
                      {required currentLength,
                      required isFocused,
                      maxLength}) {
                      return Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xs),
                        child: Text(
                          '$currentLength / $maxLength',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: currentLength > (maxLength ?? 0)
                                ? theme.colorScheme.error
                                : AppColors.neutral,
                          ),
                        ),
                      );
                    }
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
