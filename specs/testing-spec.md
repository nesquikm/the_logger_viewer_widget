# Testing Specification

## 1. Test Framework
- **Runner:** flutter_test
- **Mocking:** mocktail
- **Coverage:** `fvm flutter test --coverage`

## 2. Test Structure
```
test/
├── src/
│   ├── viewer_widget_test.dart
│   ├── viewer_page_test.dart
│   ├── log_grid_test.dart
│   ├── log_list_test.dart
│   ├── log_row_test.dart
│   ├── record_details_test.dart
│   ├── filter_bar_test.dart
│   ├── session_navigator_test.dart
│   ├── export_button_test.dart
│   ├── log_data_source_test.dart
│   ├── level_colors_test.dart
│   └── extensions/
│       ├── string_extensions_test.dart
│       └── text_extensions_test.dart
└── placeholder_test.dart  (remove once real tests exist)
```

## 3. Conventions

### Naming
- Files: `*_test.dart`
- Test names: describe expected behavior (`'filters logs by level'`)

### What to Test
- LogDataSource: fetching, caching, session grouping, maxRecords capping, filtering
- Responsive layout: grid at >=600dp, list at <600dp
- Filtering: level filter, text search, logger filter, debouncing
- Search highlighting: matches highlighted in grid message column and detail view
- Session navigation: dropdown selection, prev/next/first/last buttons
- Record details: expand on tap, JSON formatting (only in detail view), copy button
- Export: async with loading indicator, onExport callback receives file path
- Edge cases: empty logs, single session, no matching filters, maxRecords boundary
- Streaming: LogDataSource receives new records via stream, onUpdate callback fires, stream subscription disposed on dispose

### Visual Widget Tests (M5)
- LogRow: correct level colors applied, alternating row backgrounds, text truncation
- LogGrid: column headers present and ordered, row color-coding visible, scrollable with many rows
- LogList: compact layout with level/logger/time header + message body, level color indicator
- FilterBar: level chips show correct colors, active filter state visually distinct, clear button visibility
- SessionNavigator: dropdown shows session list, nav buttons disabled at boundaries
- RecordDetails: all fields rendered, JSON pretty-printed with indentation, copy button present, search highlights
- ExportButton: loading indicator during export, button disabled while loading
- ViewerWidget: responsive layout at 600dp breakpoint, empty state, dark/light theme, custom colorScheme
- ViewerPage: app bar with title, back navigation, full-screen layout

### What NOT to Test
- TheLogger internals
- Flutter framework widgets (MaterialApp, Scaffold)
- Platform-specific share sheet behavior
- share_plus internals

## 4. Coverage Targets
| Layer | Target | Minimum |
|-------|--------|---------|
| LogDataSource | >=90% | 80% |
| Widgets | >=80% | 70% |
| Extensions | >=90% | 80% |
| Overall | >=80% | 70% |

## 5. Test Data

Mock `TheLogger.i()` using mocktail. Provide canned log data with correct field names from the_logger:

```dart
final sampleLogs = [
  {
    'id': 1,
    'session_id': 1,
    'record_timestamp': '2026-01-01T10:00:00.000',
    'time': '2026-01-01T10:00:00.000',
    'level': 'INFO',
    'logger_name': 'AppLogger',
    'message': 'App started',
    'error': null,
    'stack_trace': null,
  },
  {
    'id': 2,
    'session_id': 1,
    'record_timestamp': '2026-01-01T10:01:00.000',
    'time': '2026-01-01T10:01:00.000',
    'level': 'SEVERE',
    'logger_name': 'NetworkLogger',
    'message': 'Connection failed',
    'error': 'SocketException: Connection refused',
    'stack_trace': '#0 main (file:///app.dart:10)',
  },
  {
    'id': 3,
    'session_id': 2,
    'record_timestamp': '2026-01-01T11:00:00.000',
    'time': '2026-01-01T11:00:00.000',
    'level': 'WARNING',
    'logger_name': 'AppLogger',
    'message': 'Config value: {"key": "value", "nested": {"a": 1}}',
    'error': null,
    'stack_trace': null,
  },
];

// Mock stream for the_logger ^0.0.20 streaming tests
// Use a StreamController<Map<String, Object?>> to emit new log records
// Initial load: getAllLogsAsMaps() returns sampleLogs
// Then stream emits new records incrementally
```
