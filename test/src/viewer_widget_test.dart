import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:the_logger_viewer_widget/src/log_data_source.dart';
import 'package:the_logger_viewer_widget/src/viewer_widget.dart';

import '../helpers.dart';

void main() {
  late MockTheLogger mockLogger;

  setUp(() {
    mockLogger = MockTheLogger();
    when(() => mockLogger.getAllLogsAsMaps())
        .thenAnswer((_) async => List.of(sampleLogs));
  });

  group('TheLoggerViewerWidget', () {
    testWidgets('shows loading indicator initially', (tester) async {
      final completer = Completer<List<Map<String, Object?>>>();
      when(() => mockLogger.getAllLogsAsMaps())
          .thenAnswer((_) => completer.future);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TheLoggerViewerWidget(
              dataSource: LogDataSource(logger: mockLogger),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Complete to avoid dangling future
      completer.complete([]);
      await tester.pumpAndSettle();
    });

    testWidgets('shows grid on wide screens (>=600dp)', (tester) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TheLoggerViewerWidget(
              dataSource: LogDataSource(logger: mockLogger),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Grid has header columns
      expect(find.text('Timestamp'), findsOneWidget);
      expect(find.text('Level'), findsOneWidget);
      expect(find.text('Logger'), findsOneWidget);
      expect(find.text('Message'), findsOneWidget);
    });

    testWidgets('shows list on narrow screens (<600dp)', (tester) async {
      tester.view.physicalSize = const Size(400, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TheLoggerViewerWidget(
              dataSource: LogDataSource(logger: mockLogger),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // List does not have grid header columns
      expect(find.text('Timestamp'), findsNothing);
      // But still shows log data
      expect(find.text('App started'), findsOneWidget);
    });

    testWidgets('shows empty state when no logs', (tester) async {
      when(() => mockLogger.getAllLogsAsMaps()).thenAnswer((_) async => []);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TheLoggerViewerWidget(
              dataSource: LogDataSource(logger: mockLogger),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('No logs available'), findsOneWidget);
    });

    testWidgets('displays color-coded rows by level', (tester) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TheLoggerViewerWidget(
              dataSource: LogDataSource(logger: mockLogger),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the INFO text inside the grid (not the filter chip)
      final infoTexts = tester.widgetList<Text>(find.text('INFO'));
      final gridInfoText = infoTexts.firstWhere(
        (t) => t.style?.color == const Color(0xFF1976D2),
      );
      expect(gridInfoText.style?.color, const Color(0xFF1976D2)); // Blue 700
    });
  });
}
