import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_logger_viewer_widget/src/level_colors.dart';

void main() {
  group('LevelColors', () {
    test('returns correct default colors for each level', () {
      expect(LevelColors.defaultColors['SHOUT'], Colors.red.shade900);
      expect(LevelColors.defaultColors['SEVERE'], Colors.red.shade700);
      expect(LevelColors.defaultColors['WARNING'], Colors.orange.shade700);
      expect(LevelColors.defaultColors['INFO'], Colors.blue.shade700);
      expect(LevelColors.defaultColors['CONFIG'], Colors.green.shade700);
      expect(LevelColors.defaultColors['FINE'], Colors.grey.shade600);
      expect(LevelColors.defaultColors['FINER'], Colors.grey.shade500);
      expect(LevelColors.defaultColors['FINEST'], Colors.grey.shade400);
    });

    test('colorForLevel returns correct color', () {
      expect(LevelColors.colorForLevel('SEVERE'), Colors.red.shade700);
      expect(LevelColors.colorForLevel('INFO'), Colors.blue.shade700);
    });

    test('colorForLevel returns grey for unknown level', () {
      expect(LevelColors.colorForLevel('UNKNOWN'), Colors.grey);
    });

    test('colorForLevel uses custom scheme when provided', () {
      final custom = {'INFO': Colors.purple};
      expect(
        LevelColors.colorForLevel('INFO', customScheme: custom),
        Colors.purple,
      );
      // Falls back to default for levels not in custom scheme
      expect(
        LevelColors.colorForLevel('SEVERE', customScheme: custom),
        Colors.red.shade700,
      );
    });
  });
}
