import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/tokens.dart';
import '../../../theme/gradients.dart';
import '../../../design_system/animations/micro_interactions.dart';

/// Theme customization provider
final themeCustomizationProvider = StateNotifierProvider<ThemeCustomizationNotifier, ThemeCustomization>((ref) {
  return ThemeCustomizationNotifier();
});

/// Theme customization model
class ThemeCustomization {
  final Color primaryColor;
  final Color secondaryColor;
  final ThemeMode themeMode;
  final bool useGradients;
  final bool useGlassmorphism;
  
  const ThemeCustomization({
    this.primaryColor = const Color(0xFF6366F1), // Indigo
    this.secondaryColor = const Color(0xFF8B5CF6), // Purple
    this.themeMode = ThemeMode.system,
    this.useGradients = true,
    this.useGlassmorphism = true,
  });
  
  ThemeCustomization copyWith({
    Color? primaryColor,
    Color? secondaryColor,
    ThemeMode? themeMode,
    bool? useGradients,
    bool? useGlassmorphism,
  }) {
    return ThemeCustomization(
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      themeMode: themeMode ?? this.themeMode,
      useGradients: useGradients ?? this.useGradients,
      useGlassmorphism: useGlassmorphism ?? this.useGlassmorphism,
    );
  }
}

class ThemeCustomizationNotifier extends StateNotifier<ThemeCustomization> {
  ThemeCustomizationNotifier() : super(const ThemeCustomization());
  
  void setPrimaryColor(Color color) {
    state = state.copyWith(primaryColor: color);
  }
  
  void setSecondaryColor(Color color) {
    state = state.copyWith(secondaryColor: color);
  }
  
  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
  }
  
  void toggleGradients() {
    state = state.copyWith(useGradients: !state.useGradients);
  }
  
  void toggleGlassmorphism() {
    state = state.copyWith(useGlassmorphism: !state.useGlassmorphism);
  }
  
  void resetToDefaults() {
    state = const ThemeCustomization();
  }
}

