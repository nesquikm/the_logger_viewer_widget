import 'package:the_logger/the_logger.dart';

class LogDataSource {
  LogDataSource({this.maxRecords = 5000, TheLogger? logger})
      : _logger = logger;

  final int maxRecords;
  final TheLogger? _logger;

  List<Map<String, Object?>> _logs = [];
  List<int> _sessionIds = [];

  List<Map<String, Object?>> get logs => _logs;
  List<int> get sessionIds => _sessionIds;

  TheLogger get _theLogger => _logger ?? TheLogger.i();

  Future<void> refresh() async {
    final List<Map<String, Object?>> allLogs;
    try {
      // ignore: invalid_use_of_visible_for_testing_member
      allLogs = await _theLogger.getAllLogsAsMaps();
    } catch (_) {
      return;
    }

    // Cap at maxRecords, keeping the most recent
    if (allLogs.length > maxRecords) {
      _logs = allLogs.sublist(allLogs.length - maxRecords);
    } else {
      _logs = List.of(allLogs);
    }

    // Extract distinct session IDs in order
    final seen = <int>{};
    _sessionIds = [];
    for (final log in _logs) {
      final sessionId = log['session_id'] as int;
      if (seen.add(sessionId)) {
        _sessionIds.add(sessionId);
      }
    }
  }

  List<Map<String, Object?>> logsForSession(int sessionId) {
    return _logs.where((log) => log['session_id'] == sessionId).toList();
  }

  List<Map<String, Object?>> applyFilters({
    Set<String>? levels,
    String? text,
    String? logger,
  }) {
    var filtered = _logs;

    if (levels != null && levels.isNotEmpty) {
      filtered =
          filtered.where((log) => levels.contains(log['level'])).toList();
    }

    if (text != null && text.isNotEmpty) {
      final lowerText = text.toLowerCase();
      filtered = filtered.where((log) {
        final message = (log['message'] as String?)?.toLowerCase() ?? '';
        return message.contains(lowerText);
      }).toList();
    }

    if (logger != null && logger.isNotEmpty) {
      filtered =
          filtered.where((log) => log['logger_name'] == logger).toList();
    }

    return filtered;
  }
}
