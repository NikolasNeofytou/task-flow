# Fluent UI Design System

## Overview

This implementation brings **Microsoft's Fluent Design System** to the Taskflow app, providing a premium, modern aesthetic that matches Windows 11 and Microsoft Office applications.

## What is Fluent Design?

Fluent Design is Microsoft's design language that emphasizes:

- **Light**: Subtle shadows and depth
- **Motion**: Natural, physics-based animations
- **Material**: Acrylic and Mica effects for translucency and layered depth
- **Depth**: Clear visual hierarchy
- **Scale**: Consistent spacing and sizing

## Implementation Structure

### 1. Design Tokens (`lib/theme/fluent_tokens.dart`)

Foundation of the design system with all core constants:

#### FluentColors
- **Primary**: Blue spectrum (#0078D4) - Microsoft's signature blue
- **Accent**: Purple spectrum (#8764B8)
- **Semantic**: Success, Warning, Error, Info
- **Grayscale**: 13 levels (gray10-gray130) for sophisticated neutral palette

#### FluentSpacing
9 levels: `xxs` (2.0) → `huge` (40.0)

#### FluentBorderRadius
5 levels: `none` (0.0) → `circular` (999.0)

#### FluentElevation
6 shadow levels with subtle opacity:
- `shadow2` to `shadow64`
- Presets: `card`, `dialog`, `appBar`

#### FluentTypography
Segoe UI font family (Microsoft's signature font):
- 7 styles: `caption` (12px) → `display` (32px)
- Weights: 400 (normal) or 600 (strong)

#### FluentDuration
7 animation durations: `ultraFast` (50ms) → `ultraSlow` (500ms)

#### FluentCurves
6 motion curves with custom Cubic bezier:
- `accelerate`, `decelerate`, `standard`, `entrance`, `exit`

#### Signature Fluent Effects

**FluentAcrylic**: Translucent backgrounds with subtle blur
- `light()`, `dark()`, `accentLight()`
- Signature Fluent effect for Windows 11 look

**FluentMica**: Layered depth effect
- `base()`, `alt()`
- Windows 11 style material

**FluentReveal**: Hover highlights
- `light(isHovered)`, `dark(isHovered)`
- Subtle borders and backgrounds on hover

**FluentLayers**: Z-index system
- `background` (0) → `tooltip` (16)

### 2. Theme Configuration (`lib/theme/fluent_theme.dart`)

Complete Flutter theme implementation:

```dart
// Apply Fluent theme in MaterialApp
MaterialApp(
  theme: FluentTheme.light(),
  darkTheme: FluentTheme.dark(),
  themeMode: ThemeMode.dark,
  // ...
);
```

#### Key Theme Features:
- Material 3 with Fluent colors
- Subtle elevations (no harsh shadows)
- Fluent border radius and spacing
- Segoe UI typography throughout
- Custom page transitions with Fluent motion
- Consistent styling across all widgets

### 3. Fluent Buttons (`lib/design_system/fluent_buttons.dart`)

**FluentButton** - Primary action
```dart
FluentButton(
  onPressed: () {},
  icon: Icons.add,
  isLoading: false,
  child: Text('Create Project'),
)
```

**FluentSecondaryButton** - Secondary action
```dart
FluentSecondaryButton(
  onPressed: () {},
  icon: Icons.cancel,
  child: Text('Cancel'),
)
```

**FluentSubtleButton** - Minimal action
```dart
FluentSubtleButton(
  onPressed: () {},
  child: Text('Learn More'),
)
```

**FluentIconButton** - Icon-only action
```dart
FluentIconButton(
  onPressed: () {},
  icon: Icons.settings,
  tooltip: 'Settings',
  size: 40,
)
```

**FluentFab** - Floating action button
```dart
FluentFab(
  onPressed: () {},
  icon: Icons.add,
  label: 'Add Task',
  extended: true,
)
```

**FluentAccentButton** - Accent color action
```dart
FluentAccentButton(
  onPressed: () {},
  icon: Icons.star,
  child: Text('Featured'),
)
```

#### Button Features:
- Hover effects with scale/color transitions
- Loading states
- Disabled states with gray
- Icon support
- Fluent motion curves
- Subtle shadows on hover

### 4. Fluent Cards (`lib/design_system/fluent_cards.dart`)

**FluentCard** - Standard card
```dart
FluentCard(
  onTap: () {},
  padding: EdgeInsets.all(16),
  child: Column(
    children: [
      Text('Card Title'),
      Text('Card content'),
    ],
  ),
)
```

**FluentAcrylicCard** - Translucent card
```dart
FluentAcrylicCard(
  useDarkAcrylic: false,
  child: Text('Acrylic effect'),
)
```

**FluentMicaCard** - Windows 11 style card
```dart
FluentMicaCard(
  useAltMica: false,
  child: Text('Mica material'),
)
```

**FluentElevatedCard** - Higher elevation
```dart
FluentElevatedCard(
  backgroundColor: Colors.white,
  child: Text('Elevated content'),
)
```

**FluentInfoCard** - Colored border with icon
```dart
FluentInfoCard(
  accentColor: FluentColors.info,
  icon: Icons.info,
  title: 'Information',
  child: Text('Info message'),
)
```

**FluentListTile** - List item
```dart
FluentListTile(
  leading: Icon(Icons.person),
  title: Text('John Doe'),
  subtitle: Text('john@example.com'),
  trailing: Icon(Icons.chevron_right),
  onTap: () {},
)
```

**FluentChip** - Tag/filter chip
```dart
FluentChip(
  label: Text('Design'),
  icon: Icons.design_services,
  selected: true,
  onTap: () {},
  onDelete: () {},
)
```

#### Card Features:
- Subtle borders and shadows
- Hover effects with scale/elevation
- Acrylic and Mica materials
- Tap handling with InkWell
- Fluent motion

### 5. Fluent Inputs (`lib/design_system/fluent_inputs.dart`)

**FluentTextField** - Text input
```dart
FluentTextField(
  controller: _controller,
  labelText: 'Email',
  hintText: 'Enter your email',
  prefixIcon: Icons.email,
  errorText: 'Invalid email',
  onChanged: (value) {},
)
```

**FluentSearchBox** - Search input
```dart
FluentSearchBox(
  hintText: 'Search projects...',
  onChanged: (query) {},
  onClear: () {},
)
```

**FluentSwitch** - Toggle switch
```dart
FluentSwitch(
  value: _isEnabled,
  onChanged: (value) {},
  label: 'Enable notifications',
)
```

**FluentCheckbox** - Checkbox
```dart
FluentCheckbox(
  value: _isChecked,
  onChanged: (value) {},
  label: 'I agree to terms',
)
```

**FluentRadio** - Radio button
```dart
FluentRadio<int>(
  value: 1,
  groupValue: _selectedValue,
  onChanged: (value) {},
  label: 'Option 1',
)
```

**FluentSlider** - Slider
```dart
FluentSlider(
  value: _value,
  onChanged: (value) {},
  min: 0,
  max: 100,
  divisions: 10,
  label: 'Volume',
)
```

#### Input Features:
- Focus states with border color
- Hover effects
- Error states
- Helper text
- Icons and labels
- Smooth animations

## Migration Guide

### Before (Material Design)
```dart
ElevatedButton(
  onPressed: () {},
  child: Text('Button'),
)
```

### After (Fluent Design)
```dart
FluentButton(
  onPressed: () {},
  child: Text('Button'),
)
```

### Before (Material Card)
```dart
Card(
  elevation: 2,
  child: ListTile(
    title: Text('Item'),
  ),
)
```

### After (Fluent Card)
```dart
FluentCard(
  child: FluentListTile(
    title: Text('Item'),
  ),
)
```

## Key Differences from Material Design

| Aspect | Material Design | Fluent Design |
|--------|----------------|---------------|
| Shadows | Prominent, dark | Subtle, light opacity |
| Colors | Vibrant, high contrast | Softer, blue-focused |
| Motion | Sharp, snappy | Smooth, natural |
| Typography | Roboto | Segoe UI |
| Effects | Ripples | Acrylic, Mica, Reveal |
| Borders | Minimal | Visible borders |

## Color Palette

### Primary Blue Spectrum
- Primary: `#0078D4`
- Primary Light: `#429CE3`
- Primary Dark: `#005A9E`

### Accent Purple
- Accent: `#8764B8`
- Accent Light: `#A47FBF`
- Accent Dark: `#744DA9`

### Semantic Colors
- Success: `#107C10` (green)
- Warning: `#F7630C` (orange)
- Error: `#D13438` (red)
- Info: `#0078D4` (blue)

### Grayscale (13 levels)
From lightest to darkest:
- gray10: `#FAFAFA`
- gray20: `#F5F5F5`
- gray30: `#EBEBEB`
- gray40: `#E0E0E0`
- gray50: `#CCCCCC`
- gray60: `#B3B3B3`
- gray70: `#999999`
- gray80: `#808080`
- gray90: `#666666`
- gray100: `#4D4D4D`
- gray110: `#333333`
- gray120: `#1F1F1F`
- gray130: `#141414`

## Best Practices

### 1. Use Fluent Colors
```dart
// ✅ Good
Container(color: FluentColors.primary)

// ❌ Avoid
Container(color: Colors.blue)
```

### 2. Apply Fluent Spacing
```dart
// ✅ Good
Padding(padding: EdgeInsets.all(FluentSpacing.lg))

// ❌ Avoid
Padding(padding: EdgeInsets.all(16))
```

### 3. Use Fluent Typography
```dart
// ✅ Good
Text('Title', style: FluentTypography.title)

// ❌ Avoid
Text('Title', style: TextStyle(fontSize: 20))
```

### 4. Apply Fluent Motion
```dart
// ✅ Good
AnimatedContainer(
  duration: FluentDuration.normal,
  curve: FluentCurves.standard,
)

// ❌ Avoid
AnimatedContainer(
  duration: Duration(milliseconds: 200),
  curve: Curves.easeInOut,
)
```

### 5. Use Fluent Effects for Premium Look
```dart
// ✅ Acrylic for dialogs/overlays
Container(decoration: FluentAcrylic.light())

// ✅ Mica for large surfaces
Container(decoration: FluentMica.base())

// ✅ Reveal for hover states
Container(decoration: FluentReveal.light(isHovered: true))
```

## Component Examples

### Dashboard Card
```dart
FluentCard(
  onTap: () => context.push('/project/123'),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(Icons.folder, color: FluentColors.primary),
          SizedBox(width: FluentSpacing.sm),
          Text('Project Name', style: FluentTypography.subtitle),
        ],
      ),
      SizedBox(height: FluentSpacing.md),
      Text('Project description', style: FluentTypography.body),
      SizedBox(height: FluentSpacing.lg),
      Row(
        children: [
          FluentChip(
            label: Text('Active'),
            selected: true,
          ),
          SizedBox(width: FluentSpacing.sm),
          FluentChip(
            label: Text('5 Tasks'),
          ),
        ],
      ),
    ],
  ),
)
```

### Form with Fluent Inputs
```dart
Column(
  children: [
    FluentTextField(
      labelText: 'Project Name',
      hintText: 'Enter project name',
      prefixIcon: Icons.title,
    ),
    SizedBox(height: FluentSpacing.lg),
    FluentTextField(
      labelText: 'Description',
      hintText: 'Enter description',
      maxLines: 4,
    ),
    SizedBox(height: FluentSpacing.lg),
    FluentSwitch(
      value: _isPublic,
      onChanged: (value) => setState(() => _isPublic = value),
      label: 'Make project public',
    ),
    SizedBox(height: FluentSpacing.xl),
    Row(
      children: [
        Expanded(
          child: FluentSecondaryButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ),
        SizedBox(width: FluentSpacing.md),
        Expanded(
          child: FluentButton(
            onPressed: _saveProject,
            icon: Icons.save,
            child: Text('Save'),
          ),
        ),
      ],
    ),
  ],
)
```

### Dialog with Acrylic Effect
```dart
showDialog(
  context: context,
  builder: (context) => Dialog(
    backgroundColor: Colors.transparent,
    child: FluentAcrylicCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Confirm Action', style: FluentTypography.title),
          SizedBox(height: FluentSpacing.md),
          Text('Are you sure you want to delete this project?'),
          SizedBox(height: FluentSpacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FluentSubtleButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              SizedBox(width: FluentSpacing.md),
              FluentButton(
                onPressed: () {
                  // Delete action
                  Navigator.pop(context);
                },
                child: Text('Delete'),
              ),
            ],
          ),
        ],
      ),
    ),
  ),
);
```

## Performance Notes

- **Hover effects**: Use `MouseRegion` for desktop, no performance impact on mobile
- **Animations**: All animations use hardware-accelerated properties
- **Shadows**: Fluent shadows are more subtle (less blur), better performance than Material
- **Acrylic/Mica**: Use sparingly for premium surfaces (dialogs, cards), not for entire screens

## Future Enhancements

Potential additions to the Fluent design system:

1. **FluentNavBar**: Custom navigation bar with Acrylic effect
2. **FluentAppBar**: Custom app bar with Mica material
3. **FluentDropdown**: Dropdown menu with Fluent styling
4. **FluentDatePicker**: Date picker with Fluent design
5. **FluentContextMenu**: Right-click context menu
6. **FluentTooltip**: Enhanced tooltips
7. **FluentProgress**: Linear and circular progress indicators
8. **FluentBadge**: Notification badges

## References

- [Fluent 2 Design System](https://fluent2.microsoft.design/)
- [Windows 11 Design Principles](https://learn.microsoft.com/en-us/windows/apps/design/)
- [Fluent UI GitHub](https://github.com/microsoft/fluentui)

## Files Structure

```
lib/
├── theme/
│   ├── fluent_tokens.dart      # Design tokens (395 lines)
│   └── fluent_theme.dart       # Theme configuration (480 lines)
└── design_system/
    ├── fluent_buttons.dart     # Button widgets (520 lines)
    ├── fluent_cards.dart       # Card widgets (650 lines)
    └── fluent_inputs.dart      # Input widgets (580 lines)
```

**Total**: 5 files, ~2,625 lines of Fluent UI implementation

## Summary

The Fluent UI design system provides:

✅ **Premium aesthetics** matching Windows 11 and Microsoft Office  
✅ **Comprehensive widget library** (buttons, cards, inputs)  
✅ **Signature effects** (Acrylic, Mica, Reveal)  
✅ **Consistent design tokens** (colors, spacing, typography)  
✅ **Smooth animations** with Fluent motion curves  
✅ **Hover states** for desktop experience  
✅ **Light/dark themes** out of the box  
✅ **Type-safe** with proper TypeScript-like structure
