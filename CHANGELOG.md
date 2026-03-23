## 0.0.3

* Fix log level display: normalize integer level values from `the_logger` to level name strings.

## 0.0.2

* Remove unused `share_plus` dependency (fixes pub.dev dependency score).

## 0.0.1

* Initial release.
* Embeddable log viewer widget reading from `the_logger` directly.
* Responsive layout: scrollable table on wide screens (>=600dp), compact list on narrow screens.
* Log level color-coding with customizable color scheme.
* Filter bar with level multi-select, text search (debounced), and logger dropdown.
* Search term highlighting in grid message column and detail view.
* Session navigation with dropdown and first/prev/next/last buttons.
* Expandable record details with auto-formatted embedded JSON.
* Copy record to clipboard.
* Export button with loading indicator and optional `onExport` callback.
* Full-screen page wrapper with `show()` and `route()` convenience methods.
* Stream-based live updates via `the_logger` ^0.0.20 streaming API.
* Manual refresh button with last-refresh timestamp.
* `maxRecords` cap (default 5000) to prevent OOM with high-volume loggers.
* Material 3 theming — follows host app theme, supports light and dark mode.
