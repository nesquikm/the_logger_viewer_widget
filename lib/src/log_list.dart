import 'package:flutter/material.dart';
import 'package:the_logger_viewer_widget/src/level_colors.dart';

class LogList extends StatelessWidget {
  const LogList({
    super.key,
    required this.logs,
    this.selectedLogId,
    this.onLogTap,
    this.customColorScheme,
  });

  final List<Map<String, Object?>> logs;
  final int? selectedLogId;
  final ValueChanged<Map<String, Object?>>? onLogTap;
  final Map<String, Color>? customColorScheme;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView.builder(
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: levelColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        level,
                        style: TextStyle(
                          color: levelColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        log['logger_name'] as String? ?? '',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatTimestamp(
                          log['record_timestamp'] as String? ?? '',
                        ),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    log['message'] as String? ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatTimestamp(String timestamp) {
    if (timestamp.isEmpty) return '';
    try {
      final dt = DateTime.parse(timestamp);
      return '${dt.hour.toString().padLeft(2, '0')}:'
          '${dt.minute.toString().padLeft(2, '0')}:'
          '${dt.second.toString().padLeft(2, '0')}';
    } catch (_) {
      return timestamp;
    }
  }
}
