import 'package:flutter/material.dart';
import 'package:the_logger_viewer_widget/src/level_colors.dart';

class LogGrid extends StatelessWidget {
  const LogGrid({
    super.key,
    required this.logs,
    this.selectedLogId,
    this.onLogTap,
    this.customColorScheme,
    this.messageBuilder,
  });

  final List<Map<String, Object?>> logs;
  final int? selectedLogId;
  final ValueChanged<Map<String, Object?>>? onLogTap;
  final Map<String, Color>? customColorScheme;
  final Widget Function(String message)? messageBuilder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Header row
        Container(
          color: theme.colorScheme.surfaceContainerHighest,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: const Row(
            children: [
              SizedBox(width: 160, child: Text('Timestamp', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
              SizedBox(width: 80, child: Text('Level', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
              SizedBox(width: 120, child: Text('Logger', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
              Expanded(child: Text('Message', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            ],
          ),
        ),
        // Data rows
        Expanded(
          child: ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              final level = log['level'] as String? ?? '';
              final levelColor = LevelColors.colorForLevel(
                level,
                customScheme: customColorScheme,
              );
              final isSelected = log['id'] == selectedLogId;
              final isEven = index.isEven;

              return Material(
                color: isSelected
                    ? theme.colorScheme.primaryContainer
                    : isEven
                        ? theme.colorScheme.surfaceContainerLowest
                        : theme.colorScheme.surface,
                child: InkWell(
                  onTap: () => onLogTap?.call(log),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 160,
                          child: Text(
                            _formatTimestamp(
                              log['record_timestamp'] as String? ?? '',
                            ),
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                        SizedBox(
                          width: 80,
                          child: Text(
                            level,
                            style: TextStyle(
                              color: levelColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 120,
                          child: Text(
                            log['logger_name'] as String? ?? '',
                            style: theme.textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Expanded(
                          child: messageBuilder != null
                              ? messageBuilder!(
                                  log['message'] as String? ?? '',
                                )
                              : Text(
                                  log['message'] as String? ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall,
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _formatTimestamp(String timestamp) {
    if (timestamp.isEmpty) return '';
    try {
      final dt = DateTime.parse(timestamp);
      return '${dt.hour.toString().padLeft(2, '0')}:'
          '${dt.minute.toString().padLeft(2, '0')}:'
          '${dt.second.toString().padLeft(2, '0')}.'
          '${dt.millisecond.toString().padLeft(3, '0')}';
    } catch (_) {
      return timestamp;
    }
  }
}
