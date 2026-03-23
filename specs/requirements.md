# the_logger_viewer_widget

## Overview

An embeddable Flutter widget package for viewing logs from `the_logger` directly — no file export needed. Drop a single widget into any app and get a full-featured log viewer that reads from `TheLogger.i()` at runtime.

**Relationship to existing packages:**
- `the_logger` — the logging library (dependency)
- `the_logger_viewer` — standalone desktop app that reads exported JSON files
- `the_logger_viewer_widget` — **this package**: embeddable widget, reads from `the_logger` directly

## Public API

### Primary Widget

```dart
/// Drop-in log viewer widget. Reads logs from TheLogger.i() directly.
class TheLoggerViewerWidget extends StatefulWidget {
  const TheLoggerViewerWidget({
    super.key,
    this.colorScheme,    // optional custom level colors
    this.showExport,     // show "Export" button (default: true)
    this.maxRecords,     // max records to display (default: 5000)
    this.onExport,       // optional export callback (replaces default behavior)
  });
}
```

### Convenience Navigation

```dart
/// Push a full-screen log viewer page.
static void show(BuildContext context);

/// Use as a route in GoRouter / Navigator.
static Route<void> route();
```

### Usage Example

```dart
// As a widget (e.g., in a settings page)
TheLoggerViewerWidget()

// As a full-screen page
ElevatedButton(
  onPressed: () => TheLoggerViewerWidget.show(context),
  child: Text('View Logs'),
)

// With custom export handling (no share_plus needed)
TheLoggerViewerWidget(
  onExport: (filePath) => myCustomShareFunction(filePath),
)
```

## Features

### Log Display
- **Wide screens (>=600dp):** Scrollable table with columns: Timestamp, Level, Logger, Message
- **Narrow screens (<600dp):** List layout — level/logger/timestamp header, message below
- Color-coded rows by log level (SEVERE=red, WARNING=orange, INFO=blue, FINE=grey, etc.)
- Alternating row colors for readability
- Tap a row to expand details
- **Performance:** Caps displayed records at `maxRecords` (default 5000) — most recent records shown

### Filtering
- **Level filter**: multi-select dropdown to show/hide specific log levels
- **Text search**: filter by message content (case-insensitive), highlighted in grid message column
- **Logger filter**: filter by logger name
- Filters are debounced (500ms) to avoid excessive rebuilds

### Session Navigation
- Session selector dropdown to pick a specific session
- Navigation buttons (first, previous, next, last) for quick traversal
- Session boundaries visually separated in the grid
- Default: show current (latest) session

### Record Details
- Expandable detail view when a row is tapped
- Shows all fields: timestamp, level, logger, full message, error, stack trace
- Auto-detects and pretty-prints embedded JSON in messages (only in expanded view, not during scroll)
- Copy record to clipboard button

### Live Refresh
- Stream-based live updates via the_logger's streaming API (no polling)
- Manual refresh button
- Shows last refresh timestamp

### Export
- "Export" button calls `TheLogger.i().writeAllLogsToJson()` asynchronously
- Shows loading indicator during export
- Default behavior: share on mobile (via share_plus), save on desktop
- **Optional `onExport` callback**: when provided, receives the file path and lets the consumer handle sharing/saving (avoids share_plus dependency)
- Can be hidden via `showExport: false`

### Search Highlighting
- Active search terms highlighted in the grid message column
- Also highlighted in the expanded detail view
- Case-insensitive substring matching

## Architecture

```
lib/
├── the_logger_viewer_widget.dart     # Package export barrel
└── src/
    ├── viewer_widget.dart            # Main TheLoggerViewerWidget
    ├── viewer_page.dart              # Full-screen page wrapper + show()/route()
    ├── log_grid.dart                 # Wide-screen scrollable table
    ├── log_list.dart                 # Narrow-screen list layout
    ├── log_row.dart                  # Individual row widget
    ├── record_details.dart           # Expanded detail view
    ├── filter_bar.dart               # Level + text + logger filters
    ├── session_navigator.dart        # Session dropdown + jump controls
    ├── export_button.dart            # Export functionality
    ├── log_data_source.dart          # Reads from TheLogger.i().getAllLogsAsMaps()
    ├── level_colors.dart             # Log level → Color mapping
    └── extensions/
        ├── string_extensions.dart    # JSON pretty-printing
        └── text_extensions.dart      # Search highlighting
```

## Data Flow

```
TheLogger.i().getAllLogsAsMaps()
  ↓
LogDataSource (fetches, caches, groups by session, caps at maxRecords)
  ↓
ViewerWidget (manages state: filters, selected session, selected record)
  ↓
├── FilterBar (level, text, logger filters)
├── SessionNavigator (session dropdown + nav buttons)
├── LogGrid/LogList → LogRow (filtered, color-coded, highlighted)
└── RecordDetails (expanded view with JSON formatting)
```

