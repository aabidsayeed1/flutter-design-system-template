import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'test_lock.dart';

void main() {
  test('generator recreates missing managed files', () async {
    await withGeneratorLock(() async {
      final initialRun = await _runGenerator();
      expect(initialRun.exitCode, 0, reason: _failureReason('initial run', initialRun));

      final originalContents = _snapshot(_filesUnderTest);

      try {
        for (final entry in _filesUnderTest.entries) {
          final path = entry.key;
          final expectedSnippet = entry.value;
          final file = File(path);

          expect(file.existsSync(), isTrue, reason: 'Expected managed file to exist: $path');

          file.deleteSync();
          expect(file.existsSync(), isFalse, reason: 'Expected file to be deleted: $path');

          final regenRun = await _runGenerator();
          expect(
            regenRun.exitCode,
            0,
            reason: _failureReason('regen after deleting $path', regenRun),
          );

          expect(file.existsSync(), isTrue, reason: 'Expected generator to recreate: $path');

          final content = file.readAsStringSync();
          expect(
            content,
            contains(expectedSnippet),
            reason: 'Recreated file does not contain expected anchor for $path',
          );
        }
      } finally {
        _restore(originalContents);
      }
    });
  });
}

Future<ProcessResult> _runGenerator() {
  return Process.run(
    'dart',
    ['run', 'lib/core/design_system/generator/generate_tokens.dart'],
  );
}

String _failureReason(String stage, ProcessResult result) {
  return '$stage failed with exit code ${result.exitCode}\n'
      'stdout:\n${result.stdout}\n'
      'stderr:\n${result.stderr}';
}

Map<String, String?> _snapshot(Map<String, String> files) {
  final snapshot = <String, String?>{};
  for (final path in files.keys) {
    final file = File(path);
    snapshot[path] = file.existsSync() ? file.readAsStringSync() : null;
  }
  return snapshot;
}

void _restore(Map<String, String?> snapshot) {
  for (final entry in snapshot.entries) {
    final file = File(entry.key);
    final original = entry.value;

    if (original == null) {
      if (file.existsSync()) {
        file.deleteSync();
      }
      continue;
    }

    file.parent.createSync(recursive: true);
    file.writeAsStringSync(original);
  }
}

const Map<String, String> _filesUnderTest = {
  'lib/core/design_system/generated/generated_spacing_tokens.dart': 'class GeneratedSpacingTokens',
  'lib/core/design_system/generated/generated_gradient_tokens.dart':
      'class GeneratedThemeGradientTokens',
  'lib/core/design_system/generated/generated_shadow_tokens.dart':
      'class GeneratedThemeShadowTokens',
  'lib/core/design_system/generated/generated_elevation_tokens.dart':
      'class GeneratedElevationTokens',
  'lib/core/design_system/tokens/shadow_tokens.dart': 'class LightShadowTokens',
  'lib/core/design_system/tokens/elevation_tokens.dart': 'class ElevationTokens',
  'lib/core/design_system/theme/app_theme_extension.dart': 'class AppThemeExtension',
  'lib/core/design_system/extensions/context_extension.dart':
      'extension ContextExtension on BuildContext',
  'lib/core/design_system/responsive/responsive.dart': 'class Responsive',
};
