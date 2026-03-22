import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:the_logger_viewer_widget/src/extensions/string_extensions.dart';
import 'package:the_logger_viewer_widget/src/extensions/text_extensions.dart';
import 'package:the_logger_viewer_widget/src/level_colors.dart';

class RecordDetails extends StatelessWidget {
  const RecordDetails({
    super.key,
    required this.log,
    this.searchText,
    this.customColorScheme,
  });

  final Map<String, Object?> log;
  final String? searchText;
  final Map<String, Color>? customColorScheme;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final level = log['level'] as String? ?? '';
    final levelColor = LevelColors.colorForLevel(
      level,
      customScheme: customColorScheme,
    );
    final message = log['message'] as String? ?? '';
    final formattedMessage = message.containsJson
        ? message.prettyPrintJson()
        : message;
    final error = log['error'] as String?;
    final stackTrace = log['stack_trace'] as String?;

    return Container(
      color: theme.colorScheme.surfaceContainerLow,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with level and copy button
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: levelColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  level,
                  style: TextStyle(
                    color: levelColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                log['logger_name'] as String? ?? '',
                style: theme.textTheme.bodySmall,
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.copy, size: 18),
                tooltip: 'Copy to clipboard',
                onPressed: () => _copyToClipboard(context),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Timestamp
          _DetailField(
            label: 'Timestamp',
            value: log['record_timestamp'] as String? ?? '',
          ),

          // Session
          _DetailField(
            label: 'Session',
            value: '${log['session_id'] ?? ''}',
          ),

          const SizedBox(height: 8),

          // Message (with JSON formatting and search highlighting)
          Text('Message', style: theme.textTheme.labelSmall),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(4),
            ),
            child: searchText != null && searchText!.isNotEmpty
                ? HighlightedText(
                    text: formattedMessage,
                    highlight: searchText!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
                  )
                : Text(
                    formattedMessage,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
          ),

          // Error
          if (error != null && error.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Error', style: theme.textTheme.labelSmall),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                error,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
            ),
          ],

          // Stack trace
          if (stackTrace != null && stackTrace.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Stack Trace', style: theme.textTheme.labelSmall),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                stackTrace,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context) {
    final buffer = StringBuffer();
    buffer.writeln('Level: ${log['level']}');
    buffer.writeln('Logger: ${log['logger_name']}');
    buffer.writeln('Timestamp: ${log['record_timestamp']}');
    buffer.writeln('Session: ${log['session_id']}');
    buffer.writeln('Message: ${log['message']}');
    if (log['error'] != null) buffer.writeln('Error: ${log['error']}');
    if (log['stack_trace'] != null) {
      buffer.writeln('Stack Trace: ${log['stack_trace']}');
    }

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 1),
      ),
    );
  }
}

class _DetailField extends StatelessWidget {
  const _DetailField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: theme.textTheme.labelSmall,
            ),
          ),
          Expanded(
            child: Text(value, style: theme.textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}
