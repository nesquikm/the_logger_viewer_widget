/// Embeddable Flutter widget for viewing logs from
/// [the_logger](https://pub.dev/packages/the_logger) directly.
///
/// Drop a single widget into any app and get a full-featured log viewer
/// with filtering, search highlighting, session navigation, export, and
/// real-time stream-based updates.
///
/// ```dart
/// // Drop-in widget
/// TheLoggerViewerWidget()
///
/// // Full-screen page
/// TheLoggerViewerWidget.show(context);
/// ```
library;

export 'src/level_colors.dart';
export 'src/log_data_source.dart';
export 'src/viewer_page.dart';
export 'src/viewer_widget.dart';
