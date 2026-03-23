import 'package:flutter/material.dart';
import 'package:the_logger_viewer_widget/src/export_button.dart';
import 'package:the_logger_viewer_widget/src/extensions/text_extensions.dart';
import 'package:the_logger_viewer_widget/src/filter_bar.dart';
import 'package:the_logger_viewer_widget/src/log_data_source.dart';
import 'package:the_logger_viewer_widget/src/log_grid.dart';
import 'package:the_logger_viewer_widget/src/log_list.dart';
import 'package:the_logger_viewer_widget/src/record_details.dart';
import 'package:the_logger_viewer_widget/src/session_navigator.dart';
import 'package:the_logger_viewer_widget/src/viewer_page.dart';

class TheLoggerViewerWidget extends StatefulWidget {
  const TheLoggerViewerWidget({
    super.key,
    this.colorScheme,
    this.showExport,
    this.maxRecords,
    this.onExport,
    this.dataSource,
  });

  final Map<String, Color>? colorScheme;
  final bool? showExport;
  final int? maxRecords;
  final void Function(String filePath)? onExport;
  final LogDataSource? dataSource;

  /// Push a full-screen log viewer page.
  static void show(BuildContext context) {
    Navigator.of(context).push(route());
  }

  /// Use as a route in GoRouter / Navigator.
  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (_) => const TheLoggerViewerPage(),
    );
  }

  @override
  State<TheLoggerViewerWidget> createState() => _TheLoggerViewerWidgetState();
}

class _TheLoggerViewerWidgetState extends State<TheLoggerViewerWidget> {
  late LogDataSource _dataSource;
  List<Map<String, Object?>> _displayedLogs = [];
  int? _selectedLogId;
  bool _loading = true;
  String _searchText = '';
  int? _selectedSessionId;
  DateTime? _lastRefresh;

  // Filter state
  Set<String> _filterLevels = {};
  String? _filterLogger;

  @override
  void initState() {
    super.initState();
    _dataSource = widget.dataSource ??
        LogDataSource(maxRecords: widget.maxRecords ?? 5000);
    _initDataSource();
  }

  @override
  void dispose() {
    _dataSource.onUpdate = null;
    _dataSource.dispose();
    super.dispose();
  }

  Future<void> _initDataSource() async {
    await _dataSource.init();
    if (mounted) {
      _dataSource.onUpdate = _onStreamUpdate;
      setState(() {
        _applyFilters();
        _loading = false;
        _lastRefresh = DateTime.now();
      });
    }
  }

  void _onStreamUpdate() {
    if (mounted) {
      setState(() {
        _applyFilters();
        _lastRefresh = DateTime.now();
      });
    }
  }

  Future<void> _manualRefresh() async {
    await _dataSource.refresh();
    if (mounted) {
      setState(() {
        _applyFilters();
        _lastRefresh = DateTime.now();
      });
    }
  }

  void _applyFilters() {
    var logs = _selectedSessionId != null
        ? _dataSource.logsForSession(_selectedSessionId!)
        : _dataSource.logs;

    if (_filterLevels.isNotEmpty || _searchText.isNotEmpty || _filterLogger != null) {
      if (_filterLevels.isNotEmpty) {
        logs = logs.where((log) => _filterLevels.contains(log['level'])).toList();
      }
      if (_searchText.isNotEmpty) {
        final lowerText = _searchText.toLowerCase();
        logs = logs.where((log) {
          final message = (log['message'] as String?)?.toLowerCase() ?? '';
          return message.contains(lowerText);
        }).toList();
      }
      if (_filterLogger != null && _filterLogger!.isNotEmpty) {
        logs = logs.where((log) => log['logger_name'] == _filterLogger).toList();
      }
    }

    _displayedLogs = logs;
  }

  void _onFiltersChanged({
    required Set<String> levels,
    required String text,
    String? logger,
  }) {
    setState(() {
      _filterLevels = levels;
      _searchText = text;
      _filterLogger = logger;
      _applyFilters();
    });
  }

  void _onSessionChanged(int? sessionId) {
    setState(() {
      _selectedSessionId = sessionId;
      _selectedLogId = null;
      _applyFilters();
    });
  }

  void _onLogTap(Map<String, Object?> log) {
    setState(() {
      final id = log['id'] as int?;
      _selectedLogId = _selectedLogId == id ? null : id;
    });
  }

  Map<String, Object?>? get _selectedLog {
    if (_selectedLogId == null) return null;
    try {
      return _displayedLogs.firstWhere((log) => log['id'] == _selectedLogId);
    } catch (_) {
      return null;
    }
  }

  List<String> get _availableLevels {
    final levels = <String>{};
    for (final log in _dataSource.logs) {
      final level = log['level'] as String?;
      if (level != null) levels.add(level);
    }
    return levels.toList()..sort();
  }

  List<String> get _availableLoggers {
    final loggers = <String>{};
    for (final log in _dataSource.logs) {
      final logger = log['logger_name'] as String?;
      if (logger != null) loggers.add(logger);
    }
    return loggers.toList()..sort();
  }

  String _formatLastRefresh() {
    if (_lastRefresh == null) return '';
    final h = _lastRefresh!.hour.toString().padLeft(2, '0');
    final m = _lastRefresh!.minute.toString().padLeft(2, '0');
    final s = _lastRefresh!.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final showExportButton = widget.showExport ?? true;

    return Column(
      children: [
        if (_dataSource.logs.isNotEmpty) ...[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterBar(
                  availableLevels: _availableLevels,
                  availableLoggers: _availableLoggers,
                  onFiltersChanged: _onFiltersChanged,
                ),
                SessionNavigator(
                  sessionIds: _dataSource.sessionIds,
                  selectedSessionId: _selectedSessionId,
                  onSessionChanged: _onSessionChanged,
                ),
                // Manual refresh
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  tooltip: 'Refresh',
                  onPressed: _manualRefresh,
                  visualDensity: VisualDensity.compact,
                ),
                if (_lastRefresh != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      _formatLastRefresh(),
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ),
                // Export button
                if (showExportButton)
                  ExportButton(onExport: widget.onExport),
              ],
            ),
          ),
        ],
        Expanded(
          child: _displayedLogs.isEmpty
              ? const Center(child: Text('No logs available'))
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final logView = constraints.maxWidth >= 600
                        ? LogGrid(
                            logs: _displayedLogs,
                            selectedLogId: _selectedLogId,
                            onLogTap: _onLogTap,
                            customColorScheme: widget.colorScheme,
                            messageBuilder: _searchText.isNotEmpty
                                ? (message) => HighlightedText(
                                      text: message,
                                      highlight: _searchText,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    )
                                : null,
                          )
                        : LogList(
                            logs: _displayedLogs,
                            selectedLogId: _selectedLogId,
                            onLogTap: _onLogTap,
                            customColorScheme: widget.colorScheme,
                          );

                    if (_selectedLog != null) {
                      return Column(
                        children: [
                          Expanded(child: logView),
                          RecordDetails(
                            log: _selectedLog!,
                            searchText: _searchText,
                            customColorScheme: widget.colorScheme,
                          ),
                        ],
                      );
                    }

                    return logView;
                  },
                ),
        ),
      ],
    );
  }
}
