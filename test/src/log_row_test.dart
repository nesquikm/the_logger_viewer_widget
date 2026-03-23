import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_logger_viewer_widget/src/level_colors.dart';
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

  group('LogRow visual', () {
    testWidgets('level color indicator dot uses correct color per level',
        (tester) async {
      for (final log in sampleLogs) {
        final level = log['level'] as String;
        final expectedColor = LevelColors.colorForLevel(level);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: LogRow(log: log),
            ),
          ),
        );

        // The dot is a Container with BoxDecoration
        final dotFinder = find.byWidgetPredicate((w) {
          if (w is Container && w.decoration is BoxDecoration) {
            final dec = w.decoration as BoxDecoration;
            return dec.shape == BoxShape.circle && dec.color == expectedColor;
          }
          return false;
        });
        expect(dotFinder, findsOneWidget,
            reason: 'Level color dot for $level should use $expectedColor');
      }
    });

    testWidgets('even row uses surfaceContainerLowest background',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LogRow(log: sampleLogs[0], isEvenRow: true),
          ),
        ),
      );

      final material = tester.widget<Material>(
        find.descendant(
          of: find.byType(LogRow),
          matching: find.byType(Material),
        ),
      );
      final theme = Theme.of(tester.element(find.byType(LogRow)));
      expect(material.color, theme.colorScheme.surfaceContainerLowest);
    });

    testWidgets('odd row uses surface background', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LogRow(log: sampleLogs[0], isEvenRow: false),
          ),
        ),
      );

      final material = tester.widget<Material>(
        find.descendant(
          of: find.byType(LogRow),
          matching: find.byType(Material),
        ),
      );
      final theme = Theme.of(tester.element(find.byType(LogRow)));
      expect(material.color, theme.colorScheme.surface);
    });

    testWidgets('selected row uses primaryContainer background',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LogRow(log: sampleLogs[0], isSelected: true),
          ),
        ),
      );

      final material = tester.widget<Material>(
        find.descendant(
          of: find.byType(LogRow),
          matching: find.byType(Material),
        ),
      );
      final theme = Theme.of(tester.element(find.byType(LogRow)));
      expect(material.color, theme.colorScheme.primaryContainer);
    });

    testWidgets('message text truncates with ellipsis', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LogRow(log: sampleLogs[0]),
          ),
        ),
      );

      final messageText = tester.widget<Text>(find.text('App started'));
      expect(messageText.maxLines, 1);
      expect(messageText.overflow, TextOverflow.ellipsis);
    });

    testWidgets('custom colorScheme overrides level color', (tester) async {
      const customColor = Colors.teal;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LogRow(
              log: sampleLogs[0],
              customColorScheme: const {'INFO': customColor},
            ),
          ),
        ),
      );

      final levelText = tester.widget<Text>(find.text('INFO'));
      expect(levelText.style?.color, customColor);

      // Dot should also use custom color
      final dotFinder = find.byWidgetPredicate((w) {
        if (w is Container && w.decoration is BoxDecoration) {
          final dec = w.decoration as BoxDecoration;
          return dec.shape == BoxShape.circle && dec.color == customColor;
        }
        return false;
      });
      expect(dotFinder, findsOneWidget);
    });
  });
}
