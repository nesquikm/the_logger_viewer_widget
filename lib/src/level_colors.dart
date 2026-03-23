import 'package:flutter/material.dart';

/// Maps log level names to display colors.
///
/// Provides sensible defaults for standard logging levels (SHOUT through
/// FINEST) and supports custom overrides via [colorForLevel].
class LevelColors {
  LevelColors._();

  /// Default color mapping for standard log levels.
  static const Map<String, Color> defaultColors = {
    'SHOUT': Color(0xFFB71C1C), // Red 900
    'SEVERE': Color(0xFFD32F2F), // Red 700
    'WARNING': Color(0xFFF57C00), // Orange 700
    'INFO': Color(0xFF1976D2), // Blue 700
    'CONFIG': Color(0xFF388E3C), // Green 700
    'FINE': Color(0xFF757575), // Grey 600
    'FINER': Color(0xFF9E9E9E), // Grey 500
    'FINEST': Color(0xFFBDBDBD), // Grey 400
  };

  /// Returns the color for a given log [level].
  ///
  /// If [customScheme] contains the level, that color is used. Otherwise
  /// falls back to [defaultColors], then to [Colors.grey].
  static Color colorForLevel(
    String level, {
    Map<String, Color>? customScheme,
  }) {
    if (customScheme != null && customScheme.containsKey(level)) {
      return customScheme[level]!;
    }
    return defaultColors[level] ?? Colors.grey;
  }
}
