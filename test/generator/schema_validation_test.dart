import 'dart:convert';
import 'dart:io';

import 'package:flutter_design_system_template/core/design_system/generator/generate_tokens.dart'
    as generator;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('validateTokensSchema', () {
    test('accepts current project tokens.json', () {
      final data = _readJson('lib/core/design_system/generator/tokens.json');

      expect(() => generator.validateTokensSchema(data), returnsNormally);
    });

    test('rejects fixture: missing light theme', () {
      final data = _readJson('test/fixtures/tokens_invalid_missing_light.json');

      expect(
        () => generator.validateTokensSchema(data),
        throwsA(
          isA<StateError>().having(
            (e) => e.message.toString(),
            'message',
            contains('must include a "light" theme'),
          ),
        ),
      );
    });

    test('rejects fixture: invalid hex color', () {
      final data = _readJson('test/fixtures/tokens_invalid_color_format.json');

      expect(
        () => generator.validateTokensSchema(data),
        throwsA(
          isA<StateError>().having(
            (e) => e.message.toString(),
            'message',
            contains('Expected format: #RRGGBB'),
          ),
        ),
      );
    });

    test('rejects fixture: unknown typography color reference', () {
      final data = _readJson('test/fixtures/tokens_invalid_typography_color_ref.json');

      expect(
        () => generator.validateTokensSchema(data),
        throwsA(
          isA<StateError>().having(
            (e) => e.message.toString(),
            'message',
            contains('Unknown color reference'),
          ),
        ),
      );
    });

    test('rejects fixture: invalid dimension type', () {
      final data = _readJson('test/fixtures/tokens_invalid_dimension_type.json');

      expect(
        () => generator.validateTokensSchema(data),
        throwsA(
          isA<StateError>().having(
            (e) => e.message.toString(),
            'message',
            contains('Allowed: width, height, radius'),
          ),
        ),
      );
    });

    test('rejects fixture: non-numeric responsive value', () {
      final data = _readJson('test/fixtures/tokens_invalid_spacing_mobile_type.json');

      expect(
        () => generator.validateTokensSchema(data),
        throwsA(
          isA<StateError>().having(
            (e) => e.message.toString(),
            'message',
            contains('Invalid numeric value'),
          ),
        ),
      );
    });

    test('rejects fixture: invalid gradient type', () {
      final data = _readJson('test/fixtures/tokens_invalid_gradient_type.json');

      expect(
        () => generator.validateTokensSchema(data),
        throwsA(
          isA<StateError>().having(
            (e) => e.message.toString(),
            'message',
            contains('Allowed: linear, radial, sweep'),
          ),
        ),
      );
    });

    test('rejects fixture: unknown gradient color reference', () {
      final data = _readJson('test/fixtures/tokens_invalid_gradient_color_ref.json');

      expect(
        () => generator.validateTokensSchema(data),
        throwsA(
          isA<StateError>().having(
            (e) => e.message.toString(),
            'message',
            contains('Unknown gradient color reference'),
          ),
        ),
      );
    });

    test('rejects fixture: unknown shadow color reference', () {
      final data = _readJson('test/fixtures/tokens_invalid_shadow_color_ref.json');

      expect(
        () => generator.validateTokensSchema(data),
        throwsA(
          isA<StateError>().having(
            (e) => e.message.toString(),
            'message',
            contains('Unknown gradient color reference'),
          ),
        ),
      );
    });

    test('rejects fixture: invalid shadow opacity bounds', () {
      final data = _readJson('test/fixtures/tokens_invalid_shadow_opacity.json');

      expect(
        () => generator.validateTokensSchema(data),
        throwsA(
          isA<StateError>().having(
            (e) => e.message.toString(),
            'message',
            contains('must be between 0 and 1'),
          ),
        ),
      );
    });

    test('rejects fixture: unknown elevation alias target', () {
      final data = _readJson('test/fixtures/tokens_invalid_elevation_alias_target.json');

      expect(
        () => generator.validateTokensSchema(data),
        throwsA(
          isA<StateError>().having(
            (e) => e.message.toString(),
            'message',
            contains('Unknown elevation alias target'),
          ),
        ),
      );
    });

    test('rejects fixture: invalid typography letterSpacing type', () {
      final data = _readJson('test/fixtures/tokens_invalid_typography_letter_spacing_type.json');

      expect(
        () => generator.validateTokensSchema(data),
        throwsA(
          isA<StateError>().having(
            (e) => e.message.toString(),
            'message',
            contains('Invalid letterSpacing'),
          ),
        ),
      );
    });
  });
}

Map<String, dynamic> _readJson(String path) {
  final file = File(path);
  final decoded = jsonDecode(file.readAsStringSync());
  return Map<String, dynamic>.from(decoded as Map);
}
