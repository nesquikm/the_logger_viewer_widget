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
}
