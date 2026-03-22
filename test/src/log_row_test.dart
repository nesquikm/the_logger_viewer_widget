import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_logger_viewer_widget/src/log_row.dart';

import '../helpers.dart';

void main() {
  group('LogRow', () {
    testWidgets('displays level and message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LogRow(log: sampleLogs[0]),
          ),
        ),
      );

      expect(find.text('INFO'), findsOneWidget);
      expect(find.text('App started'), findsOneWidget);
    });

    testWidgets('applies level color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LogRow(log: sampleLogs[1]),
          ),
        ),
      );

      final levelText = tester.widget<Text>(find.text('SEVERE'));
      expect(levelText.style?.color, const Color(0xFFD32F2F)); // Red 700
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LogRow(
              log: sampleLogs[0],
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('App started'));
      expect(tapped, isTrue);
    });
  });
}
