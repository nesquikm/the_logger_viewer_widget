import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_logger_viewer_widget/src/extensions/text_extensions.dart';

void main() {
  group('HighlightedText', () {
    testWidgets('renders plain text when highlight is empty', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HighlightedText(text: 'Hello world', highlight: ''),
          ),
        ),
      );

      expect(find.text('Hello world'), findsOneWidget);
    });

    testWidgets('highlights matching text case-insensitively', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HighlightedText(text: 'Hello World', highlight: 'world'),
          ),
        ),
      );

      // Should render as RichText with highlighted spans
      expect(find.byType(RichText), findsOneWidget);
    });

    testWidgets('highlights multiple occurrences', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HighlightedText(text: 'foo bar foo', highlight: 'foo'),
          ),
        ),
      );

      final richText = tester.widget<RichText>(find.byType(RichText));
      final textSpan = richText.text as TextSpan;
      // "foo" + " bar " + "foo" + "" (trailing) = 4 spans
      // Verify the highlighted spans exist
      expect(
        textSpan.children!.where((s) => s.toPlainText() == 'foo'),
        hasLength(2),
      );
    });

    testWidgets('renders plain text when no match found', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HighlightedText(text: 'Hello', highlight: 'xyz'),
          ),
        ),
      );

      // Still uses RichText but with single unmatched span
      final richText = tester.widget<RichText>(find.byType(RichText));
      final textSpan = richText.text as TextSpan;
      expect(textSpan.children, hasLength(1));
      expect(textSpan.children!.first.toPlainText(), 'Hello');
    });
  });
}
