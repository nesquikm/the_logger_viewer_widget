import 'package:flutter/material.dart';
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
        _displayedLogs = _dataSource.logs;
        _loading = false;
      });
    }
  }

  void _onLogTap(Map<String, Object?> log) {
    setState(() {
      final id = log['id'] as int?;
      _selectedLogId = _selectedLogId == id ? null : id;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_displayedLogs.isEmpty) {
      return const Center(child: Text('No logs available'));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 600) {
          return LogGrid(
            logs: _displayedLogs,
            selectedLogId: _selectedLogId,
            onLogTap: _onLogTap,
            customColorScheme: widget.colorScheme,
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
    );
  }
}
