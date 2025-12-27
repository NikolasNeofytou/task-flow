/// Test helpers and utilities for TaskFlow tests
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// Creates a testable widget wrapped with necessary providers
Widget createTestableWidget({
  required Widget child,
  List<Override> overrides = const [],
  GoRouter? router,
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      home: router != null
          ? MaterialApp.router(
              routerConfig: router,
            )
          : child,
    ),
  );
}

/// Pumps a widget and settles all animations
Future<void> pumpTestWidget(
  WidgetTester tester, {
  required Widget widget,
  List<Override> overrides = const [],
}) async {
  await tester.pumpWidget(
    createTestableWidget(
      child: widget,
      overrides: overrides,
    ),
  );
  await tester.pumpAndSettle();
}

/// Finds a widget by type and returns it
T findWidgetByType<T extends Widget>(WidgetTester tester) {
  return tester.widget<T>(find.byType(T));
}

/// Simulates a tap and waits for animations
Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// Simulates entering text and waits for animations
Future<void> enterTextAndSettle(
  WidgetTester tester,
  Finder finder,
  String text,
) async {
  await tester.enterText(finder, text);
  await tester.pumpAndSettle();
}

/// Scrolls until a widget is visible
Future<void> scrollUntilVisible(
  WidgetTester tester, {
  required Finder item,
  required Finder scrollable,
  double delta = 300.0,
  int maxScrolls = 50,
}) async {
  int scrolls = 0;
  while (!tester.any(item) && scrolls < maxScrolls) {
    await tester.drag(scrollable, Offset(0, -delta));
    await tester.pump();
    scrolls++;
  }
}

/// Verifies that no errors are shown on screen
void expectNoErrors() {
  expect(find.text('Error'), findsNothing);
  expect(find.byType(ErrorWidget), findsNothing);
}

/// Verifies loading indicators are shown
void expectLoading() {
  expect(
    find.byType(CircularProgressIndicator),
    findsOneWidget,
  );
}

/// Verifies loading indicators are not shown
void expectNotLoading() {
  expect(
    find.byType(CircularProgressIndicator),
    findsNothing,
  );
}

/// Waits for a condition to be true
Future<void> waitFor(
  bool Function() condition, {
  Duration timeout = const Duration(seconds: 5),
  Duration interval = const Duration(milliseconds: 100),
}) async {
  final endTime = DateTime.now().add(timeout);
  while (!condition()) {
    if (DateTime.now().isAfter(endTime)) {
      throw TimeoutException('Condition not met within timeout');
    }
    await Future.delayed(interval);
  }
}

/// Custom exception for test timeouts
class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);

  @override
  String toString() => 'TimeoutException: $message';
}

/// Test delay utilities
class TestDelay {
  static const short = Duration(milliseconds: 100);
  static const medium = Duration(milliseconds: 500);
  static const long = Duration(seconds: 1);
  static const veryLong = Duration(seconds: 2);
}

/// Screen size presets for responsive testing
class TestScreenSizes {
  static const Size mobile = Size(375, 667); // iPhone SE
  static const Size tablet = Size(768, 1024); // iPad
  static const Size desktop = Size(1920, 1080); // HD
}

/// Sets the screen size for testing
void setScreenSize(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
}

/// Resets screen size to default
void resetScreenSize(WidgetTester tester) {
  tester.view.resetPhysicalSize();
  tester.view.resetDevicePixelRatio();
}
