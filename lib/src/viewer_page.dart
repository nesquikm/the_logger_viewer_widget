import 'package:flutter/material.dart';
import 'package:the_logger_viewer_widget/src/viewer_widget.dart';

class TheLoggerViewerPage extends StatelessWidget {
  const TheLoggerViewerPage({
    super.key,
    this.colorScheme,
    this.maxRecords,
    this.onExport,
    this.showExport,
  });

  final Map<String, Color>? colorScheme;
  final int? maxRecords;
  final void Function(String filePath)? onExport;
  final bool? showExport;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Viewer'),
      ),
      body: TheLoggerViewerWidget(
        colorScheme: colorScheme,
        maxRecords: maxRecords,
        onExport: onExport,
        showExport: showExport,
      ),
    );
  }
}
