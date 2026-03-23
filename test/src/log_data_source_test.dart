import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';
import 'package:mocktail/mocktail.dart';
import 'package:the_logger/the_logger.dart';
import 'package:the_logger_viewer_widget/src/log_data_source.dart';

class MockTheLogger extends Mock implements TheLogger {}

void main() {
  late MockTheLogger mockLogger;
  late StreamController<MaskedLogRecord> streamController;

  final sampleLogs = [
    {
      'id': 1,
      'session_id': 1,
      'record_timestamp': '2026-01-01T10:00:00.000',
      'time': '2026-01-01T10:00:00.000',
      'level': 'INFO',
      'logger_name': 'AppLogger',
      'message': 'App started',
      'error': null,
      'stack_trace': null,
    },
    {
      'id': 2,
      'session_id': 1,
      'record_timestamp': '2026-01-01T10:01:00.000',
      'time': '2026-01-01T10:01:00.000',
      'level': 'SEVERE',
      'logger_name': 'NetworkLogger',
      'message': 'Connection failed',
      'error': 'SocketException: Connection refused',
      'stack_trace': '#0 main (file:///app.dart:10)',
    },
    {
      'id': 3,
      'session_id': 2,
      'record_timestamp': '2026-01-01T11:00:00.000',
      'time': '2026-01-01T11:00:00.000',
      'level': 'WARNING',
      'logger_name': 'AppLogger',
      'message': 'Config value: {"key": "value"}',
      'error': null,
      'stack_trace': null,
    },
  ];

  MaskedLogRecord makeRecord(String message) {
    return MaskedLogRecord(
      Level.INFO,
      message,
      'TestLogger',
      null,
      null,
      null,
      null,
      maskedMessage: message,
      maskedError: null,
      maskedStackTrace: null,
    );
  }

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

  group('LogDataSource', () {
    test('fetches and caches logs from TheLogger', () async {
      final ds = LogDataSource(logger: mockLogger);
      await ds.refresh();

      expect(ds.logs, hasLength(3));
      expect(ds.logs.first['message'], 'App started');
      verify(() => mockLogger.getAllLogsAsMaps()).called(1);
    });

    test('caps at maxRecords keeping most recent', () async {
      final ds = LogDataSource(maxRecords: 2, logger: mockLogger);
      await ds.refresh();

      expect(ds.logs, hasLength(2));
      // Should keep the last 2 records (ids 2 and 3)
      expect(ds.logs.first['id'], 2);
      expect(ds.logs.last['id'], 3);
    });

    test('extracts distinct session IDs in order', () async {
      final ds = LogDataSource(logger: mockLogger);
      await ds.refresh();

      expect(ds.sessionIds, [1, 2]);
    });

    test('logsForSession returns only matching session', () async {
      final ds = LogDataSource(logger: mockLogger);
      await ds.refresh();

      final session1 = ds.logsForSession(1);
      expect(session1, hasLength(2));
      expect(session1.every((l) => l['session_id'] == 1), isTrue);

      final session2 = ds.logsForSession(2);
      expect(session2, hasLength(1));
      expect(session2.first['id'], 3);
    });

    test('applyFilters filters by level', () async {
      final ds = LogDataSource(logger: mockLogger);
      await ds.refresh();

      final result = ds.applyFilters(levels: {'INFO'});
      expect(result, hasLength(1));
      expect(result.first['level'], 'INFO');
    });

    test('applyFilters filters by text case-insensitively', () async {
      final ds = LogDataSource(logger: mockLogger);
      await ds.refresh();

      final result = ds.applyFilters(text: 'connection');
      expect(result, hasLength(1));
      expect(result.first['message'], 'Connection failed');
    });

    test('applyFilters filters by logger name', () async {
      final ds = LogDataSource(logger: mockLogger);
      await ds.refresh();

      final result = ds.applyFilters(logger: 'NetworkLogger');
      expect(result, hasLength(1));
      expect(result.first['logger_name'], 'NetworkLogger');
    });

    test('applyFilters combines multiple filters', () async {
      final ds = LogDataSource(logger: mockLogger);
      await ds.refresh();

      final result = ds.applyFilters(
        levels: {'INFO', 'WARNING'},
        logger: 'AppLogger',
      );
      expect(result, hasLength(2));
    });

    test('handles empty logs', () async {
      when(() => mockLogger.getAllLogsAsMaps()).thenAnswer((_) async => []);
      final ds = LogDataSource(logger: mockLogger);
      await ds.refresh();

      expect(ds.logs, isEmpty);
      expect(ds.sessionIds, isEmpty);
    });
  });

  group('LogDataSource stream', () {
    test('init subscribes to stream and loads initial data', () async {
      final ds = LogDataSource(logger: mockLogger);
      await ds.init();

      expect(ds.logs, hasLength(3));
      verify(() => mockLogger.getAllLogsAsMaps()).called(1);

      ds.dispose();
    });

    test('stream event triggers re-fetch and onUpdate callback', () async {
      var updateCount = 0;
      final ds = LogDataSource(logger: mockLogger);
      ds.onUpdate = () => updateCount++;
      await ds.init();

      // Reset to verify re-fetch
      reset(mockLogger);
      when(() => mockLogger.getAllLogsAsMaps())
          .thenAnswer((_) async => List.of(sampleLogs));
      when(() => mockLogger.stream).thenAnswer((_) => streamController.stream);

      // Emit a stream event
      streamController.add(makeRecord('new log'));
      await Future<void>.delayed(Duration.zero);

      verify(() => mockLogger.getAllLogsAsMaps()).called(1);
      expect(updateCount, 1);

      ds.dispose();
    });

    test('dispose cancels stream subscription', () async {
      final ds = LogDataSource(logger: mockLogger);
      await ds.init();

      ds.dispose();

      // Emit after dispose — should not trigger re-fetch
      reset(mockLogger);
      when(() => mockLogger.getAllLogsAsMaps())
          .thenAnswer((_) async => List.of(sampleLogs));
      when(() => mockLogger.stream).thenAnswer((_) => streamController.stream);

      streamController.add(makeRecord('after dispose'));
      await Future<void>.delayed(Duration.zero);

      verifyNever(() => mockLogger.getAllLogsAsMaps());
    });

    test('stream respects maxRecords cap', () async {
      final manyLogs = List.generate(
        10,
        (i) => <String, Object?>{
          'id': i,
          'session_id': 1,
          'record_timestamp': '2026-01-01T10:00:00.000',
          'level': 'INFO',
          'logger_name': 'AppLogger',
          'message': 'Log $i',
        },
      );
      when(() => mockLogger.getAllLogsAsMaps())
          .thenAnswer((_) async => manyLogs);

      final ds = LogDataSource(maxRecords: 5, logger: mockLogger);
      await ds.init();

      expect(ds.logs, hasLength(5));
      expect(ds.logs.first['id'], 5);

      ds.dispose();
    });
  });
}
