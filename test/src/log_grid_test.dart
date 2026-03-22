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
}