### LogDataSource

Wraps `TheLogger.i()` calls and provides:
- `Future<void> refresh()` — re-fetches logs (capped at maxRecords, most recent first)
- `List<Map<String, Object?>> get logs` — cached log maps
- `List<int> get sessionIds` — distinct session IDs
- `List<Map<String, Object?>> logsForSession(int sessionId)` — filtered by session
- `List<Map<String, Object?>> applyFilters({levels, text, logger})` — combined filtering

### Map Fields (from the_logger)

| Field | Type | Description |
|-------|------|-------------|
| `id` | int | Record ID |
| `record_timestamp` | String | ISO 8601 timestamp |
| `session_id` | int | Session ID |
| `level` | String | Log level name |
| `message` | String | Log message |
| `logger_name` | String | Logger name |
| `error` | String? | Error details |
| `stack_trace` | String? | Stack trace |
| `time` | String | Additional time field |

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  the_logger: ^0.0.20    # direct dependency — streaming API + getAllLogsAsMaps()
  logging: ^1.3.0        # for Level class
  share_plus: ^10.0.0    # default export sharing (skipped if onExport provided)
```

**No heavy dependencies** — no pluto_grid, no freezed, no code generation. Pure Flutter widgets to keep it lightweight and embeddable.

**Note:** `share_plus` is used only for the default export behavior. Consumers can avoid it entirely by providing `onExport` callback.

## Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| No pluto_grid | Custom ListView/DataTable | Keep dependency footprint minimal for an embeddable widget |
| No freezed/codegen | Plain Dart classes | Avoid build_runner requirement for consumers |
| Direct TheLogger dependency | `getAllLogsAsMaps()` | No file export step, live data, simpler UX |
| StatefulWidget (not BLoC) | Internal state only | No state management dependency on consumers |
| Stream-based updates | the_logger ^0.0.20 streaming API | Real-time updates without polling overhead |
| maxRecords cap | Default 5000 | Prevents OOM/jank with high-volume loggers |
| Responsive layout | Grid >=600dp, List <600dp | 5-column grid doesn't fit phone portrait |
| onExport callback | Optional, replaces share_plus | Lets consumers avoid share_plus native setup |
| JSON pretty-print in detail only | Not during scroll | Avoids frame drops from parsing JSON on every row |

## Visual Design

- Follows host app's `Theme` (Material 3) for background/surface colors
- Level colors are defaults that can be overridden via `colorScheme`
- Responsive: grid on wide screens, list on narrow screens
- Works in full-screen or embedded in a card/panel
- No custom fonts or assets — pure Material widgets

## Level Color Defaults

| Level | Color |
|-------|-------|
| SHOUT | Red 900 |
| SEVERE | Red 700 |
| WARNING | Orange 700 |
| INFO | Blue 700 |
| CONFIG | Green 700 |
| FINE | Grey 600 |
| FINER | Grey 500 |
| FINEST | Grey 400 |

## Testing Strategy

- **Framework:** flutter_test, mocktail
- **Mock TheLogger** — verify `getAllLogsAsMaps()` is called, return canned data
- **Widget tests:**
  - Renders log grid/list with sample data
  - Responsive layout switches at 600dp breakpoint
  - Level filter hides/shows rows
  - Text search filters messages and highlights matches in grid
  - Session navigation switches sessions (dropdown + buttons)
  - Tap row expands details
  - JSON auto-formatting in detail view only
  - Export button triggers `writeAllLogsToJson()` with loading indicator
  - onExport callback receives file path
  - Copy button puts record text on clipboard
  - maxRecords caps displayed records
- **No real database** — all tests use mocked TheLogger

## Milestones

### M1: Core Display & Data Source

**Goal:** Render logs from TheLogger in a scrollable, responsive display.
**Tasks:**
1. Implement LogDataSource (fetch from TheLogger, cache, group by session, cap at maxRecords)
2. Implement level_colors.dart (log level → Color mapping)
3. Build LogRow widget (individual row, color-coded by level)
4. Build LogGrid widget (wide-screen scrollable table)
5. Build LogList widget (narrow-screen list layout)
6. Create ViewerWidget with responsive layout switching at 600dp
7. Update barrel export file

**Acceptance Criteria:**
- [ ] LogDataSource fetches and caches logs from TheLogger.i()
- [ ] LogDataSource caps at maxRecords (most recent)
- [ ] LogGrid renders on wide screens (>=600dp)
- [ ] LogList renders on narrow screens (<600dp)
- [ ] Rows are color-coded by log level
- [ ] Gate passes: `fvm flutter analyze && fvm flutter test`

### M2: Filtering & Search

**Goal:** Filter logs by level, text, and logger name with highlighted matches.
**Tasks:**
1. Build FilterBar widget (level multi-select, text input, logger dropdown)
2. Implement filter logic in LogDataSource
3. Add debouncing (500ms) to text search
4. Implement search highlighting in grid message column (text_extensions.dart)

**Acceptance Criteria:**
- [ ] Level filter shows/hides log levels
- [ ] Text search filters by message content (case-insensitive)
- [ ] Search terms highlighted in grid message column
- [ ] Logger filter narrows by logger name
- [ ] Filters are debounced (500ms)
- [ ] Gate passes

### M3: Record Details & Session Navigation

**Goal:** Tap to expand details, navigate between sessions.
**Tasks:**
1. Build RecordDetails widget (all fields, copy button)
2. Implement JSON pretty-printing in detail view only (string_extensions.dart)
3. Build SessionNavigator (session dropdown + first/prev/next/last buttons)
4. Wire session selection and record expansion to ViewerWidget state
5. Add search term highlighting in detail view

**Acceptance Criteria:**
- [ ] Tap row shows full record details
- [ ] Embedded JSON is auto-formatted in detail view
- [ ] Copy button copies record text to clipboard
- [ ] Session dropdown selects specific sessions
- [ ] Navigation buttons traverse sessions
- [ ] Search terms highlighted in detail view
- [ ] Gate passes

### M4: Public API, Export & Polish

**Goal:** Full public API, export functionality, theming, refresh.
**Tasks:**
1. Finalize TheLoggerViewerWidget public parameters (refreshInterval, colorScheme, showExport, maxRecords, onExport)
2. Create viewer_page.dart — full-screen page with `show()` and `route()`
3. Implement export button — async writeAllLogsToJson() with loading indicator
4. Default export: share_plus on mobile, save on desktop
5. onExport callback: pass file path to consumer
6. Add periodic refresh with configurable interval
7. Add manual refresh button + last refresh timestamp

**Acceptance Criteria:**
- [ ] `TheLoggerViewerWidget()` works as drop-in widget
- [ ] `TheLoggerViewerWidget.show(context)` opens full-screen page
- [ ] Export shows loading indicator and produces file
- [ ] Default export uses share_plus; onExport callback overrides
- [ ] Custom color scheme applied when provided
- [ ] Auto-refresh works at configured interval
- [ ] Manual refresh button works
- [ ] Gate passes

### M5: Visual Widget Tests

**Goal:** Comprehensive widget tests verifying visual presentation — theming, colors, responsive layout, empty/edge states, and cross-widget integration.
**Tasks:**
1. LogRow visual tests — level colors, alternating backgrounds, text truncation
2. LogGrid visual tests — column headers, row color-coding, scroll behavior
3. LogList visual tests — compact layout, level color indicator
4. FilterBar visual tests — chip colors, active state, clear button visibility
5. SessionNavigator visual tests — dropdown contents, button disabled states at boundaries
6. RecordDetails visual tests — field rendering, JSON formatting, search highlights
7. ExportButton visual tests — loading indicator, disabled state during export
8. ViewerWidget integration visual tests — responsive breakpoint, empty state, dark/light theme, custom colorScheme
9. ViewerPage visual tests — app bar, back navigation, full-screen layout

**Acceptance Criteria:**
- [ ] Every widget has visual tests covering its presentation states
- [ ] Light and dark theme tested on ViewerWidget
- [ ] Custom colorScheme overrides verified
- [ ] Responsive breakpoint tested (grid at >=600dp, list at <600dp)
- [ ] Empty state / no-matching-filters state tested
- [ ] Nav button enabled/disabled states verified at session boundaries
- [ ] Loading states verified (export)
- [ ] Gate passes

### M6: Stream-Based Live Updates

**Goal:** Replace timer-based polling with the_logger's streaming API for real-time log updates.
**Tasks:**
1. Bump the_logger dependency to ^0.0.20
2. Update LogDataSource — subscribe to TheLogger.i() stream for new records, keep getAllLogsAsMaps() for initial load
3. Remove Timer.periodic polling from ViewerWidget
4. Remove refreshInterval parameter from TheLoggerViewerWidget public API
5. Keep manual refresh button (re-fetches full dataset)
6. Update existing tests to use stream-based mocks instead of timer-based assertions

**Acceptance Criteria:**
- [ ] LogDataSource subscribes to the_logger stream on init
- [ ] New log records appear in the viewer without polling
- [ ] refreshInterval parameter removed from public API
- [ ] Manual refresh button still works
- [ ] Stream subscription disposed on widget dispose
- [ ] No Timer.periodic usage remains
- [ ] Gate passes: `fvm flutter analyze && fvm flutter test`
