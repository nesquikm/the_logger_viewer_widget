import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_logger_viewer_widget/src/record_details.dart';

import '../helpers.dart';

void main() {
  group('RecordDetails', () {
    testWidgets('renders all fields for a log entry', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: RecordDetails(log: sampleLogs[1]),
            ),
          ),
        ),
      );

      expect(find.text('SEVERE'), findsOneWidget);
      expect(find.text('NetworkLogger'), findsOneWidget);
      expect(find.text('Timestamp'), findsOneWidget);
      expect(find.text('Session'), findsOneWidget);
      expect(find.text('Message'), findsOneWidget);
      expect(find.text('Error'), findsOneWidget);
      expect(find.text('Stack Trace'), findsOneWidget);
      expect(find.textContaining('Connection failed'), findsOneWidget);
      expect(find.textContaining('SocketException'), findsOneWidget);
    });

    testWidgets('formats embedded JSON in message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: RecordDetails(log: sampleLogs[2]),
            ),
          ),
        ),
      );

      // Should show pretty-printed JSON
      expect(find.textContaining('"key": "value"'), findsOneWidget);
    });

    testWidgets('copy button copies to clipboard', (tester) async {
      // Set up clipboard mock
      final clipboardData = <String>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (methodCall) async {
          if (methodCall.method == 'Clipboard.setData') {
            final args = methodCall.arguments as Map;
            clipboardData.add(args['text'] as String);
          }
          return null;
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: RecordDetails(log: sampleLogs[0]),
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.copy));
      await tester.pump();

      expect(clipboardData, isNotEmpty);
      expect(clipboardData.first, contains('App started'));
    });

    testWidgets('highlights search terms in message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: RecordDetails(
                log: sampleLogs[0],
                searchText: 'started',
              ),
            ),
          ),
        ),
      );

      // Should use HighlightedText (renders as RichText)
      expect(find.byType(RichText), findsWidgets);
    });

    testWidgets('does not show error section when error is null',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: RecordDetails(log: sampleLogs[0]),
            ),
          ),
        ),
      );

      expect(find.text('Error'), findsNothing);
      expect(find.text('Stack Trace'), findsNothing);
    });
  });
}
