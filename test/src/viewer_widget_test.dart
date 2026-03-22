import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:the_logger_viewer_widget/src/log_data_source.dart';
import 'package:the_logger_viewer_widget/src/viewer_widget.dart';

import '../helpers.dart';

/// Long interval to prevent auto-refresh timer from firing during tests.
const _noAutoRefresh = Duration(hours: 1);

Widget _buildWidget(LogDataSource ds) {
  return MaterialApp(
    home: Scaffold(
      body: TheLoggerViewerWidget(
        dataSource: ds,
        refreshInterval: _noAutoRefresh,
      ),
    ),
  );
}

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
        _buildWidget(LogDataSource(logger: mockLogger)),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete([]);
      await tester.pumpAndSettle();
    });

    testWidgets('shows grid on wide screens (>=600dp)', (tester) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _buildWidget(LogDataSource(logger: mockLogger)),
      );
      await tester.pumpAndSettle();

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
        _buildWidget(LogDataSource(logger: mockLogger)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Timestamp'), findsNothing);
      expect(find.text('App started'), findsOneWidget);
    });

    testWidgets('shows empty state when no logs', (tester) async {
      when(() => mockLogger.getAllLogsAsMaps()).thenAnswer((_) async => []);

      await tester.pumpWidget(
        _buildWidget(LogDataSource(logger: mockLogger)),
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
        _buildWidget(LogDataSource(logger: mockLogger)),
      );
      await tester.pumpAndSettle();

      final infoTexts = tester.widgetList<Text>(find.text('INFO'));
      final gridInfoText = infoTexts.firstWhere(
        (t) => t.style?.color == const Color(0xFF1976D2),
      );
      expect(gridInfoText.style?.color, const Color(0xFF1976D2));
    });

    testWidgets('auto-refresh fires at configured interval', (tester) async {
      var callCount = 0;
      when(() => mockLogger.getAllLogsAsMaps()).thenAnswer((_) async {
        callCount++;
        return List.of(sampleLogs);
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TheLoggerViewerWidget(
              dataSource: LogDataSource(logger: mockLogger),
              refreshInterval: const Duration(seconds: 5),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final initialCount = callCount;

      // Advance time by 5 seconds to trigger auto-refresh
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      expect(callCount, greaterThan(initialCount));
    });

    testWidgets('manual refresh button works', (tester) async {
      tester.view.physicalSize = const Size(1200, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _buildWidget(LogDataSource(logger: mockLogger)),
      );
      await tester.pumpAndSettle();

      // Initial load called once
      verify(() => mockLogger.getAllLogsAsMaps()).called(1);

      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();

      // Refresh called again
      verify(() => mockLogger.getAllLogsAsMaps()).called(1);
    });

    testWidgets('shows export button by default', (tester) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _buildWidget(LogDataSource(logger: mockLogger)),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.file_download), findsOneWidget);
    });

    testWidgets('custom color scheme is applied', (tester) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TheLoggerViewerWidget(
              dataSource: LogDataSource(logger: mockLogger),
              refreshInterval: _noAutoRefresh,
              colorScheme: const {'INFO': Colors.purple},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final infoTexts = tester.widgetList<Text>(find.text('INFO'));
      final gridInfoText = infoTexts.firstWhere(
        (t) => t.style?.color == Colors.purple,
      );
      expect(gridInfoText.style?.color, Colors.purple);
    });
  });
}
