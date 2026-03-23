# the_logger_viewer_widget

Embeddable Flutter widget for viewing logs from [the_logger](https://pub.dev/packages/the_logger) directly — no file export needed. Drop a single widget into any app and get a full-featured log viewer.

## Features

- **Responsive layout** — scrollable table on wide screens (>=600dp), compact list on narrow screens
- **Level color-coding** — each log level gets a distinct color, fully customizable
- **Filtering** — filter by log level (multi-select), text search (debounced), and logger name
- **Search highlighting** — matching terms highlighted in the grid and detail view
- **Session navigation** — dropdown + first/prev/next/last buttons to traverse sessions
- **Record details** — tap a row to expand full details with auto-formatted embedded JSON
- **Copy to clipboard** — one-tap copy of any log record
- **Export** — async export with loading indicator; provide `onExport` callback or use default behavior
- **Live updates** — stream-based real-time updates from `the_logger` ^0.0.20 (no polling)
- **Material 3** — follows host app theme, supports light and dark mode
- **Lightweight** — no codegen, no heavy dependencies, pure Flutter widgets

## Getting started

Add `the_logger_viewer_widget` to your `pubspec.yaml`:

```yaml
dependencies:
  the_logger_viewer_widget: ^0.0.1
```

Make sure you already have [the_logger](https://pub.dev/packages/the_logger) initialized in your app:

```dart
await TheLogger.i().init();
```

## Usage

### Drop-in widget

Place the viewer anywhere in your widget tree:

```dart
import 'package:the_logger_viewer_widget/the_logger_viewer_widget.dart';

// In a settings page, debug panel, etc.
TheLoggerViewerWidget()
```

### Full-screen page

Push a dedicated log viewer page:

```dart
// Via static helper
TheLoggerViewerWidget.show(context);

// Or as a named route
GoRouter(
  routes: [
    GoRoute(
      path: '/logs',
      builder: (_, __) => const TheLoggerViewerPage(),
    ),
  ],
)
```

### Custom configuration

```dart
TheLoggerViewerWidget(
  // Custom level colors
  colorScheme: const {
    'SEVERE': Colors.redAccent,
    'WARNING': Colors.amber,
    'INFO': Colors.cyan,
  },
  // Cap displayed records
  maxRecords: 1000,
  // Hide export button
  showExport: false,
  // Custom export handling (skips default share_plus behavior)
  onExport: (filePath) => myCustomShare(filePath),
)
```

### Using TheLoggerViewerPage

The page wrapper provides a Scaffold with an AppBar:

```dart
TheLoggerViewerPage(
  colorScheme: const {'INFO': Colors.teal},
  maxRecords: 2000,
  showExport: true,
)
```

## Architecture

```
lib/
├── the_logger_viewer_widget.dart     # Package export barrel
└── src/
    ├── viewer_widget.dart            # Main TheLoggerViewerWidget
    ├── viewer_page.dart              # Full-screen page wrapper
    ├── log_grid.dart                 # Wide-screen scrollable table
    ├── log_list.dart                 # Narrow-screen list layout
    ├── log_row.dart                  # Individual row widget
    ├── record_details.dart           # Expanded detail view
    ├── filter_bar.dart               # Level + text + logger filters
    ├── session_navigator.dart        # Session dropdown + nav buttons
    ├── export_button.dart            # Export functionality
    ├── log_data_source.dart          # Data layer (fetch, cache, stream)
    ├── level_colors.dart             # Log level color mapping
    └── extensions/
        ├── string_extensions.dart    # JSON pretty-printing
        └── text_extensions.dart      # Search highlighting
```

## Level color defaults

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

Override any level by passing a `colorScheme` map.

## Additional information

- **Source:** [GitHub](https://github.com/nesquikm/the_logger_viewer_widget)
- **Issues:** [GitHub Issues](https://github.com/nesquikm/the_logger_viewer_widget/issues)
- **Related packages:**
  - [the_logger](https://pub.dev/packages/the_logger) — the logging library (dependency)
  - [the_logger_viewer](https://pub.dev/packages/the_logger_viewer) — standalone desktop app that reads exported JSON files
