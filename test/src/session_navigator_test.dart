import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_logger_viewer_widget/src/session_navigator.dart';

void main() {
  group('SessionNavigator', () {
    testWidgets('renders session dropdown with all sessions', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SessionNavigator(
              sessionIds: const [1, 2, 3],
              selectedSessionId: null,
              onSessionChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(DropdownButton<int?>), findsOneWidget);
      expect(find.text('All sessions'), findsOneWidget);
    });

    testWidgets('selects session from dropdown', (tester) async {
      int? selectedSession;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SessionNavigator(
              sessionIds: const [1, 2, 3],
              selectedSessionId: null,
              onSessionChanged: (id) => selectedSession = id,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(DropdownButton<int?>));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Session 2').last);
      await tester.pumpAndSettle();

      expect(selectedSession, 2);
    });

    testWidgets('navigation buttons work correctly', (tester) async {
      int? selectedSession;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SessionNavigator(
              sessionIds: const [1, 2, 3],
              selectedSessionId: 2,
              onSessionChanged: (id) => selectedSession = id,
            ),
          ),
        ),
      );

      // Previous button should navigate to session 1
      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pump();
      expect(selectedSession, 1);

      // Next button should navigate to session 3
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pump();
      expect(selectedSession, 3);
    });

    testWidgets('first/last buttons navigate to extremes', (tester) async {
      int? selectedSession;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SessionNavigator(
              sessionIds: const [1, 2, 3],
              selectedSessionId: 2,
              onSessionChanged: (id) => selectedSession = id,
            ),
          ),
        ),
      );

      // First button
      await tester.tap(find.byIcon(Icons.first_page));
      await tester.pump();
      expect(selectedSession, 1);

      // Last button
      await tester.tap(find.byIcon(Icons.last_page));
      await tester.pump();
      expect(selectedSession, 3);
    });

    testWidgets('disables nav buttons when at edges', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SessionNavigator(
              sessionIds: const [1, 2, 3],
              selectedSessionId: 1,
              onSessionChanged: (_) {},
            ),
          ),
        ),
      );

      // At first session, previous and first should be disabled
      final prevButton = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.chevron_left),
      );
      expect(prevButton.onPressed, isNull);

      final firstButton = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.first_page),
      );
      expect(firstButton.onPressed, isNull);
    });

    testWidgets('returns empty widget when no sessions', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SessionNavigator(
              sessionIds: const [],
              selectedSessionId: null,
              onSessionChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(DropdownButton<int?>), findsNothing);
    });
  });
}
