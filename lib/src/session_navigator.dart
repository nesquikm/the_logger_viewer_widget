import 'package:flutter/material.dart';

class SessionNavigator extends StatelessWidget {
  const SessionNavigator({
    super.key,
    required this.sessionIds,
    required this.selectedSessionId,
    required this.onSessionChanged,
  });

  final List<int> sessionIds;
  final int? selectedSessionId;
  final ValueChanged<int?> onSessionChanged;

  @override
  Widget build(BuildContext context) {
    if (sessionIds.isEmpty) return const SizedBox.shrink();

    final currentIndex = selectedSessionId != null
        ? sessionIds.indexOf(selectedSessionId!)
        : -1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // First
          IconButton(
            icon: const Icon(Icons.first_page, size: 20),
            tooltip: 'First session',
            onPressed: currentIndex > 0
                ? () => onSessionChanged(sessionIds.first)
                : null,
            visualDensity: VisualDensity.compact,
          ),
          // Previous
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 20),
            tooltip: 'Previous session',
            onPressed: currentIndex > 0
                ? () => onSessionChanged(sessionIds[currentIndex - 1])
                : null,
            visualDensity: VisualDensity.compact,
          ),
          // Session dropdown
          DropdownButton<int?>(
            value: selectedSessionId,
            hint: const Text('All sessions', style: TextStyle(fontSize: 12)),
            items: [
              const DropdownMenuItem<int?>(
                value: null,
                child: Text('All sessions', style: TextStyle(fontSize: 12)),
              ),
              ...sessionIds.map(
                (id) => DropdownMenuItem(
                  value: id,
                  child: Text('Session $id', style: const TextStyle(fontSize: 12)),
                ),
              ),
            ],
            onChanged: onSessionChanged,
            isDense: true,
          ),
          // Next
          IconButton(
            icon: const Icon(Icons.chevron_right, size: 20),
            tooltip: 'Next session',
            onPressed: currentIndex >= 0 && currentIndex < sessionIds.length - 1
                ? () => onSessionChanged(sessionIds[currentIndex + 1])
                : null,
            visualDensity: VisualDensity.compact,
          ),
          // Last
          IconButton(
            icon: const Icon(Icons.last_page, size: 20),
            tooltip: 'Last session',
            onPressed: currentIndex >= 0 && currentIndex < sessionIds.length - 1
                ? () => onSessionChanged(sessionIds.last)
                : null,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
