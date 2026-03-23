import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_logger_viewer_widget/src/log_list.dart';

import '../helpers.dart';

void main() {
  group('LogList', () {
    testWidgets('renders log entries in list format', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 600,
              child: LogList(logs: sampleLogs),
            ),
          ),
        ),
      );

      expect(find.text('INFO'), findsOneWidget);
      expect(find.text('SEVERE'), findsOneWidget);
      expect(find.text('App started'), findsOneWidget);
      expect(find.text('Connection failed'), findsOneWidget);
    });

    testWidgets('shows logger name', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 600,
              child: LogList(logs: sampleLogs),
            ),
          ),
        ),
      );

      expect(find.text('AppLogger'), findsWidgets);
      expect(find.text('NetworkLogger'), findsOneWidget);
    });

    testWidgets('calls onLogTap when row is tapped', (tester) async {
      Map<String, Object?>? tappedLog;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 600,
              child: LogList(
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

    testWidgets('applies level color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 600,
              child: LogList(logs: sampleLogs),
            ),
          ),
        ),
      );

      final severeText = tester.widget<Text>(find.text('SEVERE'));
      expect(severeText.style?.color, const Color(0xFFD32F2F));
    });
  });

  group('LogList visual', () {
    testWidgets('compact layout renders level, logger, time header + message body',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 600,
              child: LogList(logs: [sampleLogs[0]]),
            ),
          ),
        ),
      );

      // Header row contains level, logger name, and timestamp
      expect(find.text('INFO'), findsOneWidget);
      expect(find.text('AppLogger'), findsOneWidget);
      expect(find.text('10:00:00'), findsOneWidget);

      // Message body
      expect(find.text('App started'), findsOneWidget);
    });

    testWidgets('level color indicator dot is present', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 600,
              child: LogList(logs: [sampleLogs[0]]),
            ),
          ),
        ),
      );

      final expectedColor = const Color(0xFF1976D2); // INFO blue
      final dotFinder = find.byWidgetPredicate((w) {
        if (w is Container && w.decoration is BoxDecoration) {
          final dec = w.decoration as BoxDecoration;
          return dec.shape == BoxShape.circle && dec.color == expectedColor;
        }
        return false;
      });
      expect(dotFinder, findsOneWidget);
    });

    testWidgets('alternating row backgrounds', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 600,
              child: LogList(logs: sampleLogs),
            ),
          ),
        ),
      );

      final theme = Theme.of(tester.element(find.byType(LogList)));
      final materials = tester.widgetList<Material>(
        find.descendant(
          of: find.byType(ListView),
          matching: find.byType(Material),
        ),
      ).toList();

      expect(materials[0].color, theme.colorScheme.surfaceContainerLowest);
      expect(materials[1].color, theme.colorScheme.surface);
    });

    testWidgets('selected row uses primaryContainer', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 600,
              child: LogList(logs: sampleLogs, selectedLogId: 1),
            ),
          ),
        ),
      );

      final theme = Theme.of(tester.element(find.byType(LogList)));
      final materials = tester.widgetList<Material>(
        find.descendant(
          of: find.byType(ListView),
          matching: find.byType(Material),
        ),
      ).toList();

      expect(materials[0].color, theme.colorScheme.primaryContainer);
    });

    testWidgets('message truncates at 2 lines with ellipsis', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 600,
              child: LogList(logs: [sampleLogs[0]]),
            ),
          ),
        ),
      );

      final messageText = tester.widget<Text>(find.text('App started'));
      expect(messageText.maxLines, 2);
      expect(messageText.overflow, TextOverflow.ellipsis);
    });

    testWidgets('custom colorScheme is applied', (tester) async {
      const customColor = Colors.pink;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 600,
              child: LogList(
                logs: [sampleLogs[0]],
                customColorScheme: const {'INFO': customColor},
              ),
            ),
          ),
        ),
      );

      final levelText = tester.widget<Text>(find.text('INFO'));
      expect(levelText.style?.color, customColor);
    });
  });
}
