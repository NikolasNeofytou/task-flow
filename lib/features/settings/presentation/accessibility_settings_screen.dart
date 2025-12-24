import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/accessible_themes.dart';

/// Accessibility settings provider
final accessibilitySettingsProvider = StateNotifierProvider<AccessibilitySettingsNotifier, AccessibilitySettings>((ref) {
  return AccessibilitySettingsNotifier();
});

/// Accessibility settings model
class AccessibilitySettings {
  final bool highContrastMode;
  final bool screenReaderOptimized;
  final TextSizePreset textSizePreset;
  final ColorBlindMode colorBlindMode;
  final bool reduceAnimations;
  final bool increaseTouchTargets;
  final bool boldText;
  final bool showFocusIndicators;
  
  const AccessibilitySettings({
    this.highContrastMode = false,
    this.screenReaderOptimized = false,
    this.textSizePreset = TextSizePreset.medium,
    this.colorBlindMode = ColorBlindMode.none,
    this.reduceAnimations = false,
    this.increaseTouchTargets = false,
    this.boldText = false,
    this.showFocusIndicators = true,
  });
  
  AccessibilitySettings copyWith({
    bool? highContrastMode,
    bool? screenReaderOptimized,
    TextSizePreset? textSizePreset,
    ColorBlindMode? colorBlindMode,
    bool? reduceAnimations,
    bool? increaseTouchTargets,
    bool? boldText,
    bool? showFocusIndicators,
  }) {
    return AccessibilitySettings(
      highContrastMode: highContrastMode ?? this.highContrastMode,
      screenReaderOptimized: screenReaderOptimized ?? this.screenReaderOptimized,
      textSizePreset: textSizePreset ?? this.textSizePreset,
      colorBlindMode: colorBlindMode ?? this.colorBlindMode,
      reduceAnimations: reduceAnimations ?? this.reduceAnimations,
      increaseTouchTargets: increaseTouchTargets ?? this.increaseTouchTargets,
      boldText: boldText ?? this.boldText,
      showFocusIndicators: showFocusIndicators ?? this.showFocusIndicators,
    );
  }
  
  /// Get animation duration based on settings
  Duration getAnimationDuration(Duration defaultDuration) {
    if (reduceAnimations) return Duration.zero;
    return defaultDuration;
  }
  
  /// Get minimum touch target size
  double get minTouchTarget => increaseTouchTargets ? 56.0 : 48.0;
}

enum ColorBlindMode {
  none,
  deuteranopia,   // Red-green
  protanopia,     // Red
  tritanopia,     // Blue-yellow
}

/// Accessibility settings notifier
class AccessibilitySettingsNotifier extends StateNotifier<AccessibilitySettings> {
  AccessibilitySettingsNotifier() : super(const AccessibilitySettings());
  
  void toggleHighContrast() {
    state = state.copyWith(highContrastMode: !state.highContrastMode);
  }
  
  void toggleScreenReaderOptimization() {
    state = state.copyWith(screenReaderOptimized: !state.screenReaderOptimized);
  }
  
  void setTextSize(TextSizePreset preset) {
    state = state.copyWith(textSizePreset: preset);
  }
  
  void setColorBlindMode(ColorBlindMode mode) {
    state = state.copyWith(colorBlindMode: mode);
  }
  
  void toggleReduceAnimations() {
    state = state.copyWith(reduceAnimations: !state.reduceAnimations);
  }
  
  void toggleIncreaseTouchTargets() {
    state = state.copyWith(increaseTouchTargets: !state.increaseTouchTargets);
  }
  
  void toggleBoldText() {
    state = state.copyWith(boldText: !state.boldText);
  }
  
  void toggleFocusIndicators() {
    state = state.copyWith(showFocusIndicators: !state.showFocusIndicators);
  }
  
  void resetToDefaults() {
    state = const AccessibilitySettings();
  }
  
  /// Auto-detect system accessibility settings
  void detectSystemSettings(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    
    state = state.copyWith(
      highContrastMode: mediaQuery.highContrast,
      boldText: mediaQuery.boldText,
      reduceAnimations: mediaQuery.disableAnimations,
      screenReaderOptimized: mediaQuery.accessibleNavigation,
    );
  }
}

/// Accessibility settings screen
class AccessibilitySettingsScreen extends ConsumerWidget {
  const AccessibilitySettingsScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(accessibilitySettingsProvider);
    final notifier = ref.read(accessibilitySettingsProvider.notifier);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accessibility Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Visual section
          const _SectionHeader(title: 'Visual'),
          const SizedBox(height: 8),
          
