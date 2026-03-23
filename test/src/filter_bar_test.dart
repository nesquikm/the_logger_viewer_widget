import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_logger_viewer_widget/src/filter_bar.dart';

void main() {
  group('FilterBar', () {
    testWidgets('renders search field and level chips', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilterBar(
              availableLevels: const ['INFO', 'SEVERE'],
              availableLoggers: const ['AppLogger'],
              onFiltersChanged: ({
                required Set<String> levels,
                required String text,
                String? logger,
              }) {},
            ),
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('INFO'), findsOneWidget);
      expect(find.text('SEVERE'), findsOneWidget);
    });

    testWidgets('emits filter changes when level chip toggled',
        (tester) async {
      Set<String>? emittedLevels;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilterBar(
              availableLevels: const ['INFO', 'SEVERE'],
              availableLoggers: const ['AppLogger'],
              onFiltersChanged: ({
                required Set<String> levels,
                required String text,
                String? logger,
              }) {
                emittedLevels = levels;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('INFO'));
      await tester.pump();

      expect(emittedLevels, contains('INFO'));
    });

    testWidgets('debounces text search', (tester) async {
      var callCount = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilterBar(
              availableLevels: const ['INFO'],
              availableLoggers: const ['AppLogger'],
              debounceDuration: const Duration(milliseconds: 500),
              onFiltersChanged: ({
                required Set<String> levels,
                required String text,
                String? logger,
              }) {
                callCount++;
              },
            ),
          ),
        ),
      );

      // Type rapidly — should not call immediately
      await tester.enterText(find.byType(TextField), 'h');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.enterText(find.byType(TextField), 'he');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.enterText(find.byType(TextField), 'hel');
      await tester.pump(const Duration(milliseconds: 100));

      expect(callCount, 0);

      // Wait for debounce to fire
      await tester.pump(const Duration(milliseconds: 500));
      expect(callCount, 1);
    });

    testWidgets('shows logger dropdown when multiple loggers available',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilterBar(
              availableLevels: const ['INFO'],
              availableLoggers: const ['AppLogger', 'NetworkLogger'],
              onFiltersChanged: ({
                required Set<String> levels,
                required String text,
                String? logger,
              }) {},
            ),
          ),
        ),
      );

      expect(find.byType(DropdownButton<String?>), findsOneWidget);
    });

    testWidgets('emits logger filter when logger selected', (tester) async {
      String? emittedLogger;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilterBar(
              availableLevels: const ['INFO'],
              availableLoggers: const ['AppLogger', 'NetworkLogger'],
              onFiltersChanged: ({
                required Set<String> levels,
                required String text,
                String? logger,
              }) {
                emittedLogger = logger;
              },
            ),
          ),
        ),
      );

      // Open dropdown
      await tester.tap(find.byType(DropdownButton<String?>));
      await tester.pumpAndSettle();

      // Select NetworkLogger
      await tester.tap(find.text('NetworkLogger').last);
      await tester.pumpAndSettle();

      expect(emittedLogger, 'NetworkLogger');
    });
  });

  group('FilterBar visual', () {
    testWidgets('level chips render as FilterChip widgets', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilterBar(
              availableLevels: const ['INFO', 'SEVERE', 'WARNING'],
              availableLoggers: const ['AppLogger'],
              onFiltersChanged: ({
                required Set<String> levels,
                required String text,
                String? logger,
              }) {},
            ),
          ),
        ),
      );

      expect(find.byType(FilterChip), findsNWidgets(3));
      expect(find.text('INFO'), findsOneWidget);
      expect(find.text('SEVERE'), findsOneWidget);
      expect(find.text('WARNING'), findsOneWidget);
    });

    testWidgets('active filter chip is visually distinct (selected state)',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilterBar(
              availableLevels: const ['INFO', 'SEVERE'],
              availableLoggers: const ['AppLogger'],
              onFiltersChanged: ({
                required Set<String> levels,
                required String text,
                String? logger,
              }) {},
            ),
          ),
        ),
      );

      // Initially no chips are selected
      final infoChipBefore = tester.widget<FilterChip>(
        find.widgetWithText(FilterChip, 'INFO'),
      );
      expect(infoChipBefore.selected, isFalse);

      // Tap to select INFO
      await tester.tap(find.text('INFO'));
      await tester.pump();

      // Now the INFO chip should be selected
      final infoChipAfter = tester.widget<FilterChip>(
        find.widgetWithText(FilterChip, 'INFO'),
      );
      expect(infoChipAfter.selected, isTrue);

      // SEVERE should remain unselected
      final severeChip = tester.widget<FilterChip>(
        find.widgetWithText(FilterChip, 'SEVERE'),
      );
      expect(severeChip.selected, isFalse);
    });

    testWidgets('search field shows search icon and hint', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilterBar(
              availableLevels: const ['INFO'],
              availableLoggers: const ['AppLogger'],
              onFiltersChanged: ({
                required Set<String> levels,
                required String text,
                String? logger,
              }) {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.text('Search...'), findsOneWidget);
    });

    testWidgets('hides logger dropdown with single logger', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilterBar(
              availableLevels: const ['INFO'],
              availableLoggers: const ['AppLogger'],
              onFiltersChanged: ({
                required Set<String> levels,
                required String text,
                String? logger,
              }) {},
            ),
          ),
        ),
      );

      expect(find.byType(DropdownButton<String?>), findsNothing);
    });
  });
}