/// Theme customization screen
class ThemeCustomizationScreen extends ConsumerWidget {
  const ThemeCustomizationScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customization = ref.watch(themeCustomizationProvider);
    final notifier = ref.read(themeCustomizationProvider.notifier);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Customization'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset to defaults',
            onPressed: () => notifier.resetToDefaults(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // Preview card
          _PreviewCard(customization: customization),
          
          const SizedBox(height: AppSpacing.xl),
          
          // Theme mode section
          _SectionHeader(title: 'Appearance'),
          const SizedBox(height: AppSpacing.sm),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(
                value: ThemeMode.light,
                icon: Icon(Icons.light_mode),
                label: Text('Light'),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                icon: Icon(Icons.dark_mode),
                label: Text('Dark'),
              ),
              ButtonSegment(
                value: ThemeMode.system,
                icon: Icon(Icons.brightness_auto),
                label: Text('Auto'),
              ),
            ],
            selected: {customization.themeMode},
            onSelectionChanged: (Set<ThemeMode> modes) {
              notifier.setThemeMode(modes.first);
            },
          ),
          
          const SizedBox(height: AppSpacing.xl),
          
          // Color customization
          _SectionHeader(title: 'Colors'),
          const SizedBox(height: AppSpacing.md),
          
          // Primary color
          _ColorRow(
            label: 'Primary Color',
            color: customization.primaryColor,
            onColorSelected: notifier.setPrimaryColor,
          ),
          
          const SizedBox(height: AppSpacing.md),
          
          // Secondary color
          _ColorRow(
            label: 'Secondary Color',
            color: customization.secondaryColor,
            onColorSelected: notifier.setSecondaryColor,
          ),
          
          const SizedBox(height: AppSpacing.xl),
          
          // Visual effects
          _SectionHeader(title: 'Visual Effects'),
          const SizedBox(height: AppSpacing.sm),
          
          SwitchListTile(
            title: const Text('Use Gradients'),
            subtitle: const Text('Enable gradient backgrounds for cards and buttons'),
            value: customization.useGradients,
            onChanged: (_) => notifier.toggleGradients(),
          ),
          
          SwitchListTile(
            title: const Text('Use Glassmorphism'),
            subtitle: const Text('Enable frosted glass effect on surfaces'),
            value: customization.useGlassmorphism,
            onChanged: (_) => notifier.toggleGlassmorphism(),
          ),
          
          const SizedBox(height: AppSpacing.xl),
          
          // Preset themes
          _SectionHeader(title: 'Preset Themes'),
          const SizedBox(height: AppSpacing.md),
          
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _PresetThemeChip(
                label: 'Indigo',
                primaryColor: const Color(0xFF6366F1),
                secondaryColor: const Color(0xFF8B5CF6),
                onTap: () {
                  notifier.setPrimaryColor(const Color(0xFF6366F1));
                  notifier.setSecondaryColor(const Color(0xFF8B5CF6));
                },
              ),
              _PresetThemeChip(
                label: 'Ocean',
                primaryColor: const Color(0xFF0EA5E9),
                secondaryColor: const Color(0xFF06B6D4),
                onTap: () {
                  notifier.setPrimaryColor(const Color(0xFF0EA5E9));
                  notifier.setSecondaryColor(const Color(0xFF06B6D4));
                },
              ),
              _PresetThemeChip(
                label: 'Forest',
                primaryColor: const Color(0xFF10B981),
                secondaryColor: const Color(0xFF059669),
                onTap: () {
                  notifier.setPrimaryColor(const Color(0xFF10B981));
                  notifier.setSecondaryColor(const Color(0xFF059669));
                },
              ),
              _PresetThemeChip(
                label: 'Sunset',
                primaryColor: const Color(0xFFF97316),
                secondaryColor: const Color(0xFFEF4444),
                onTap: () {
                  notifier.setPrimaryColor(const Color(0xFFF97316));
                  notifier.setSecondaryColor(const Color(0xFFEF4444));
                },
              ),
              _PresetThemeChip(
                label: 'Rose',
                primaryColor: const Color(0xFFF43F5E),
                secondaryColor: const Color(0xFFEC4899),
                onTap: () {
                  notifier.setPrimaryColor(const Color(0xFFF43F5E));
                  notifier.setSecondaryColor(const Color(0xFFEC4899));
                },
              ),
              _PresetThemeChip(
                label: 'Violet',
                primaryColor: const Color(0xFF8B5CF6),
                secondaryColor: const Color(0xFFA78BFA),
                onTap: () {
                  notifier.setPrimaryColor(const Color(0xFF8B5CF6));
                  notifier.setSecondaryColor(const Color(0xFFA78BFA));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  final ThemeCustomization customization;
  
  const _PreviewCard({required this.customization});
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preview',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            
            // Preview button with gradient
            PressableScale(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  gradient: customization.useGradients
                      ? LinearGradient(
                          colors: [
                            customization.primaryColor,
                            customization.secondaryColor,
                          ],
                        )
                      : null,
                  color: customization.useGradients ? null : customization.primaryColor,
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                  boxShadow: AppShadows.soft,
                ),
                child: Center(
                  child: Text(
                    'Sample Button',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            // Preview card with glassmorphism
            if (customization.useGlassmorphism)
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: customization.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  border: Border.all(
                    color: customization.primaryColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: customization.primaryColor,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Glassmorphism effect enabled',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  
  const _SectionHeader({required this.title});
  
  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _ColorRow extends StatelessWidget {
  final String label;
  final Color color;
  final ValueChanged<Color> onColorSelected;
  
  const _ColorRow({
    required this.label,
    required this.color,
    required this.onColorSelected,
  });
  
  @override
  Widget build(BuildContext context) {
    final presetColors = [
      const Color(0xFF6366F1), // Indigo
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFF0EA5E9), // Sky
      const Color(0xFF06B6D4), // Cyan
      const Color(0xFF10B981), // Emerald
      const Color(0xFF84CC16), // Lime
      const Color(0xFFF59E0B), // Amber
      const Color(0xFFF97316), // Orange
      const Color(0xFFEF4444), // Red
      const Color(0xFFF43F5E), // Rose
      const Color(0xFFEC4899), // Pink
      const Color(0xFFA78BFA), // Violet
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: presetColors.map((presetColor) {
            final isSelected = color.value == presetColor.value;
            return GestureDetector(
              onTap: () => onColorSelected(presetColor),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: presetColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                    width: 3,
                  ),
                  boxShadow: isSelected ? AppShadows.soft : null,
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _PresetThemeChip extends StatelessWidget {
  final String label;
  final Color primaryColor;
  final Color secondaryColor;
  final VoidCallback onTap;
  
  const _PresetThemeChip({
    required this.label,
    required this.primaryColor,
    required this.secondaryColor,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor, secondaryColor],
          ),
          borderRadius: BorderRadius.circular(AppRadii.pill),
          boxShadow: AppShadows.soft,
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