          _AccessibilitySwitchTile(
            title: 'High Contrast Mode',
            description: 'Increases contrast for better visibility',
            value: settings.highContrastMode,
            onChanged: (_) => notifier.toggleHighContrast(),
          ),
          
          _AccessibilitySwitchTile(
            title: 'Bold Text',
            description: 'Makes text easier to read',
            value: settings.boldText,
            onChanged: (_) => notifier.toggleBoldText(),
          ),
          
          const SizedBox(height: 16),
          Text(
            'Text Size',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          SegmentedButton<TextSizePreset>(
            segments: const [
              ButtonSegment(
                value: TextSizePreset.small,
                label: Text('S'),
              ),
              ButtonSegment(
                value: TextSizePreset.medium,
                label: Text('M'),
              ),
              ButtonSegment(
                value: TextSizePreset.large,
                label: Text('L'),
              ),
              ButtonSegment(
                value: TextSizePreset.extraLarge,
                label: Text('XL'),
              ),
            ],
            selected: {settings.textSizePreset},
            onSelectionChanged: (Set<TextSizePreset> newSelection) {
              notifier.setTextSize(newSelection.first);
            },
          ),
          
          const SizedBox(height: 16),
          Text(
            'Color Blind Mode',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          DropdownButton<ColorBlindMode>(
            value: settings.colorBlindMode,
            isExpanded: true,
            items: const [
              DropdownMenuItem(
                value: ColorBlindMode.none,
                child: Text('None'),
              ),
              DropdownMenuItem(
                value: ColorBlindMode.deuteranopia,
                child: Text('Deuteranopia (Red-Green)'),
              ),
              DropdownMenuItem(
                value: ColorBlindMode.protanopia,
                child: Text('Protanopia (Red)'),
              ),
              DropdownMenuItem(
                value: ColorBlindMode.tritanopia,
                child: Text('Tritanopia (Blue-Yellow)'),
              ),
            ],
            onChanged: (value) {
              if (value != null) notifier.setColorBlindMode(value);
            },
          ),
          
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          
          // Interaction section
          const _SectionHeader(title: 'Interaction'),
          const SizedBox(height: 8),
          
          _AccessibilitySwitchTile(
            title: 'Screen Reader Optimization',
            description: 'Optimizes app for screen readers',
            value: settings.screenReaderOptimized,
            onChanged: (_) => notifier.toggleScreenReaderOptimization(),
          ),
          
          _AccessibilitySwitchTile(
            title: 'Reduce Animations',
            description: 'Minimizes motion for better focus',
            value: settings.reduceAnimations,
            onChanged: (_) => notifier.toggleReduceAnimations(),
          ),
          
          _AccessibilitySwitchTile(
            title: 'Larger Touch Targets',
            description: 'Increases button and tap sizes',
            value: settings.increaseTouchTargets,
            onChanged: (_) => notifier.toggleIncreaseTouchTargets(),
          ),
          
          _AccessibilitySwitchTile(
            title: 'Show Focus Indicators',
            description: 'Highlights focused elements for keyboard navigation',
            value: settings.showFocusIndicators,
            onChanged: (_) => notifier.toggleFocusIndicators(),
          ),
          
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          
          // Actions
          Center(
            child: Column(
              children: [
                ElevatedButton.icon(
                  onPressed: () => notifier.detectSystemSettings(context),
                  icon: const Icon(Icons.sync),
                  label: const Text('Detect System Settings'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => notifier.resetToDefaults(),
                  child: const Text('Reset to Defaults'),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Info card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'About Accessibility',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'These settings help make the app more accessible for users with visual, motor, or cognitive disabilities. The app follows WCAG 2.1 Level AA guidelines.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  
  const _SectionHeader({required this.title});
  
  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    );
  }
}

class _AccessibilitySwitchTile extends StatelessWidget {
  final String title;
  final String description;
  final bool value;
  final ValueChanged<bool>? onChanged;
  
  const _AccessibilitySwitchTile({
    required this.title,
    required this.description,
    required this.value,
    this.onChanged,
  });
  
  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: value,
      enabled: onChanged != null,
      label: '$title, $description',
      hint: 'Double tap to ${value ? 'disable' : 'enable'}',
      child: SwitchListTile(
        title: Text(title),
        subtitle: Text(description),
        value: value,
        onChanged: onChanged,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }
}
