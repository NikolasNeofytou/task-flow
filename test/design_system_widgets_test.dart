import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:taskflow/design_system/widgets/app_card.dart';
import 'package:taskflow/design_system/widgets/app_pill.dart';
import 'package:taskflow/design_system/widgets/app_state.dart';
import 'package:taskflow/design_system/widgets/app_badge.dart';
import 'package:taskflow/design_system/widgets/app_avatar.dart';

void main() {
  testWidgets('AppCard triggers onTap', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppCard(
            onTap: () => tapped = true,
            child: const Text('Card'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Card'));
    expect(tapped, isTrue);
  });

  testWidgets('AppStateView empty renders message', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppStateView.empty(message: 'Empty state'),
        ),
      ),
    );
    expect(find.text('Empty state'), findsOneWidget);
  });

  testWidgets('AppPill shows label', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppPill(label: 'Status', color: Colors.green),
        ),
      ),
    );
    expect(find.text('Status'), findsOneWidget);
  });

  testWidgets('AppBadge shows dot and label', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppBadge(color: Colors.red, label: 'New'),
        ),
      ),
    );
    expect(find.text('New'), findsOneWidget);
  });

  testWidgets('AppAvatar renders initials', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppAvatar(label: 'Display Name'),
        ),
      ),
    );
    expect(find.text('DN'), findsOneWidget);
  });
}
