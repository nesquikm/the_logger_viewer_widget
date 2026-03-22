import 'package:flutter/material.dart';
import 'package:the_logger_viewer_widget/src/extensions/text_extensions.dart';
import 'package:the_logger_viewer_widget/src/filter_bar.dart';
import 'package:the_logger_viewer_widget/src/log_data_source.dart';
import 'package:the_logger_viewer_widget/src/log_grid.dart';
import 'package:the_logger_viewer_widget/src/log_list.dart';

class TheLoggerViewerWidget extends StatefulWidget {
  const TheLoggerViewerWidget({
    super.key,
    this.refreshInterval = const Duration(seconds: 2),
    this.colorScheme,
    this.showExport,
    this.maxRecords,
    this.onExport,
    this.dataSource,
  });

  final Duration refreshInterval;
  final Map<String, Color>? colorScheme;
  final bool? showExport;
  final int? maxRecords;
  final void Function(String filePath)? onExport;
  final LogDataSource? dataSource;

  @override
  State<TheLoggerViewerWidget> createState() => _TheLoggerViewerWidgetState();
}

class _TheLoggerViewerWidgetState extends State<TheLoggerViewerWidget> {
  late LogDataSource _dataSource;
  List<Map<String, Object?>> _displayedLogs = [];
  int? _selectedLogId;
  bool _loading = true;
  String _searchText = '';

  // Filter state
  Set<String> _filterLevels = {};
  String? _filterLogger;

  @override
  void initState() {
    super.initState();
    _dataSource = widget.dataSource ??
        LogDataSource(maxRecords: widget.maxRecords ?? 5000);
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    await _dataSource.refresh();
    if (mounted) {
      setState(() {
        _applyFilters();
        _loading = false;
      });
    }
  }

  void _applyFilters() {
    _displayedLogs = _dataSource.applyFilters(
      levels: _filterLevels.isEmpty ? null : _filterLevels,
      text: _searchText.isEmpty ? null : _searchText,
      logger: _filterLogger,
    );
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

  void _onLogTap(Map<String, Object?> log) {
    setState(() {
      final id = log['id'] as int?;
      _selectedLogId = _selectedLogId == id ? null : id;
    });
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

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        if (_dataSource.logs.isNotEmpty)
          FilterBar(
            availableLevels: _availableLevels,
            availableLoggers: _availableLoggers,
            onFiltersChanged: _onFiltersChanged,
          ),
        Expanded(
          child: _displayedLogs.isEmpty
              ? const Center(child: Text('No logs available'))
              : LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth >= 600) {
                      return LogGrid(
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
                      );
                    } else {
                      return LogList(
                        logs: _displayedLogs,
                        selectedLogId: _selectedLogId,
                        onLogTap: _onLogTap,
                        customColorScheme: widget.colorScheme,
                      );
                    }
                  },
                ),
        ),
      ],
    );
  }
}
