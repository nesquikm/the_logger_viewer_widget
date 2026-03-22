import 'dart:convert';

extension StringJsonExtension on String {
  /// Detects embedded JSON in the string and pretty-prints it.
  /// Returns the original string if no valid JSON is found.
  String prettyPrintJson() {
    // Try the whole string as JSON first
    final trimmed = trim();
    if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
      try {
        final decoded = jsonDecode(trimmed);
        return const JsonEncoder.withIndent('  ').convert(decoded);
      } catch (_) {
        // Not valid JSON, continue
      }
    }

    // Try to find JSON embedded in the string
    final jsonPattern = RegExp(r'(\{[^{}]*(?:\{[^{}]*\}[^{}]*)*\}|\[[^\[\]]*(?:\[[^\[\]]*\][^\[\]]*)*\])');
    final match = jsonPattern.firstMatch(this);
    if (match != null) {
      try {
        final decoded = jsonDecode(match.group(0)!);
        final pretty = const JsonEncoder.withIndent('  ').convert(decoded);
        return replaceRange(match.start, match.end, pretty);
      } catch (_) {
        // Not valid JSON
      }
    }

    return this;
  }

  /// Returns true if the string contains JSON-like content.
  bool get containsJson {
    return contains('{') || contains('[');
  }
}
