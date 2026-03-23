import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:the_logger_viewer_widget/src/export_button.dart';

import '../helpers.dart';

void main() {
  late MockTheLogger mockLogger;

  setUp(() {
    mockLogger = MockTheLogger();
  });

  group('ExportButton', () {
    testWidgets('shows export icon button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExportButton(logger: mockLogger),
          ),
        ),
      );

      expect(find.byIcon(Icons.file_download), findsOneWidget);
    });

    testWidgets('shows loading indicator during export', (tester) async {
      final completer = Completer<String>();
      when(() => mockLogger.writeAllLogsToJson(any()))
          .thenAnswer((_) => completer.future);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExportButton(logger: mockLogger),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.file_download));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.file_download), findsNothing);

      completer.complete('/path/to/logs.json');
      await tester.pumpAndSettle();
    });

    testWidgets('calls onExport callback with file path', (tester) async {
      String? exportedPath;
      when(() => mockLogger.writeAllLogsToJson(any()))
          .thenAnswer((_) async => '/path/to/logs.json');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExportButton(
              logger: mockLogger,
              onExport: (path) => exportedPath = path,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.file_download));
      await tester.pumpAndSettle();

      expect(exportedPath, '/path/to/logs.json');
      verify(() => mockLogger.writeAllLogsToJson(any())).called(1);
    });

    testWidgets('shows snackbar when no onExport callback', (tester) async {
      when(() => mockLogger.writeAllLogsToJson(any()))
          .thenAnswer((_) async => '/path/to/logs.json');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExportButton(logger: mockLogger),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.file_download));
      await tester.pumpAndSettle();

      expect(find.textContaining('exported'), findsOneWidget);
    });

    testWidgets('shows error snackbar on export failure', (tester) async {
      when(() => mockLogger.writeAllLogsToJson(any()))
          .thenThrow(Exception('Export error'));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExportButton(logger: mockLogger),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.file_download));
      await tester.pumpAndSettle();

      expect(find.textContaining('Export failed'), findsOneWidget);
    });
  });

  group('ExportButton visual', () {
    testWidgets('loading indicator replaces button during export',
        (tester) async {
      final completer = Completer<String>();
      when(() => mockLogger.writeAllLogsToJson(any()))
          .thenAnswer((_) => completer.future);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExportButton(logger: mockLogger),
          ),
        ),
      );

      // Before export: icon visible, no spinner
      expect(find.byIcon(Icons.file_download), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // Tap export
      await tester.tap(find.byIcon(Icons.file_download));
      await tester.pump();

      // During export: spinner visible, icon gone
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.file_download), findsNothing);

      // The spinner has specific dimensions (24x24) and thin stroke
      final sizedBox = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byType(CircularProgressIndicator),
          matching: find.byType(SizedBox),
        ),
      );
      expect(sizedBox.width, 24);
      expect(sizedBox.height, 24);

      final spinner = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(spinner.strokeWidth, 2);

      // Complete export to clean up
      completer.complete('/path/to/logs.json');
      await tester.pumpAndSettle();
    });

    testWidgets('button is re-enabled after export completes', (tester) async {
      when(() => mockLogger.writeAllLogsToJson(any()))
          .thenAnswer((_) async => '/path/to/logs.json');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExportButton(logger: mockLogger),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.file_download));
      await tester.pumpAndSettle();

      // After export completes, button should be back
      expect(find.byIcon(Icons.file_download), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('export button has correct tooltip', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExportButton(logger: mockLogger),
          ),
        ),
      );

      final iconButton = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.file_download),
      );
      expect(iconButton.tooltip, 'Export logs');
    });
  });
}
