/// Integration test for authentication flow
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:taskflow/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Flow Integration Tests', () {
    testWidgets('complete login flow', (tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      // Should show splash screen first
      expect(find.text('TaskFlow'), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Should navigate to login screen
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);

      // Enter credentials
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'demo@taskflow.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'demo123',
      );
      await tester.pumpAndSettle();

      // Tap login button
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should navigate to home screen
      expect(find.text('Projects'), findsOneWidget);
      expect(find.text('Tasks'), findsOneWidget);
      expect(find.text('Calendar'), findsOneWidget);
    });

    testWidgets('signup and login flow', (tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to signup
      await tester.tap(find.text('Don\'t have an account? Sign up'));
      await tester.pumpAndSettle();

      // Should show signup screen
      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('Name'), findsOneWidget);

      // Enter signup details
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      await tester.enterText(
        find.byKey(const Key('name_field')),
        'Test User',
      );
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test$timestamp@taskflow.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'password123',
      );
      await tester.pumpAndSettle();

      // Tap signup button
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should navigate to home screen
      expect(find.text('Projects'), findsOneWidget);
    });

    testWidgets('invalid login shows error', (tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Enter invalid credentials
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'invalid@email.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'wrongpassword',
      );
      await tester.pumpAndSettle();

      // Tap login
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Should show error message
      expect(find.textContaining('failed'), findsOneWidget);
    });

    testWidgets('logout flow', (tester) async {
      // Login first
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.enterText(
        find.byKey(const Key('email_field')),
        'demo@taskflow.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'demo123',
      );
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to profile
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();

      // Tap logout
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Should return to login screen
      expect(find.text('Welcome Back'), findsOneWidget);
    });
  });

  group('Project and Task Flow Integration Tests', () {
    testWidgets('create project and add task', (tester) async {
      // Login
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.enterText(
        find.byKey(const Key('email_field')),
        'demo@taskflow.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'demo123',
      );
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Create new project
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      await tester.enterText(
        find.byKey(const Key('project_name_field')),
        'Test Project $timestamp',
      );
      await tester.enterText(
        find.byKey(const Key('project_description_field')),
        'Test project description',
      );
      await tester.tap(find.text('Create Project'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify project created
      expect(find.text('Test Project $timestamp'), findsOneWidget);

      // Open project
      await tester.tap(find.text('Test Project $timestamp'));
      await tester.pumpAndSettle();

      // Create task
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('task_title_field')),
        'Test Task',
      );
      await tester.enterText(
        find.byKey(const Key('task_description_field')),
        'Test task description',
      );
      await tester.tap(find.text('Create Task'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify task created
      expect(find.text('Test Task'), findsOneWidget);
    });

    testWidgets('update task status', (tester) async {
      // Login and navigate to tasks
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.enterText(
        find.byKey(const Key('email_field')),
        'demo@taskflow.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'demo123',
      );
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to tasks
      await tester.tap(find.text('Tasks'));
      await tester.pumpAndSettle();

      // Find first task
      final firstTask = find.byType(ListTile).first;
      await tester.tap(firstTask);
      await tester.pumpAndSettle();

      // Change status
      await tester.tap(find.text('Status'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('In Progress'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify status changed
      expect(find.text('In Progress'), findsOneWidget);
    });
  });

  group('Request Flow Integration Tests', () {
    testWidgets('send and accept request', (tester) async {
      // Login
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.enterText(
        find.byKey(const Key('email_field')),
        'demo@taskflow.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'demo123',
      );
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to requests
      await tester.tap(find.byIcon(Icons.request_page));
      await tester.pumpAndSettle();

      // View pending requests
      expect(find.text('Pending'), findsWidgets);

      // Accept first pending request if exists
      final acceptButton = find.text('Accept').first;
      if (tester.any(acceptButton)) {
        await tester.tap(acceptButton);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Verify request accepted
        expect(find.text('Accepted'), findsOneWidget);
      }
    });
  });

  group('QR Code Flow Integration Tests', () {
    testWidgets('generate and view QR code', (tester) async {
      // Login
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.enterText(
        find.byKey(const Key('email_field')),
        'demo@taskflow.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'demo123',
      );
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to profile
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();

      // Open QR code
      await tester.tap(find.text('My QR Code'));
      await tester.pumpAndSettle();

      // Verify QR code displayed
      expect(find.byType(Image), findsWidgets);
    });
  });
}
