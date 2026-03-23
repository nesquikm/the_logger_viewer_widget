import 'package:flutter/material.dart';
import 'package:the_logger_viewer_widget/src/viewer_widget.dart';

/// Full-screen page wrapper for [TheLoggerViewerWidget].
///
/// Provides a [Scaffold] with an [AppBar] titled "Log Viewer" and the
/// viewer widget as the body. Use [TheLoggerViewerWidget.show] or
/// [TheLoggerViewerWidget.route] for convenient navigation.
class TheLoggerViewerPage extends StatelessWidget {
  /// Creates a full-screen log viewer page.
  const TheLoggerViewerPage({
    super.key,
    this.colorScheme,
    this.maxRecords,
    this.onExport,
    this.showExport,
  });

  /// Custom level-name-to-color mapping passed to the inner widget.
  final Map<String, Color>? colorScheme;

  /// Maximum number of records to display.
  final int? maxRecords;

  /// Optional export callback passed to the inner widget.
  final void Function(String filePath)? onExport;

  /// Whether to show the export button.
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
