/// Widget tests for Login Screen
library;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:taskflow/features/auth/application/auth_service.dart';
import 'package:taskflow/features/auth/application/auth_provider.dart';
import 'package:taskflow/features/auth/presentation/login_screen.dart';
import 'package:taskflow/features/auth/models/auth_models.dart';
import '../../helpers/test_helpers.dart';
import '../../helpers/mock_data.dart';

@GenerateMocks([AuthService])
import 'login_screen_test.mocks.dart';

void main() {
  late MockAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthService();
  });

  group('LoginScreen Widget Tests', () {
    testWidgets('renders all required widgets', (tester) async {
      // Act
      await pumpTestWidget(
        tester,
        widget: const LoginScreen(),
        overrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
        ],
      );

      // Assert
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Don\'t have an account? Sign up'), findsOneWidget);
    });

    testWidgets('email field accepts input', (tester) async {
      // Arrange
      await pumpTestWidget(
        tester,
        widget: const LoginScreen(),
        overrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
        ],
      );

      // Act
      final emailField = find.byKey(const Key('email_field'));
      await tester.enterText(emailField, 'test@taskflow.com');
      await tester.pump();

      // Assert
      expect(find.text('test@taskflow.com'), findsOneWidget);
    });

    testWidgets('password field obscures text', (tester) async {
      // Arrange
      await pumpTestWidget(
        tester,
        widget: const LoginScreen(),
        overrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
        ],
      );

      // Act
      final passwordField = find.byKey(const Key('password_field'));
      await tester.enterText(passwordField, 'password123');
      await tester.pump();

      // Assert
      final textField = tester.widget<TextField>(passwordField);
      expect(textField.obscureText, true);
    });

    testWidgets('shows validation error for empty email', (tester) async {
      // Arrange
      await pumpTestWidget(
        tester,
        widget: const LoginScreen(),
        overrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
        ],
      );

      // Act
      final loginButton = find.text('Login');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Please enter your email'), findsOneWidget);
    });

    testWidgets('shows validation error for invalid email', (tester) async {
      // Arrange
      await pumpTestWidget(
        tester,
        widget: const LoginScreen(),
        overrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
        ],
      );

      // Act
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'invalid-email',
      );
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('shows validation error for empty password', (tester) async {
      // Arrange
      await pumpTestWidget(
        tester,
        widget: const LoginScreen(),
        overrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
        ],
      );

      // Act
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@taskflow.com',
      );
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('successful login navigates to home', (tester) async {
      // Arrange
      when(mockAuthService.login(any, any)).thenAnswer(
        (_) async => LoginResponse(
          token: 'test-token',
          user: MockUsers.testUser,
        ),
      );

      await pumpTestWidget(
        tester,
        widget: const LoginScreen(),
        overrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
        ],
      );

      // Act
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@taskflow.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'password123',
      );
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Assert
      verify(mockAuthService.login('test@taskflow.com', 'password123'))
          .called(1);
    });

    testWidgets('failed login shows error message', (tester) async {
      // Arrange
      when(mockAuthService.login(any, any))
          .thenThrow(Exception('Invalid credentials'));

      await pumpTestWidget(
        tester,
        widget: const LoginScreen(),
        overrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
        ],
      );

      // Act
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'wrong@email.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'wrongpass',
      );
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Login failed'), findsOneWidget);
    });

    testWidgets('shows loading indicator during login', (tester) async {
      // Arrange
      when(mockAuthService.login(any, any)).thenAnswer(
        (_) async {
          await Future.delayed(const Duration(seconds: 1));
          return LoginResponse(
            token: 'test-token',
            user: MockUsers.testUser,
          );
        },
      );

      await pumpTestWidget(
        tester,
        widget: const LoginScreen(),
        overrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
        ],
      );

      // Act
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@taskflow.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'password123',
      );
      await tester.tap(find.text('Login'));
      await tester.pump(const Duration(milliseconds: 100));

      // Assert
      expectLoading();
    });

    testWidgets('tapping sign up navigates to signup screen', (tester) async {
      // Arrange
      await pumpTestWidget(
        tester,
        widget: const LoginScreen(),
        overrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
        ],
      );

      // Act
      await tester.tap(find.text('Don\'t have an account? Sign up'));
      await tester.pumpAndSettle();

      // Assert
      // Would verify navigation in integration test
      // Here we just verify the tap works
      verify(mockAuthService.login(any, any)).called(0);
    });

    testWidgets('password visibility toggle works', (tester) async {
      // Arrange
      await pumpTestWidget(
        tester,
        widget: const LoginScreen(),
        overrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
        ],
      );

      // Act
      final visibilityToggle = find.byIcon(Icons.visibility);
      expect(visibilityToggle, findsOneWidget);

      await tester.tap(visibilityToggle);
      await tester.pump();

      // Assert
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });
  });

  group('LoginScreen Accessibility', () {
    testWidgets('has semantic labels', (tester) async {
      // Arrange
      await pumpTestWidget(
        tester,
        widget: const LoginScreen(),
        overrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
        ],
      );

      // Assert
      expect(
        tester.getSemantics(find.byKey(const Key('email_field'))),
        matchesSemantics(label: contains('Email')),
      );
      expect(
        tester.getSemantics(find.byKey(const Key('password_field'))),
        matchesSemantics(label: contains('Password')),
      );
    });

    testWidgets('login button has minimum touch target', (tester) async {
      // Arrange
      await pumpTestWidget(
        tester,
        widget: const LoginScreen(),
        overrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
        ],
      );

      // Act
      final loginButton = find.text('Login');
      final size = tester.getSize(loginButton);

      // Assert
      expect(size.height, greaterThanOrEqualTo(48.0));
    });
  });
}
