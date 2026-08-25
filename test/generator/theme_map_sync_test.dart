import 'dart:convert';
import 'dart:io';

import 'package:flutter_design_system_template/core/design_system/theme/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AppTheme.themes keys stay in sync with tokens.json themes keys', () {
    final file = File('lib/core/design_system/generator/tokens.json');
    final decoded = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    final tokensThemes = Map<String, dynamic>.from(decoded['themes'] as Map).keys.toSet();

    final appThemeKeys = AppTheme.themes.keys.toSet();

    expect(appThemeKeys, equals(tokensThemes));
  });

  test('AppTheme.theme falls back to first configured theme for unknown key', () {
    final fallback = AppTheme.theme('__unknown__theme__');

    expect(identical(fallback, AppTheme.themes.values.first), isTrue);
  });
}
