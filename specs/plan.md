# Implementation Plan

## Milestone Order

M1 → M2 → M3 → M4 → M5
                    ↘ M6

M2 and M3 can be worked in parallel after M1. M4 depends on both M2 and M3. M5 and M6 depend on M4. M5 and M6 can be worked in parallel. M1–M4 are complete.

---

## M1: Core Display & Data Source

**Goal:** Render logs from TheLogger in a scrollable, responsive display.
**Prerequisites:** None

**Tasks:**
1. Implement `lib/src/log_data_source.dart` — fetch from TheLogger.i(), cache, group by session, cap at maxRecords
2. Implement `lib/src/level_colors.dart` — log level → Color mapping
3. Build `lib/src/log_row.dart` — individual row widget with level color
4. Build `lib/src/log_grid.dart` — wide-screen scrollable table (>=600dp)
5. Build `lib/src/log_list.dart` — narrow-screen list layout (<600dp)
6. Create `lib/src/viewer_widget.dart` — main widget with responsive layout switching
7. Update `lib/the_logger_viewer_widget.dart` barrel export

**Tests:**
- LogDataSource: fetches logs, caches, groups by session, caps at maxRecords
- LevelColors: correct color for each level
- LogGrid: renders table on wide screens
- LogList: renders list on narrow screens
- LogRow: displays correct fields, applies level color
- Responsive: layout switches at 600dp breakpoint

**Acceptance Criteria:**
- [x] LogDataSource fetches and caches logs from TheLogger.i()
- [x] LogDataSource caps at maxRecords (most recent)
- [x] LogGrid renders on wide screens (>=600dp)
- [x] LogList renders on narrow screens (<600dp)
- [x] Rows are color-coded by log level
- [x] Gate passes: `fvm flutter analyze && fvm flutter test`

**Gate:** `fvm flutter analyze && fvm flutter test`

---

## M2: Filtering & Search

**Goal:** Filter logs by level, text, and logger name with highlighted matches.
**Prerequisites:** M1

**Tasks:**
1. Add filter methods to LogDataSource (`applyFilters`)
2. Build `lib/src/filter_bar.dart` — level multi-select, text input, logger dropdown
3. Add debouncing (500ms) to text search
4. Implement `lib/src/extensions/text_extensions.dart` — search highlighting in grid message column
5. Wire FilterBar to ViewerWidget state

**Tests:**
- LogDataSource.applyFilters: level, text, logger filtering
- FilterBar: renders controls, emits filter changes
- Debouncing: text search is debounced at 500ms
- Text highlighting: search terms highlighted in grid message column

**Acceptance Criteria:**
- [x] Level filter shows/hides log levels
- [x] Text search filters by message content (case-insensitive)
- [x] Search terms highlighted in grid message column
- [x] Logger filter narrows by logger name
- [x] Filters are debounced (500ms)
- [x] Gate passes

**Gate:** `fvm flutter analyze && fvm flutter test`

---

## M3: Record Details & Session Navigation

**Goal:** Tap to expand details, navigate between sessions.
**Prerequisites:** M1

**Tasks:**
1. Build `lib/src/record_details.dart` — all fields, copy button
2. Implement `lib/src/extensions/string_extensions.dart` — JSON detection and pretty-printing (detail view only)
3. Build `lib/src/session_navigator.dart` — session dropdown + first/prev/next/last buttons
4. Wire session selection and record expansion to ViewerWidget state
5. Add search term highlighting in detail view

**Tests:**
- RecordDetails: renders all fields, formats embedded JSON, copy button
- StringExtensions: JSON detection and pretty-printing
- SessionNavigator: dropdown selection, navigation buttons
- Integration: tap row expands details, search terms highlighted

**Acceptance Criteria:**
- [x] Tap row shows full record details
- [x] Embedded JSON is auto-formatted in detail view only
- [x] Copy button copies record text to clipboard
- [x] Session dropdown selects specific sessions
- [x] Navigation buttons traverse sessions
- [x] Search terms highlighted in detail view
- [x] Gate passes

**Gate:** `fvm flutter analyze && fvm flutter test`

---

## M4: Public API, Export & Polish

**Goal:** Full public API, export functionality, theming, refresh.
**Prerequisites:** M2, M3

**Tasks:**
1. Finalize TheLoggerViewerWidget public parameters (refreshInterval, colorScheme, showExport, maxRecords, onExport)
2. Create `lib/src/viewer_page.dart` — full-screen page with `show()` and `route()`
3. Implement `lib/src/export_button.dart` — async writeAllLogsToJson() with loading indicator
4. Default export: share_plus on mobile, save on desktop
5. onExport callback: pass file path to consumer, skip share_plus
6. Add periodic refresh with configurable interval
7. Add manual refresh button + last refresh timestamp

