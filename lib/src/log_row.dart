import 'package:flutter/material.dart';
import 'package:the_logger_viewer_widget/src/level_colors.dart';

class LogRow extends StatelessWidget {
  const LogRow({
    super.key,
    required this.log,
    this.isSelected = false,
    this.onTap,
    this.customColorScheme,
    this.isEvenRow = false,
  });

  final Map<String, Object?> log;
  final bool isSelected;
  final VoidCallback? onTap;
  final Map<String, Color>? customColorScheme;
  final bool isEvenRow;

  @override
  Widget build(BuildContext context) {
    final level = log['level'] as String? ?? '';
    final levelColor = LevelColors.colorForLevel(
      level,
      customScheme: customColorScheme,
    );
    final theme = Theme.of(context);

    return Material(
      color: isSelected
          ? theme.colorScheme.primaryContainer
          : isEvenRow
              ? theme.colorScheme.surfaceContainerLowest
              : theme.colorScheme.surface,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: levelColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 64,
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
              Expanded(
                child: Text(
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
  }
}
