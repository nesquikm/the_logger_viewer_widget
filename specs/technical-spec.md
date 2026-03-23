# Technical Specification

## 1. Architecture

### System Overview

`the_logger_viewer_widget` is a Flutter package that provides an embeddable widget for viewing logs from `the_logger`. It reads log data directly via `TheLogger.i().getAllLogsAsMaps()` — no file export step required.

`the_logger` ^0.0.20 provides a broadcast stream API (`TheLogger.i().stream`) for real-time log updates.

### Directory Structure
```
lib/
├── the_logger_viewer_widget.dart     # Package export barrel
└── src/
    ├── viewer_widget.dart            # Main TheLoggerViewerWidget (StatefulWidget)
    ├── viewer_page.dart              # Full-screen page wrapper + show()/route()
    ├── log_grid.dart                 # Wide-screen scrollable table (>=600dp)
    ├── log_list.dart                 # Narrow-screen list layout (<600dp)
    ├── log_row.dart                  # Individual row widget (color-coded)
    ├── record_details.dart           # Expanded detail view
    ├── filter_bar.dart               # Level + text + logger filters
    ├── session_navigator.dart        # Session dropdown + jump controls
    ├── export_button.dart            # Export via writeAllLogsToJson()
    ├── log_data_source.dart          # Fetches, caches, groups by session, caps records
    ├── level_colors.dart             # Log level → Color mapping
    └── extensions/
        ├── string_extensions.dart    # JSON pretty-printing
        └── text_extensions.dart      # Search highlighting
```

### Key Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| No pluto_grid | Custom ListView/DataTable | Keep dependency footprint minimal for an embeddable widget |
| No freezed/codegen | Plain Dart classes | Avoid build_runner requirement for consumers |
| Direct TheLogger dependency | `getAllLogsAsMaps()` | No file export step, live data, simpler UX |
| StatefulWidget (not BLoC) | Internal state only | No state management dependency on consumers |
| Stream-based updates | the_logger ^0.0.20 streaming API | Real-time updates without polling overhead |
| maxRecords cap | Default 5000 | Prevents OOM/jank with high-volume loggers |
| Responsive layout | Grid >=600dp, List <600dp | 5-column grid doesn't fit phone portrait |
| onExport callback | Optional, replaces default share_plus | Lets consumers avoid share_plus native setup |
| JSON pretty-print in detail only | Not during scroll | Avoids frame drops from parsing JSON on every row |

## 2. Data Model

Log data is represented as `List<Map<String, Object?>>` from `TheLogger.i().getAllLogsAsMaps()`.

Map fields per record:

| Field | Type | Description |
|-------|------|-------------|
| `id` | int | Record ID |
| `record_timestamp` | String | ISO 8601 timestamp |
| `session_id` | int | Session ID |
| `level` | String | Log level name (SEVERE, WARNING, INFO, etc.) |
| `message` | String | Log message |
| `logger_name` | String | Logger name |
| `error` | String? | Error details |
| `stack_trace` | String? | Stack trace |
| `time` | String | Additional time field |

## 3. API / Interface Design

### Public API

```dart
class TheLoggerViewerWidget extends StatefulWidget {
  const TheLoggerViewerWidget({
    super.key,
    this.colorScheme,    // optional custom level colors
    this.showExport,     // show "Export" button (default: true)
    this.maxRecords,     // max records to display (default: 5000)
    this.onExport,       // optional callback: (String filePath) => void
  });

  static void show(BuildContext context);
  static Route<void> route();
}
```

### LogDataSource (internal)

```dart
class LogDataSource {
  LogDataSource({this.maxRecords = 5000});

  Future<void> init();    // initial load via getAllLogsAsMaps() + subscribe to stream
  Future<void> refresh(); // manual re-fetch of full dataset
  void dispose();         // cancel stream subscription
  List<Map<String, Object?>> get logs;  // capped at maxRecords, most recent first
  List<int> get sessionIds;
  List<Map<String, Object?>> logsForSession(int sessionId);
  List<Map<String, Object?>> applyFilters({Set<String>? levels, String? text, String? logger});
  VoidCallback? onUpdate; // called when new records arrive via stream
}
```

### Responsive Breakpoint

- `>=600dp` width → `LogGrid` (table with columns: Timestamp, Level, Logger, Message)
- `<600dp` width → `LogList` (compact list: level/logger/time header, message below)

## 4. Key Patterns

### State Management
- `StatefulWidget` with internal `State` — no external state management
- `LogDataSource` handles data fetching, caching, stream subscription, and record capping
- Filter state (levels, text, logger) held in widget state
- Stream-based live updates from the_logger ^0.0.20 (no polling)

### Error Handling
- Graceful handling when `TheLogger.i()` returns empty data
- Null-safe access to optional fields (error, stackTrace)
- Export runs async with loading indicator; errors shown as snackbar

### Performance
- Records capped at `maxRecords` (default 5000) to prevent OOM
- JSON pretty-printing only in expanded detail view
- Filter debouncing (500ms) to reduce rebuilds
- Lazy rendering via ListView.builder

### Data Flow
```
TheLogger.i().getAllLogsAsMaps()
  → LogDataSource (fetch, cache, cap, group by session)
  → ViewerWidget (state: filters, selected session, selected record)
  → FilterBar / SessionNavigator / LogGrid|LogList / RecordDetails
```

## 5. Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| flutter | SDK | UI framework |
| the_logger | ^0.0.20 | Log data source via streaming API + getAllLogsAsMaps() |
| logging | ^1.3.0 | Level class for log levels |
| share_plus | ^10.0.0 | Default export sharing (skipped if onExport provided) |
| flutter_test | SDK (dev) | Testing framework |
| mocktail | ^1.0.4 (dev) | Mocking for tests |
| flutter_lints | ^6.0.0 (dev) | Lint rules |
