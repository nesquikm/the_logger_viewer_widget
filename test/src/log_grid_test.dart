import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_logger_viewer_widget/src/log_grid.dart';

import '../helpers.dart';

void main() {
  group('LogGrid', () {
    testWidgets('renders header row with column names', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: LogGrid(logs: sampleLogs),
            ),
          ),
        ),
      );

      expect(find.text('Timestamp'), findsOneWidget);
      expect(find.text('Level'), findsOneWidget);
      expect(find.text('Logger'), findsOneWidget);
      expect(find.text('Message'), findsOneWidget);
    });

    testWidgets('renders log entries', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: LogGrid(logs: sampleLogs),
            ),
          ),
        ),
      );

      expect(find.text('INFO'), findsOneWidget);
      expect(find.text('SEVERE'), findsOneWidget);
      expect(find.text('WARNING'), findsOneWidget);
      expect(find.text('App started'), findsOneWidget);
    });

    testWidgets('applies level color to level text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: LogGrid(logs: sampleLogs),
            ),
          ),
        ),
      );

      final severeText = tester.widget<Text>(find.text('SEVERE'));
      expect(severeText.style?.color, const Color(0xFFD32F2F));
    });

    testWidgets('calls onLogTap when row is tapped', (tester) async {
      Map<String, Object?>? tappedLog;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: LogGrid(
                logs: sampleLogs,
                onLogTap: (log) => tappedLog = log,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('App started'));
      expect(tappedLog?['id'], 1);
    });
  });

  group('LogGrid visual', () {
    testWidgets('column headers are present and in correct order',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: LogGrid(logs: sampleLogs),
            ),
          ),
        ),
      );

      // Verify order by comparing X positions of header texts
      final headers = ['Timestamp', 'Level', 'Logger', 'Message'];
      final positions = <double>[];
      for (final header in headers) {
        final finder = find.text(header);
        expect(finder, findsOneWidget, reason: '$header header should exist');
        final box = tester.getTopLeft(finder);
        positions.add(box.dx);
      }

      // Each header should be to the right of the previous one
      for (var i = 1; i < positions.length; i++) {
        expect(positions[i], greaterThan(positions[i - 1]),
            reason: '${headers[i]} should be after ${headers[i - 1]}');
      }
    });

    testWidgets('row color-coding alternates between even and odd rows',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: LogGrid(logs: sampleLogs),
            ),
          ),
        ),
      );

      final theme = Theme.of(tester.element(find.byType(LogGrid)));

      // Find Material widgets that are data rows (inside ListView)
      final materials = tester.widgetList<Material>(
        find.descendant(
          of: find.byType(ListView),
          matching: find.byType(Material),
        ),
      ).toList();

      // Even row (index 0)
      expect(materials[0].color, theme.colorScheme.surfaceContainerLowest);
      // Odd row (index 1)
      expect(materials[1].color, theme.colorScheme.surface);
      // Even row (index 2)
      expect(materials[2].color, theme.colorScheme.surfaceContainerLowest);
    });

    testWidgets('selected row is highlighted with primaryContainer',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: LogGrid(logs: sampleLogs, selectedLogId: 2),
            ),
          ),
        ),
      );

      final theme = Theme.of(tester.element(find.byType(LogGrid)));
      final materials = tester.widgetList<Material>(
        find.descendant(
          of: find.byType(ListView),
          matching: find.byType(Material),
        ),
      ).toList();

      // Row at index 1 (id=2) should be selected
      expect(materials[1].color, theme.colorScheme.primaryContainer);
    });

    testWidgets('scrollable with many rows', (tester) async {
      final manyLogs = List.generate(
        50,
        (i) => <String, Object?>{
          'id': i,
          'session_id': 1,
          'record_timestamp': '2026-01-01T10:00:00.000',
          'level': 'INFO',
          'logger_name': 'AppLogger',
          'message': 'Log message $i',
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: LogGrid(logs: manyLogs),
            ),
          ),
        ),
      );

      // First row visible
      expect(find.text('Log message 0'), findsOneWidget);
      // Last row not visible initially
      expect(find.text('Log message 49'), findsNothing);

      // Scroll down
      await tester.drag(find.byType(ListView), const Offset(0, -2000));
      await tester.pumpAndSettle();

      // Last row should now be visible
      expect(find.text('Log message 49'), findsOneWidget);
    });

    testWidgets('custom colorScheme is applied to level text',
        (tester) async {
      const customColor = Colors.deepPurple;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: LogGrid(
                logs: sampleLogs,
                customColorScheme: const {'INFO': customColor},
              ),
            ),
          ),
        ),
      );

      final infoText = tester.widget<Text>(find.text('INFO'));
      expect(infoText.style?.color, customColor);
    });

    testWidgets('message text truncates with ellipsis', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: LogGrid(logs: sampleLogs),
            ),
          ),
        ),
      );

      final messageText = tester.widget<Text>(find.text('App started'));
      expect(messageText.maxLines, 1);
      expect(messageText.overflow, TextOverflow.ellipsis);
    });
  });
}
