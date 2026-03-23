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

  group('RecordDetails visual', () {
    testWidgets('all fields rendered for complete log entry', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: RecordDetails(log: sampleLogs[1]),
            ),
          ),
        ),
      );

      // Level badge
      expect(find.text('SEVERE'), findsOneWidget);
      // Logger name
      expect(find.text('NetworkLogger'), findsOneWidget);
      // Detail field labels
      expect(find.text('Timestamp'), findsOneWidget);
      expect(find.text('Session'), findsOneWidget);
      expect(find.text('Message'), findsOneWidget);
      // Timestamp value
      expect(find.text('2026-01-01T10:01:00.000'), findsOneWidget);
      // Session value
      expect(find.text('1'), findsOneWidget);
      // Error section
      expect(find.text('Error'), findsOneWidget);
      expect(find.textContaining('SocketException'), findsOneWidget);
      // Stack trace section
      expect(find.text('Stack Trace'), findsOneWidget);
      expect(find.textContaining('#0 main'), findsOneWidget);
    });

    testWidgets('JSON is pretty-printed with indentation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: RecordDetails(log: sampleLogs[2]),
            ),
          ),
        ),
      );

      // The JSON should be formatted with indentation
      expect(find.textContaining('"key": "value"'), findsOneWidget);
      expect(find.textContaining('"nested"'), findsOneWidget);
    });

    testWidgets('copy button is present with correct icon and tooltip',
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

      expect(find.byIcon(Icons.copy), findsOneWidget);
      final copyButton = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.copy),
      );
      expect(copyButton.tooltip, 'Copy to clipboard');
    });

    testWidgets('search highlights are visible with HighlightedText',
        (tester) async {
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

      // HighlightedText renders as RichText with highlighted spans
      final richTexts = tester.widgetList<RichText>(find.byType(RichText));
      // At least one RichText should contain a span with yellow background
      final hasHighlight = richTexts.any((rt) {
        final span = rt.text as TextSpan;
        return span.children?.any((child) {
              if (child is TextSpan) {
                return child.style?.backgroundColor != null;
              }
              return false;
            }) ??
            false;
      });
      expect(hasHighlight, isTrue);
    });

    testWidgets('level badge uses level color with translucent background',
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

      // Find the level badge container - it has horizontal padding of 8,2
      // and contains the level text
      // The level badge uses levelColor.withValues(alpha: 0.15)
      final expectedColor =
          const Color(0xFF1976D2).withValues(alpha: 0.15); // INFO blue
      final badgeFinder = find.ancestor(
        of: find.text('INFO'),
        matching: find.byWidgetPredicate((w) {
          if (w is Container && w.decoration is BoxDecoration) {
            final dec = w.decoration as BoxDecoration;
            return dec.borderRadius != null && dec.color == expectedColor;
          }
          return false;
        }),
      );
      expect(badgeFinder, findsOneWidget);
    });

    testWidgets('custom colorScheme overrides level color', (tester) async {
      const customColor = Colors.amber;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: RecordDetails(
                log: sampleLogs[0],
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
