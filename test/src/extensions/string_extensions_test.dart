import 'package:flutter_test/flutter_test.dart';
import 'package:the_logger_viewer_widget/src/extensions/string_extensions.dart';

void main() {
  group('StringJsonExtension', () {
    test('prettyPrintJson formats valid JSON object', () {
      const input = '{"key":"value","nested":{"a":1}}';
      final result = input.prettyPrintJson();
      expect(result, contains('"key": "value"'));
      expect(result, contains('\n')); // Should have newlines (pretty-printed)
    });

    test('prettyPrintJson formats valid JSON array', () {
      const input = '[1,2,3]';
      final result = input.prettyPrintJson();
      expect(result, contains('1'));
      expect(result, contains('\n'));
    });

    test('prettyPrintJson returns original for non-JSON', () {
      const input = 'Hello world';
      expect(input.prettyPrintJson(), 'Hello world');
    });

    test('prettyPrintJson handles embedded JSON in text', () {
      const input = 'Config value: {"key": "value"}';
      final result = input.prettyPrintJson();
      expect(result, contains('Config value:'));
      expect(result, contains('"key": "value"'));
    });

    test('containsJson detects JSON-like content', () {
      expect('{"key": "value"}'.containsJson, isTrue);
      expect('[1, 2, 3]'.containsJson, isTrue);
      expect('Hello world'.containsJson, isFalse);
    });

    test('prettyPrintJson handles invalid JSON gracefully', () {
      const input = '{not valid json}';
      // Should not throw, returns original or partially formatted
      expect(() => input.prettyPrintJson(), returnsNormally);
    });
  });
}
