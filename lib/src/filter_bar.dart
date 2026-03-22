import 'dart:async';

import 'package:flutter/material.dart';

class FilterBar extends StatefulWidget {
  const FilterBar({
    super.key,
    required this.availableLevels,
    required this.availableLoggers,
    required this.onFiltersChanged,
    this.debounceDuration = const Duration(milliseconds: 500),
  });

  final List<String> availableLevels;
  final List<String> availableLoggers;
  final void Function({
    required Set<String> levels,
    required String text,
    String? logger,
  }) onFiltersChanged;
  final Duration debounceDuration;

  @override
  State<FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<FilterBar> {
  final _textController = TextEditingController();
  Timer? _debounceTimer;
  Set<String> _selectedLevels = {};
  String? _selectedLogger;

  @override
  void dispose() {
    _textController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _emitFilters() {
    widget.onFiltersChanged(
      levels: _selectedLevels,
      text: _textController.text,
      logger: _selectedLogger,
    );
  }

  void _onTextChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(widget.debounceDuration, _emitFilters);
  }

  void _onLevelToggled(String level, bool selected) {
    setState(() {
      if (selected) {
        _selectedLevels = {..._selectedLevels, level};
      } else {
        _selectedLevels = {..._selectedLevels}..remove(level);
      }
    });
    _emitFilters();
  }

  void _onLoggerChanged(String? logger) {
    setState(() {
      _selectedLogger = logger;
    });
    _emitFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // Text search
          SizedBox(
            width: 200,
            child: TextField(
              controller: _textController,
              decoration: const InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search),
                isDense: true,
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              onChanged: _onTextChanged,
            ),
          ),
          // Level filter chips
          ...widget.availableLevels.map((level) {
            final selected = _selectedLevels.contains(level);
            return FilterChip(
              label: Text(level, style: const TextStyle(fontSize: 12)),
              selected: selected,
              onSelected: (s) => _onLevelToggled(level, s),
              visualDensity: VisualDensity.compact,
            );
          }),
          // Logger dropdown
          if (widget.availableLoggers.length > 1)
            DropdownButton<String?>(
              value: _selectedLogger,
              hint: const Text('All loggers', style: TextStyle(fontSize: 12)),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('All loggers', style: TextStyle(fontSize: 12)),
                ),
                ...widget.availableLoggers.map(
                  (logger) => DropdownMenuItem(
                    value: logger,
                    child: Text(logger, style: const TextStyle(fontSize: 12)),
                  ),
                ),
              ],
              onChanged: _onLoggerChanged,
              isDense: true,
            ),
        ],
      ),
    );
  }
}
