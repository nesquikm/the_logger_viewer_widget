import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_logger_viewer_widget/src/viewer_page.dart';
import 'package:the_logger_viewer_widget/src/viewer_widget.dart';

void main() {
  group('TheLoggerViewerPage', () {
    testWidgets('renders app bar with title', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TheLoggerViewerPage(),
        ),
      );

      expect(find.text('Log Viewer'), findsOneWidget);
      expect(find.byType(TheLoggerViewerWidget), findsOneWidget);
    });

    testWidgets('show() pushes page onto navigator', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => TheLoggerViewerWidget.show(context),
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Log Viewer'), findsOneWidget);
    });

    testWidgets('route() returns valid MaterialPageRoute', (tester) async {
      final route = TheLoggerViewerWidget.route();
      expect(route, isA<MaterialPageRoute<void>>());
    });
  });

  group('TheLoggerViewerPage visual', () {
    testWidgets('back navigation is available via app bar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const TheLoggerViewerPage(),
                ),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // App bar back button should be present
      expect(find.byType(BackButton), findsOneWidget);

      // Tap back
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      // Should be back on original page
      expect(find.text('Open'), findsOneWidget);
      expect(find.text('Log Viewer'), findsNothing);
    });

    testWidgets('full-screen layout fills body with TheLoggerViewerWidget',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TheLoggerViewerPage(),
        ),
      );

      // Scaffold with AppBar and TheLoggerViewerWidget in body
      expect(find.byType(Scaffold), findsWidgets);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(TheLoggerViewerWidget), findsOneWidget);
    });

    testWidgets('passes through configuration options', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TheLoggerViewerPage(
            showExport: false,
            maxRecords: 100,
          ),
        ),
      );

      final widget = tester.widget<TheLoggerViewerWidget>(
        find.byType(TheLoggerViewerWidget),
      );
      expect(widget.showExport, false);
      expect(widget.maxRecords, 100);
    });
  });
}
