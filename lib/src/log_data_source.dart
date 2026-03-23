import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:the_logger/the_logger.dart';

/// Fetches, caches, and streams log data from [TheLogger].
///
/// Call [init] to perform the initial load and subscribe to real-time
/// updates via the logger's broadcast stream. Call [dispose] to cancel the
/// subscription when the data source is no longer needed.
class LogDataSource {
  /// Creates a data source that reads from [logger] (defaults to
  /// `TheLogger.i()`) and caps cached records at [maxRecords].
  LogDataSource({this.maxRecords = 5000, TheLogger? logger})
      : _logger = logger;

  /// Maximum number of records to keep in memory (most recent).
  final int maxRecords;

  final TheLogger? _logger;

  StreamSubscription<MaskedLogRecord>? _subscription;

  /// Called when new records arrive via the stream.
  VoidCallback? onUpdate;

  bool _disposed = false;

  List<Map<String, Object?>> _logs = [];
  List<int> _sessionIds = [];

  /// All cached log records, capped at [maxRecords].
  List<Map<String, Object?>> get logs => _logs;

  /// Distinct session IDs in the order they appear in [logs].
  List<int> get sessionIds => _sessionIds;

  TheLogger get _theLogger => _logger ?? TheLogger.i();

  /// Loads logs from the database and subscribes to the logger's stream
  /// for real-time updates.
  ///
  /// Each stream event triggers a full re-fetch followed by an [onUpdate]
  /// callback so the UI can rebuild.
  Future<void> init() async {
    await refresh();
    if (_disposed) return;
    _subscription = _theLogger.stream.listen((_) async {
      await refresh();
      onUpdate?.call();
    });
  }

  /// Cancels the stream subscription.
  void dispose() {
    _disposed = true;
    _subscription?.cancel();
    _subscription = null;
  }

  /// Re-fetches all logs from the database and updates the cache.
  Future<void> refresh() async {
    try {
      // ignore: invalid_use_of_visible_for_testing_member
      final allLogs = await _theLogger.getAllLogsAsMaps();

      // Convert int level values to level name strings.
      final normalized = allLogs.map((log) {
        final level = log['level'];
        if (level is int) {
          return {
            ...log,
            'level': _levelName(level),
          };
        }
        return log;
      }).toList();

      // Cap at maxRecords, keeping the most recent
      if (normalized.length > maxRecords) {
        _logs = normalized.sublist(normalized.length - maxRecords);
      } else {
        _logs = List.of(normalized);
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
    } catch (_) {
      // Silently handle errors (e.g., TheLogger not initialized)
    }
  }

  /// Returns only the logs belonging to [sessionId].
  List<Map<String, Object?>> logsForSession(int sessionId) {
    return _logs.where((log) => log['session_id'] == sessionId).toList();
  }

  /// Filters cached logs by [levels], [text] (case-insensitive substring
  /// match on message), and [logger] name.
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

  static String _levelName(int value) {
    for (final level in Level.LEVELS) {
      if (level.value == value) return level.name;
    }
    return value.toString();
  }
}
