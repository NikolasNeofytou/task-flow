import 'package:flutter/material.dart';

/// Accessible button with minimum touch target and semantic labels
class AccessibleButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String? semanticLabel;
  final String? semanticHint;
  final bool isDestructive;
  final ButtonStyle? style;
  
  const AccessibleButton({
    super.key,
    required this.child,
    this.onPressed,
    this.semanticLabel,
    this.semanticHint,
    this.isDestructive = false,
    this.style,
  });
  
  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: semanticLabel,
      hint: semanticHint ?? 'Double tap to activate',
      onTap: onPressed,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 48,
          minHeight: 48,
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: style ?? (isDestructive ? 
            ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ) : null),
          child: child,
        ),
      ),
    );
  }
}

/// Accessible icon button with focus indicator
class AccessibleIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final String semanticLabel;
  final double size;
  final Color? color;
  
  const AccessibleIconButton({
    super.key,
    required this.icon,
    required this.semanticLabel,
    this.onPressed,
    this.tooltip,
    this.size = 24,
    this.color,
  });
  
  @override
  State<AccessibleIconButton> createState() => _AccessibleIconButtonState();
}

class _AccessibleIconButtonState extends State<AccessibleIconButton> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  
  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }
  
  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }
  
  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: widget.onPressed != null,
      label: widget.semanticLabel,
      hint: 'Double tap to activate',
      onTap: widget.onPressed,
      child: Focus(
        focusNode: _focusNode,
        child: Container(
          decoration: _isFocused ? BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.primary,
              width: 3,
            ),
            borderRadius: BorderRadius.circular(8),
          ) : null,
          child: IconButton(
            icon: Icon(widget.icon, size: widget.size),
            onPressed: widget.onPressed,
            tooltip: widget.tooltip ?? widget.semanticLabel,
            color: widget.color,
            constraints: const BoxConstraints(
              minWidth: 48,
              minHeight: 48,
            ),
          ),
        ),
      ),
    );
  }
}

/// Accessible checkbox with proper semantics
class AccessibleCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final String label;
  final String? description;
  
  const AccessibleCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.description,
  });
  
  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: value,
      enabled: onChanged != null,
      label: label,
      hint: description ?? 'Double tap to toggle',
      onTap: onChanged != null ? () => onChanged!(!value) : null,
      child: InkWell(
        onTap: onChanged != null ? () => onChanged!(!value) : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              SizedBox(
                width: 48,
                height: 48,
                child: Checkbox(
                  value: value,
                  onChanged: onChanged,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    if (description != null)
                      Text(
                        description!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Accessible text field with proper labels
class AccessibleTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final String? hint;
  final String? semanticLabel;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final int? maxLines;
  final String? errorText;
  
  const AccessibleTextField({
    super.key,
    this.controller,
    required this.label,
    this.hint,
    this.semanticLabel,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
    this.maxLines = 1,
    this.errorText,
  });
  
  @override
  Widget build(BuildContext context) {
    return Semantics(
      textField: true,
      label: semanticLabel ?? label,
      hint: hint ?? 'Enter $label',
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          errorText: errorText,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        obscureText: obscureText,
        keyboardType: keyboardType,
        onChanged: onChanged,
        maxLines: maxLines,
      ),
    );
  }
}

/// Accessible card with proper focus and semantics
class AccessibleCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final String? semanticHint;
  final bool isSelected;
  
  const AccessibleCard({
    super.key,
    required this.child,
    this.onTap,
    this.semanticLabel,
    this.semanticHint,
    this.isSelected = false,
  });
  
  @override
  State<AccessibleCard> createState() => _AccessibleCardState();
}

class _AccessibleCardState extends State<AccessibleCard> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  
  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }
  
  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }
  
  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: widget.onTap != null,
      selected: widget.isSelected,
      enabled: widget.onTap != null,
      label: widget.semanticLabel,
      hint: widget.semanticHint ?? (widget.onTap != null ? 'Double tap to open' : null),
      onTap: widget.onTap,
      child: Focus(
        focusNode: _focusNode,
        child: Card(
          elevation: _isFocused ? 8 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: _isFocused 
                ? Theme.of(context).colorScheme.primary 
                : (widget.isSelected 
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
                  : Colors.transparent),
              width: _isFocused ? 3 : 2,
            ),
          ),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(12),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// Accessible list tile with proper focus and semantics
class AccessibleListTile extends StatefulWidget {
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final String? semanticHint;
  final bool isSelected;
  
  const AccessibleListTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.semanticLabel,
    this.semanticHint,
    this.isSelected = false,
  });
  
  @override
  State<AccessibleListTile> createState() => _AccessibleListTileState();
}

class _AccessibleListTileState extends State<AccessibleListTile> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  
  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }
  
  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }
  
  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: widget.onTap != null,
      selected: widget.isSelected,
      enabled: widget.onTap != null,
      label: widget.semanticLabel,
      hint: widget.semanticHint ?? (widget.onTap != null ? 'Double tap to open' : null),
      onTap: widget.onTap,
      child: Focus(
        focusNode: _focusNode,
        child: Container(
          decoration: BoxDecoration(
            border: _isFocused ? Border.all(
              color: Theme.of(context).colorScheme.primary,
              width: 3,
            ) : null,
            color: widget.isSelected 
              ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
              : null,
          ),
          child: ListTile(
            leading: widget.leading,
            title: widget.title,
            subtitle: widget.subtitle,
            trailing: widget.trailing,
            onTap: widget.onTap,
            minVerticalPadding: 12,
          ),
        ),
      ),
    );
  }
}

/// Accessible tab bar with proper semantics
class AccessibleTabBar extends StatelessWidget {
  final List<String> tabs;
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  
  const AccessibleTabBar({
    super.key,
    required this.tabs,
    required this.currentIndex,
    required this.onTabSelected,
  });
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(tabs.length, (index) {
        final isSelected = index == currentIndex;
        return Expanded(
          child: Semantics(
            button: true,
            selected: isSelected,
            label: tabs[index],
            hint: 'Tab ${index + 1} of ${tabs.length}, ${isSelected ? 'selected' : 'not selected'}',
            onTap: () => onTabSelected(index),
            child: InkWell(
              onTap: () => onTabSelected(index),
              child: Container(
                constraints: const BoxConstraints(minHeight: 48),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected 
                        ? Theme.of(context).colorScheme.primary 
                        : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      tabs[index],
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected 
                          ? Theme.of(context).colorScheme.primary 
                          : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

/// Focus indicator widget for keyboard navigation
class FocusIndicator extends StatelessWidget {
  final Widget child;
  final FocusNode focusNode;
  final BorderRadius? borderRadius;
  
  const FocusIndicator({
    super.key,
    required this.child,
    required this.focusNode,
    this.borderRadius,
  });
  
  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: focusNode,
      child: AnimatedBuilder(
        animation: focusNode,
        builder: (context, child) {
          return Container(
            decoration: focusNode.hasFocus ? BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 3,
              ),
              borderRadius: borderRadius ?? BorderRadius.circular(8),
            ) : null,
            child: child,
          );
        },
        child: child,
      ),
    );
  }
}
