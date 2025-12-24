# TaskFlow Testing Guide

## 🎯 Professional Testing Strategy

### Testing Levels

#### 1. **Unit Tests** (70% coverage target)
Test individual functions, classes, and utilities in isolation.

```bash
# Run unit tests
flutter test test/unit/

# Run with coverage
flutter test --coverage
```

**What to test:**
- Business logic in providers
- Utility functions (search, date formatting, etc.)
- Model validation
- Service methods

**Example:**
```dart
test('TaskItem should have pending status by default', () {
  final task = TaskItem(
    id: '1',
    title: 'Test',
    dueDate: DateTime.now(),
    status: TaskStatus.pending,
  );
  expect(task.status, TaskStatus.pending);
});
```

#### 2. **Widget Tests** (20% coverage)
Test UI components and user interactions.

```bash
# Run widget tests
flutter test test/widget/
```

**What to test:**
- User interactions (taps, swipes, input)
- Widget rendering
- State changes
- Navigation

**Example:**
```dart
testWidgets('Task card shows title and due date', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: TaskCard(task: mockTask),
    ),
  );
  
  expect(find.text('Test Task'), findsOneWidget);
  expect(find.text('Due: Tomorrow'), findsOneWidget);
});
```

#### 3. **Integration Tests** (10% coverage)
Test complete user flows across multiple screens.

```bash
# Run integration tests
flutter test integration_test/
```

**What to test:**
- Complete user journeys
- Multi-screen workflows
- API integration
- Database operations

#### 4. **Golden Tests** (Visual Regression)
Compare screenshots to detect UI changes.

```bash
# Update golden files
flutter test --update-goldens

# Run golden tests
flutter test test/golden/
```

---

## 🔧 Testing Tools & Frameworks

### Current Setup
- `flutter_test` - Core testing framework
- `integration_test` - End-to-end testing
- `mockito` - Mocking dependencies (recommended)
- `bloc_test` - State management testing (recommended)

### Recommended Additions

Add to `pubspec.yaml`:
```yaml
dev_dependencies:
  mockito: ^5.4.0
  build_runner: ^2.4.0
  bloc_test: ^9.1.0
  faker: ^2.1.0  # Generate test data
  network_image_mock: ^2.1.1  # Mock images
```

---

## 📝 Testing Best Practices

### 1. **AAA Pattern**
```dart
test('should format date correctly', () {
  // Arrange
  final date = DateTime(2025, 12, 24);
  
  // Act
  final result = formatDate(date);
  
  // Assert
  expect(result, 'Dec 24, 2025');
});
```

### 2. **Test Organization**
```
test/
├── unit/                  # Unit tests
│   ├── models/
│   ├── services/
│   └── utils/
├── widget/                # Widget tests
│   ├── screens/
│   └── components/
├── integration_test/      # E2E tests
│   └── user_flows/
└── golden/                # Visual regression
    └── screens/
```

### 3. **Mock External Dependencies**
```dart
class MockTaskRepository extends Mock implements TaskRepository {}

testWidgets('loads tasks from repository', (tester) async {
  final mockRepo = MockTaskRepository();
  when(mockRepo.getTasks()).thenAnswer((_) async => mockTasks);
  
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        taskRepositoryProvider.overrideWithValue(mockRepo),
      ],
      child: TaskListScreen(),
    ),
  );
});
```

---

## 🚀 CI/CD Testing Pipeline

### GitHub Actions Example
```yaml
name: Test

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Analyze code
        run: flutter analyze
      
      - name: Run tests
        run: flutter test --coverage
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
```

---

## 🔍 Code Quality Tools

### 1. **Static Analysis**
```bash
# Analyze code for issues
flutter analyze

# Check formatting
dart format --set-exit-if-changed .
```

### 2. **Code Coverage**
```bash
# Generate coverage report
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### 3. **Performance Testing**
```dart
testWidgets('calendar renders quickly', (tester) async {
  await tester.pumpWidget(CalendarScreen());
  
  final stopwatch = Stopwatch()..start();
  await tester.pumpAndSettle();
  stopwatch.stop();
  
  expect(stopwatch.elapsedMilliseconds, lessThan(1000));
});
```

---

## 📊 Testing Metrics

### Target Metrics
- **Code Coverage**: > 80%
- **Test Pass Rate**: 100%
- **Build Time**: < 5 minutes
- **Test Execution**: < 2 minutes

### Monitoring
```bash
# Generate coverage report
flutter test --coverage

# View line coverage
lcov --list coverage/lcov.info
```

---

## 🐛 Debugging Tests

### Common Issues

1. **Async State Issues**
```dart
await tester.pumpAndSettle();  // Wait for animations
await tester.pump(Duration(seconds: 1));  // Wait specific time
```

2. **Provider Scope Missing**
```dart
await tester.pumpWidget(
  ProviderScope(  // Always wrap in ProviderScope
    child: MyWidget(),
  ),
);
```

3. **Golden Test Failures**
```bash
# Update golden files
flutter test --update-goldens

# Run on same platform
flutter test --platform chrome
```

---

## 🎓 Testing Resources

- [Flutter Testing Docs](https://docs.flutter.dev/testing)
- [Effective Dart: Testing](https://dart.dev/guides/language/effective-dart/testing)
- [Widget Test Best Practices](https://flutter.dev/docs/cookbook/testing/widget)
- [Integration Testing](https://docs.flutter.dev/testing/integration-tests)

---

## 📋 Testing Checklist

Before releasing:
- [ ] All tests pass
- [ ] Code coverage > 80%
- [ ] No critical analyzer warnings
- [ ] Golden tests updated
- [ ] Performance tests pass
- [ ] Manual testing on target devices
- [ ] Accessibility testing
- [ ] Security testing (auth, data)

---

## 🔄 Continuous Testing

### Test-Driven Development (TDD)
1. **Red**: Write a failing test
2. **Green**: Write minimal code to pass
3. **Refactor**: Improve code quality

### Testing During Development
```bash
# Watch mode - auto-run tests on file changes
flutter test --watch

# Run specific test file
flutter test test/unit/task_service_test.dart

# Run tests matching pattern
flutter test --name "TaskService"
```

---

## 🛡️ Security Testing

1. **Authentication Testing**
   - Test login/logout flows
   - Test session management
   - Test token expiration

2. **Data Validation**
   - Test input sanitization
   - Test XSS prevention
   - Test SQL injection prevention

3. **Permission Testing**
   - Test role-based access
   - Test data isolation
   - Test API authorization

---

## 📱 Device Testing

### Emulators/Simulators
```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device-id>

# Run tests on device
flutter test -d <device-id>
```

### Real Devices
- Test on different screen sizes
- Test on different OS versions
- Test on different manufacturers
- Test offline scenarios
- Test low battery scenarios

---

## 🎯 Next Steps

1. **Add Unit Tests**: Start with services and utilities
2. **Expand Widget Tests**: Cover critical user paths
3. **Setup CI/CD**: Automate testing on every commit
4. **Add Integration Tests**: Test complete workflows
5. **Monitor Coverage**: Aim for 80%+ coverage
6. **Performance Testing**: Add benchmarks

---

## 💡 Pro Tips

1. **Test the behavior, not the implementation**
2. **Keep tests simple and focused**
3. **Use descriptive test names**
4. **Mock external dependencies**
5. **Test error scenarios**
6. **Maintain test independence**
7. **Use fixtures for test data**
8. **Run tests before committing**
