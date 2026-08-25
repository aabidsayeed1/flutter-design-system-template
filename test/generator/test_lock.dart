import 'dart:io';

Future<T> withGeneratorLock<T>(Future<T> Function() action) async {
  final lockFile = File('test/.generator_test.lock');
  lockFile.parent.createSync(recursive: true);

  final raf = await lockFile.open(mode: FileMode.write);
  try {
    await _acquireLockWithRetry(raf);
    return await action();
  } finally {
    await raf.unlock();
    await raf.close();
  }
}

Future<void> _acquireLockWithRetry(RandomAccessFile raf) async {
  const maxAttempts = 300;
  const retryDelay = Duration(milliseconds: 100);

  for (var attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      await raf.lock();
      return;
    } on FileSystemException catch (e) {
      final isLockContention = e.osError?.errorCode == 35;
      if (!isLockContention || attempt == maxAttempts) {
        rethrow;
      }
      await Future<void>.delayed(retryDelay);
    }
  }
}
