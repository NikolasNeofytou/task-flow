# Contributing to TaskFlow

Thank you for your interest in contributing to TaskFlow! This document provides guidelines and instructions for contributing to the project.

## 📋 Table of Contents

1. [Getting Started](#getting-started)
2. [Development Workflow](#development-workflow)
3. [Code Standards](#code-standards)
4. [Commit Guidelines](#commit-guidelines)
5. [Pull Request Process](#pull-request-process)
6. [Project Structure](#project-structure)

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.24.5 or later
- Android Studio / Xcode (for mobile development)
- Node.js 16+ (for backend development)
- Git

### Initial Setup

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd taskflow_app
   ```

2. **Read the setup guide:**
   ```bash
   # Start here for complete setup instructions
   cat GETTING_STARTED.md
   ```

3. **Quick start:**
   ```powershell
   # Windows
   .\quick_start.ps1
   ```

---

## 💻 Development Workflow

### Daily Development

1. **Start development environment:**
   ```powershell
   .\quick_start.ps1
   ```

2. **Make your changes** in the code editor

3. **Hot reload** by pressing `r` in the terminal

4. **Test your changes** thoroughly

### Before Committing

Always run these checks before committing:

```powershell
# Format code
.\dev.ps1 format

# Analyze code
.\dev.ps1 analyze

# Run tests
.\dev.ps1 test
```

---

## 📐 Code Standards

### Dart/Flutter Code

- **Follow Flutter style guide:** [Official Flutter Style Guide](https://docs.flutter.dev/development/tools/formatting)
- **Use dart format:** Code must be formatted with `dart format`
- **Lint rules:** Follow rules defined in `analysis_options.yaml`
- **File naming:** Use `snake_case` for file names
- **Class naming:** Use `PascalCase` for class names
- **Variable naming:** Use `camelCase` for variables and functions

### Code Organization

```dart
// 1. Imports (sorted)
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:taskflow_app/core/utils.dart';

// 2. Class definition
class MyWidget extends StatelessWidget {
  // 3. Constructor
  const MyWidget({super.key});

  // 4. Build method
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

// 5. Private methods/helpers
```

### Design System Usage

Always use design tokens from the design system:

```dart
// ✅ Good
Container(
  padding: EdgeInsets.all(AppSpacing.md),
  decoration: BoxDecoration(
    color: AppColors.primary,
    borderRadius: BorderRadius.circular(AppRadii.md),
  ),
)

// ❌ Bad
Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.blue,
    borderRadius: BorderRadius.circular(8),
  ),
)
```

### Component Structure

New UI components should follow this pattern:

```dart
// lib/design_system/components/my_component.dart

import 'package:flutter/material.dart';
import 'package:taskflow_app/design_system/design_system.dart';

class MyComponent extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  
  const MyComponent({
    super.key,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Implementation
    );
  }
}
```

---

## 📝 Commit Guidelines

### Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- **feat:** New feature
- **fix:** Bug fix
- **docs:** Documentation changes
- **style:** Code style changes (formatting, etc.)
- **refactor:** Code refactoring
- **test:** Adding or updating tests
- **chore:** Maintenance tasks

### Examples

```bash
# Good commit messages
git commit -m "feat(chat): add voice message recording"
git commit -m "fix(tasks): resolve date picker timezone issue"
git commit -m "docs(readme): update installation instructions"
git commit -m "refactor(auth): simplify login flow"

# Bad commit messages
git commit -m "fixed stuff"
git commit -m "updates"
git commit -m "wip"
```

### Scope Guidelines

Use these scopes consistently:
- **auth:** Authentication/authorization
- **tasks:** Task management
- **projects:** Project features
- **chat:** Chat/messaging
- **calendar:** Calendar views
- **profile:** User profile
- **notifications:** Notification system
- **ui:** UI components
- **backend:** Backend changes

---

## 🔄 Pull Request Process

### Before Creating PR

1. **Update your branch:**
   ```bash
   git checkout main
   git pull origin main
   git checkout your-branch
   git merge main
   ```

2. **Run all checks:**
   ```powershell
   .\dev.ps1 format
   .\dev.ps1 analyze
   .\dev.ps1 test
   ```

3. **Test thoroughly:**
   - Test on Android emulator
   - Test on Windows desktop (if applicable)
   - Verify all new features work
   - Check for regressions

### Creating the PR

1. **Push your branch:**
   ```bash
   git push origin your-branch
   ```

2. **Create PR with template:**
   - Clear title following commit guidelines
   - Description of changes
   - Screenshots/videos of UI changes
   - Testing instructions
   - Related issues

### PR Template

```markdown
## Description
Brief description of what this PR does

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Changes Made
- Change 1
- Change 2
- Change 3

## Screenshots/Videos
(If applicable)

## Testing
- [ ] Tested on Android
- [ ] Tested on Windows
- [ ] All tests passing
- [ ] No analyzer warnings

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex code
- [ ] Documentation updated
- [ ] No new warnings
```

### Review Process

- PRs require at least one approval
- Address all review comments
- Keep PR scope focused and manageable
- Update PR description if scope changes

---

## 📁 Project Structure

```
taskflow_app/
├── lib/
│   ├── core/              # Core utilities and services
│   ├── design_system/     # Design tokens and components
│   ├── features/          # Feature modules
│   └── theme/             # Theme configuration
├── docs/                  # Documentation
├── backend/               # Node.js backend server
├── backend_mock/          # Mock server for testing
├── scripts/               # Utility scripts
├── test/                  # Test files
├── assets/                # Images, sounds, etc.
├── quick_start.ps1        # Quick startup script
├── start_taskflow.ps1     # Full startup with options
└── dev.ps1                # Development tools
```

### Feature Module Structure

Each feature follows this structure:

```
features/my_feature/
├── data/
│   ├── models/           # Data models
│   ├── repositories/     # Data layer
│   └── providers/        # Riverpod providers
├── domain/
│   └── entities/         # Business logic entities
└── presentation/
    ├── screens/          # Full-screen views
    ├── widgets/          # Feature-specific widgets
    └── providers/        # UI state providers
```

---

## 🧪 Testing Guidelines

### Writing Tests

- Write tests for new features
- Update tests when modifying existing features
- Aim for meaningful test coverage
- Test edge cases and error scenarios

### Running Tests

```powershell
# Run all tests
.\dev.ps1 test

# Run specific test file
flutter test test/my_test.dart

# Run with coverage
flutter test --coverage
```

### Test Structure

```dart
void main() {
  group('MyWidget', () {
    testWidgets('should render correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: MyWidget()),
      );
      
      expect(find.text('Expected Text'), findsOneWidget);
    });
    
    testWidgets('should handle user interaction', (tester) async {
      // Test implementation
    });
  });
}
```

---

## 🎨 Design System

### Using Design Tokens

All UI components must use design system tokens:

```dart
import 'package:taskflow_app/design_system/design_system.dart';

// Colors
AppColors.primary
AppColors.secondary
AppColors.background
AppColors.surface

// Spacing
AppSpacing.xs  // 4px
AppSpacing.sm  // 8px
AppSpacing.md  // 16px
AppSpacing.lg  // 24px
AppSpacing.xl  // 32px

// Border Radius
AppRadii.sm    // 4px
AppRadii.md    // 8px
AppRadii.lg    // 12px
AppRadii.xl    // 16px

// Typography
AppTypography.h1
AppTypography.h2
AppTypography.body1
AppTypography.caption
```

### Creating New Components

1. Place in `lib/design_system/components/`
2. Follow existing component patterns
3. Use design tokens exclusively
4. Document usage in component comments
5. Add to `lib/design_system/design_system.dart` exports

---

## 📚 Documentation

### Code Documentation

- Add doc comments for public APIs
- Explain complex logic
- Include usage examples for components

```dart
/// A button that shows a loading spinner when processing.
///
/// Example:
/// ```dart
/// LoadingButton(
///   label: 'Submit',
///   isLoading: true,
///   onPressed: () => handleSubmit(),
/// )
/// ```
class LoadingButton extends StatelessWidget {
  /// The text shown on the button
  final String label;
  
  /// Whether to show loading spinner
  final bool isLoading;
  
  // ...
}
```

### Updating Documentation

When making significant changes:
- Update README.md if setup changes
- Update relevant docs/ files
- Add examples for new features
- Update CHANGELOG.md (if exists)

---

## 🐛 Reporting Issues

### Bug Reports

Include:
- Clear description of the issue
- Steps to reproduce
- Expected vs actual behavior
- Screenshots/videos
- Device/platform information
- Flutter version
- Error logs/stack traces

### Feature Requests

Include:
- Clear description of the feature
- Use case and benefits
- Mockups or examples (if applicable)
- Implementation suggestions (optional)

---

## 💡 Best Practices

### Performance

- Use `const` constructors where possible
- Avoid rebuilding expensive widgets
- Use `ListView.builder` for long lists
- Optimize images and assets
- Profile before optimizing

### State Management

- Use Riverpod for state management
- Keep providers focused and single-purpose
- Use appropriate provider types (StateProvider, FutureProvider, etc.)
- Clean up resources in dispose methods

### Error Handling

- Handle errors gracefully
- Show user-friendly error messages
- Log errors for debugging
- Provide fallback UI when appropriate

### Accessibility

- Add semantic labels
- Support screen readers
- Ensure sufficient color contrast
- Test with accessibility tools

---

## 🤝 Getting Help

- Check existing documentation in `docs/`
- Review `GETTING_STARTED.md` for setup issues
- Search existing issues before creating new ones
- Ask questions in team channels
- Review Flutter documentation

---

## 📄 License

By contributing to TaskFlow, you agree that your contributions will be licensed under the project's license.

---

**Thank you for contributing to TaskFlow!** 🎉
