import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'test_lock.dart';

void main() {
  test('generator is idempotent across two consecutive runs', () async {
    await withGeneratorLock(() async {
      final firstRun = await _runGenerator();
      expect(firstRun.exitCode, 0, reason: _failureReason('first run', firstRun));

      final firstSnapshot = _snapshotManagedFiles();

      final secondRun = await _runGenerator();
      expect(secondRun.exitCode, 0, reason: _failureReason('second run', secondRun));

      final secondSnapshot = _snapshotManagedFiles();

      expect(
        secondSnapshot.keys.toSet(),
        equals(firstSnapshot.keys.toSet()),
        reason: 'Managed file set changed between runs.',
      );

      for (final path in firstSnapshot.keys) {
        expect(
          secondSnapshot[path],
          equals(firstSnapshot[path]),
          reason: 'File changed between consecutive runs: $path',
        );
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

Map<String, String> _snapshotManagedFiles() {
  final files = <String, String>{};

  for (final path in _managedDirectories) {
    final dir = Directory(path);
    if (!dir.existsSync()) {
      continue;
    }

    final entities = dir
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));

    for (final file in entities) {
      files[file.path] = file.readAsStringSync();
    }
  }

  for (final path in _managedSingleFiles) {
    final file = File(path);
    if (file.existsSync()) {
      files[file.path] = file.readAsStringSync();
    }
  }

  return files;
}

const List<String> _managedDirectories = [
  'lib/core/design_system/generated',
  'lib/core/design_system/tokens',
  'lib/core/design_system/theme',
  'lib/core/design_system/responsive',
];

const List<String> _managedSingleFiles = [
  'lib/core/design_system/extensions/context_extension.dart',
];
