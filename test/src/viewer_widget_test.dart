import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';
import 'package:mocktail/mocktail.dart';
import 'package:the_logger/the_logger.dart';
import 'package:the_logger_viewer_widget/src/log_data_source.dart';
import 'package:the_logger_viewer_widget/src/log_grid.dart';
import 'package:the_logger_viewer_widget/src/log_list.dart';
import 'package:the_logger_viewer_widget/src/viewer_widget.dart';

import '../helpers.dart';

Widget _buildWidget(LogDataSource ds, {ThemeData? theme}) {
  return MaterialApp(
    theme: theme,
    home: Scaffold(
      body: TheLoggerViewerWidget(
        dataSource: ds,
      ),
    ),
  );
}

Widget _buildWidgetWithOptions(
  LogDataSource ds, {
  ThemeData? theme,
  Map<String, Color>? colorScheme,
  bool? showExport,
}) {
  return MaterialApp(
    theme: theme,
    home: Scaffold(
      body: TheLoggerViewerWidget(
        dataSource: ds,
        colorScheme: colorScheme,
        showExport: showExport,
      ),
    ),
  );
}

void main() {
  late MockTheLogger mockLogger;
  late StreamController<MaskedLogRecord> streamController;

  setUp(() {
    mockLogger = MockTheLogger();
    streamController = StreamController<MaskedLogRecord>.broadcast();
    when(() => mockLogger.getAllLogsAsMaps())
        .thenAnswer((_) async => List.of(sampleLogs));
    when(() => mockLogger.stream).thenAnswer((_) => streamController.stream);
  });

  tearDown(() {
    streamController.close();
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

    testWidgets('new records appear via stream without polling',
        (tester) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _buildWidget(LogDataSource(logger: mockLogger)),
      );
      await tester.pumpAndSettle();

      expect(find.text('App started'), findsOneWidget);

      // Simulate new log arriving via stream
      final updatedLogs = List.of(sampleLogs)
        ..add({
          'id': 4,
          'session_id': 2,
          'record_timestamp': '2026-01-01T12:00:00.000',
          'time': '2026-01-01T12:00:00.000',
          'level': 'INFO',
          'logger_name': 'AppLogger',
          'message': 'New stream log',
          'error': null,
          'stack_trace': null,
        });
      when(() => mockLogger.getAllLogsAsMaps())
          .thenAnswer((_) async => updatedLogs);

      streamController.add(MaskedLogRecord(
        Level.INFO,
        'New stream log',
        'AppLogger',
        null,
        null,
        null,
        null,
        maskedMessage: 'New stream log',
        maskedError: null,
        maskedStackTrace: null,
      ));
      await tester.pumpAndSettle();

      expect(find.text('New stream log'), findsOneWidget);
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

  group('TheLoggerViewerWidget visual', () {
    testWidgets('responsive: shows LogGrid at exactly 600dp wide',
        (tester) async {
      tester.view.physicalSize = const Size(600, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _buildWidget(LogDataSource(logger: mockLogger)),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LogGrid), findsOneWidget);
      expect(find.byType(LogList), findsNothing);
    });

    testWidgets('responsive: shows LogList at 599dp wide', (tester) async {
      tester.view.physicalSize = const Size(599, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _buildWidget(LogDataSource(logger: mockLogger)),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LogList), findsOneWidget);
      expect(find.byType(LogGrid), findsNothing);
    });

    testWidgets('empty state displays "No logs available" message',
        (tester) async {
      when(() => mockLogger.getAllLogsAsMaps()).thenAnswer((_) async => []);

      await tester.pumpWidget(
        _buildWidget(LogDataSource(logger: mockLogger)),
      );
      await tester.pumpAndSettle();

      expect(find.text('No logs available'), findsOneWidget);
      // Should be centered
      expect(find.byType(Center), findsWidgets);
    });

    testWidgets('dark theme renders correctly', (tester) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _buildWidget(
          LogDataSource(logger: mockLogger),
          theme: ThemeData.dark(useMaterial3: true),
        ),
      );
      await tester.pumpAndSettle();

      // Grid is visible with log data
      expect(find.byType(LogGrid), findsOneWidget);
      expect(find.text('App started'), findsOneWidget);

      // Verify dark theme is applied by checking the theme brightness
      final context = tester.element(find.byType(TheLoggerViewerWidget));
      final theme = Theme.of(context);
      expect(theme.brightness, Brightness.dark);
    });

    testWidgets('light theme renders correctly', (tester) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _buildWidget(
          LogDataSource(logger: mockLogger),
          theme: ThemeData.light(useMaterial3: true),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LogGrid), findsOneWidget);
      expect(find.text('App started'), findsOneWidget);

      final context = tester.element(find.byType(TheLoggerViewerWidget));
      final theme = Theme.of(context);
      expect(theme.brightness, Brightness.light);
    });

    testWidgets('custom colorScheme overrides are applied to grid rows',
        (tester) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _buildWidgetWithOptions(
          LogDataSource(logger: mockLogger),
          colorScheme: const {
            'INFO': Colors.teal,
            'SEVERE': Colors.pink,
          },
        ),
      );
      await tester.pumpAndSettle();

      // INFO should use teal
      final infoTexts = tester.widgetList<Text>(find.text('INFO'));
      final infoText = infoTexts.firstWhere(
        (t) => t.style?.color == Colors.teal,
      );
      expect(infoText.style?.color, Colors.teal);

      // SEVERE should use pink
      final severeTexts = tester.widgetList<Text>(find.text('SEVERE'));
      final severeText = severeTexts.firstWhere(
        (t) => t.style?.color == Colors.pink,
      );
      expect(severeText.style?.color, Colors.pink);
    });

    testWidgets('no-matching-filters state shows empty message',
        (tester) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _buildWidget(LogDataSource(logger: mockLogger)),
      );
      await tester.pumpAndSettle();

      // Filter by a level that matches no logs: toggle FINE filter chip
      // The available levels are extracted from data: INFO, SEVERE, WARNING
      // Select INFO to filter, then type text that doesn't match any INFO log
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'zzzznonexistent');
      await tester.pump(const Duration(milliseconds: 600)); // debounce

      expect(find.text('No logs available'), findsOneWidget);
    });

    testWidgets('search text highlights matching terms in grid rows',
        (tester) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _buildWidget(LogDataSource(logger: mockLogger)),
      );
      await tester.pumpAndSettle();

      // Enter search text that matches a log message
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'started');
      await tester.pump(const Duration(milliseconds: 600)); // debounce

      // HighlightedText renders as RichText with highlighted spans
      final richTexts = tester.widgetList<RichText>(
        find.descendant(
          of: find.byType(LogGrid),
          matching: find.byType(RichText),
        ),
      );

      final hasHighlight = richTexts.any((rt) {
        final span = rt.text;
        if (span is TextSpan) {
          return span.children?.any((child) {
                if (child is TextSpan) {
                  return child.style?.backgroundColor != null;
                }
                return false;
              }) ??
              false;
        }
        return false;
      });
      expect(hasHighlight, isTrue);
    });

    testWidgets('showExport false hides export button', (tester) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _buildWidgetWithOptions(
          LogDataSource(logger: mockLogger),
          showExport: false,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.file_download), findsNothing);
    });
  });
}
