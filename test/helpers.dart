import 'package:mocktail/mocktail.dart';
import 'package:the_logger/the_logger.dart';

class MockTheLogger extends Mock implements TheLogger {}

final sampleLogs = <Map<String, Object?>>[
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
    'message': 'Config value: {"key": "value", "nested": {"a": 1}}',
    'error': null,
    'stack_trace': null,
  },
];
