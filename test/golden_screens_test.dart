import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:taskflow/features/notifications/presentation/notifications_screen.dart';
import 'package:taskflow/features/projects/presentation/projects_screen.dart';
import 'package:taskflow/features/requests/presentation/requests_screen.dart';
import 'package:taskflow/features/schedule/presentation/calendar_screen.dart';
import 'package:taskflow/design_system/widgets/app_scaffold.dart';

Future<void> _pumpGolden(WidgetTester tester, Widget child) async {
  tester.binding.window.physicalSizeTestValue = const Size(450, 900);
  tester.binding.window.devicePixelRatioTestValue = 1.0;
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF9747FF),
            secondary: Color(0xFFFD32E5),
          ),
        ),
        home: AppScaffold(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: child,
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('Requests screen golden', (tester) async {
    await _pumpGolden(tester, const RequestsScreen());
    await expectLater(
      find.byType(RequestsScreen),
      matchesGoldenFile('goldens/requests.png'),
    );
  });

  testWidgets('Notifications screen golden', (tester) async {
    await _pumpGolden(tester, const NotificationsScreen());
    await expectLater(
      find.byType(NotificationsScreen),
      matchesGoldenFile('goldens/notifications.png'),
    );
  });

  testWidgets('Calendar screen golden', (tester) async {
    await _pumpGolden(tester, const CalendarScreen());
    await expectLater(
      find.byType(CalendarScreen),
      matchesGoldenFile('goldens/calendar.png'),
    );
  });

  testWidgets('Projects screen golden', (tester) async {
    await _pumpGolden(tester, const ProjectsScreen());
    await expectLater(
      find.byType(ProjectsScreen),
      matchesGoldenFile('goldens/projects.png'),
    );
  });
}
