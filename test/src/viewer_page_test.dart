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
}
