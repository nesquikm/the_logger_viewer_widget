import 'package:flutter/material.dart';
import 'package:the_logger/the_logger.dart';

class ExportButton extends StatefulWidget {
  const ExportButton({
    super.key,
    this.onExport,
    this.logger,
  });

  final void Function(String filePath)? onExport;
  final TheLogger? logger;

  @override
  State<ExportButton> createState() => _ExportButtonState();
}

class _ExportButtonState extends State<ExportButton> {
  bool _exporting = false;

  TheLogger get _theLogger => widget.logger ?? TheLogger.i();

  Future<void> _export() async {
    setState(() => _exporting = true);

    try {
      // ignore: invalid_use_of_visible_for_testing_member
      final filePath = await _theLogger.writeAllLogsToJson();

      if (!mounted) return;

      if (widget.onExport != null) {
        widget.onExport!(filePath);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logs exported to $filePath')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _exporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _exporting
        ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : IconButton(
            icon: const Icon(Icons.file_download),
            tooltip: 'Export logs',
            onPressed: _export,
          );
  }
}