**Tests:**
- ViewerPage: show() pushes page, route() returns valid route
- ExportButton: triggers writeAllLogsToJson(), shows loading, calls onExport callback
- Refresh: periodic timer fires at configured interval
- ColorScheme: custom colors applied when provided

**Acceptance Criteria:**
- [x] `TheLoggerViewerWidget()` works as drop-in widget
- [x] `TheLoggerViewerWidget.show(context)` opens full-screen page
- [x] Export shows loading indicator and produces file
- [x] Default export uses share_plus; onExport callback overrides
- [x] Custom color scheme applied when provided
- [x] Auto-refresh works at configured interval
- [x] Manual refresh button works
- [x] Gate passes

**Gate:** `fvm flutter analyze && fvm flutter test`

---

## M5: Visual Widget Tests

**Goal:** Comprehensive widget tests verifying visual presentation — theming, colors, responsive layout, empty/edge states, and cross-widget integration.
**Prerequisites:** M4

**Tasks:**
1. `LogRow` visual tests — correct level colors applied, alternating row backgrounds, text truncation
2. `LogGrid` visual tests — column headers present and ordered, row color-coding visible, scrollable with many rows
3. `LogList` visual tests — compact layout renders level/logger/time header + message body, level color indicator
4. `FilterBar` visual tests — level chips show correct colors, active filter state visually distinct, clear button visible when filters active
5. `SessionNavigator` visual tests — dropdown shows session list, nav buttons disabled at boundaries (first/last)
6. `RecordDetails` visual tests — all fields rendered, JSON pretty-printed with indentation, copy button present, search highlights visible
7. `ExportButton` visual tests — loading indicator shown during export, button disabled while loading
8. `ViewerWidget` integration visual tests — responsive layout switching at 600dp, empty state message when no logs, dark/light theme renders correctly, custom colorScheme applied
9. `ViewerPage` visual tests — app bar with title, back navigation, full-screen layout

**Tests:**
- LogRow: level colors, alternating backgrounds, text truncation
- LogGrid: column headers, row colors, scroll behavior
- LogList: compact layout, level indicator
- FilterBar: chip colors, active state, clear button
- SessionNavigator: dropdown contents, button disabled states
- RecordDetails: field rendering, JSON formatting, highlights
- ExportButton: loading indicator, disabled state
- ViewerWidget: responsive switch, empty state, dark/light theme, custom colors
- ViewerPage: app bar, back nav, layout

**Acceptance Criteria:**
- [x] Every widget has visual tests covering its presentation states
- [x] Light and dark theme tested on ViewerWidget
- [x] Custom colorScheme overrides verified
- [x] Responsive breakpoint tested (grid at >=600dp, list at <600dp)
- [x] Empty state / no-matching-filters state tested
- [x] Nav button enabled/disabled states verified at session boundaries
- [x] Loading states verified (export)
- [x] Gate passes: `fvm flutter analyze && fvm flutter test`

**Gate:** `fvm flutter analyze && fvm flutter test`

---

## M6: Stream-Based Live Updates

**Goal:** Replace timer-based polling with the_logger's streaming API for real-time log updates.
**Prerequisites:** M4

**Tasks:**
1. Bump `the_logger` dependency to `^0.0.20` in `pubspec.yaml`
2. Update `LogDataSource` — add `init()` to subscribe to TheLogger.i() stream, append new records to cache (respecting maxRecords cap)
3. Add `onUpdate` callback to `LogDataSource` so ViewerWidget can call `setState` on new records
4. Add `dispose()` to `LogDataSource` — cancel stream subscription
5. Remove `Timer.periodic` polling from `ViewerWidget`
6. Remove `refreshInterval` parameter from `TheLoggerViewerWidget` public API
7. Keep manual refresh button (calls `LogDataSource.refresh()` for full re-fetch)
8. Update all existing tests — replace timer-based mocks with stream-based mocks

**Tests:**
- LogDataSource: stream subscription receives new records, appends to cache, respects maxRecords
- LogDataSource: onUpdate callback fires when stream emits
- LogDataSource: dispose cancels stream subscription
- ViewerWidget: no Timer.periodic usage
- ViewerWidget: new records appear without manual refresh
- Manual refresh button still re-fetches full dataset

**Acceptance Criteria:**
- [x] LogDataSource subscribes to the_logger stream on init
- [x] New log records appear in the viewer without polling
- [x] refreshInterval parameter removed from public API
- [x] Manual refresh button still works
- [x] Stream subscription disposed on widget dispose
- [x] No Timer.periodic usage remains
- [x] Gate passes: `fvm flutter analyze && fvm flutter test`

**Gate:** `fvm flutter analyze && fvm flutter test`

---

## Milestone Dependency Graph

```
M1 → M2 → M4 → M5
 ↘ M3 ↗    ↘ M6
```

M1–M6 complete.
