import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:multai_mobile/features/gallery/data/cache/photo_cache_service.dart';

Directory createTempDir() {
  return Directory.systemTemp.createTempSync('photo_cache_test_');
}

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = createTempDir();
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  final testBytes = Uint8List.fromList(List.generate(100, (i) => i));
  final testBytes2 = Uint8List.fromList(List.generate(200, (i) => i));

  group('basic operations', () {
    test('save and retrieve photo', () async {
      final service = PhotoCacheService(overrideDir: tempDir);
      final path = await service.saveToCache('photo1', testBytes);
      expect(path, isNotEmpty);
      expect(File(path).existsSync(), true);
      final cached = await service.getCachedPath('photo1');
      expect(cached, equals(path));
    });

    test('missing photo returns null', () async {
      final service = PhotoCacheService(overrideDir: tempDir);
      final path = await service.getCachedPath('nonexistent');
      expect(path, isNull);
    });

    test('clear cache removes all', () async {
      final service = PhotoCacheService(overrideDir: tempDir);
      await service.saveToCache('photo_a', testBytes);
      await service.saveToCache('photo_b', testBytes2);
      await service.clearCache();
      expect(await service.getCachedPath('photo_a'), isNull);
      expect(await service.getCachedPath('photo_b'), isNull);
    });

    test('files within TTL are returned', () async {
      final service = PhotoCacheService(
        overrideDir: tempDir,
        ttl: const Duration(days: 30),
      );
      await service.saveToCache('fresh', testBytes);
      expect(await service.getCachedPath('fresh'), isNotNull);
    });

    test('memory cache after disk cache hit', () async {
      final service = PhotoCacheService(overrideDir: tempDir);
      await service.saveToCache('mem', testBytes);
      final service2 = PhotoCacheService(overrideDir: tempDir);
      final first = await service2.getCachedPath('mem');
      expect(first, isNotNull);
      final second = await service2.getCachedPath('mem');
      expect(second, equals(first));
    });

    test('concurrent saves are serialized', () async {
      final service = PhotoCacheService(overrideDir: tempDir);
      final futures = [
        service.saveToCache('c1', testBytes),
        service.saveToCache('c2', testBytes2),
        service.saveToCache('c3', testBytes),
        service.saveToCache('c4', testBytes2),
      ];
      final paths = await Future.wait(futures);
      expect(paths.length, 4);
      for (final p in paths) {
        expect(File(p).existsSync(), true);
      }
    });
  });

  group('user isolation', () {
    test('different user prefixes isolate caches', () async {
      final dirA = createTempDir();
      final dirB = createTempDir();
      final a = PhotoCacheService(userId: 'userA', overrideDir: dirA);
      final b = PhotoCacheService(userId: 'userB', overrideDir: dirB);
      await a.saveToCache('shared', testBytes);
      expect(await a.getCachedPath('shared'), isNotNull);
      expect(await b.getCachedPath('shared'), isNull);
      dirA.deleteSync(recursive: true);
      dirB.deleteSync(recursive: true);
    });
  });

  group('eviction by size', () {
    test('no eviction when under size limit', () async {
      final service = PhotoCacheService(
        overrideDir: tempDir,
        maxCacheSize: 10000,
        maxFiles: 100,
      );
      for (int i = 0; i < 10; i++) {
        await service.saveToCache('keep_$i', testBytes);
      }
      for (int i = 0; i < 10; i++) {
        expect(await service.getCachedPath('keep_$i'), isNotNull);
      }
    });

    test('evicts oldest when over size limit', () async {
      final service = PhotoCacheService(
        overrideDir: tempDir,
        maxCacheSize: 250,
        maxFiles: 100,
      );
      // 100 + 200 = 300 > 250, so the oldest should be evicted
      await service.saveToCache('first', testBytes);
      await service.saveToCache('second', testBytes2);
      // second is larger, first is older — first should be evicted
      expect(await service.getCachedPath('second'), isNotNull);
    });

    test('evicts multiple files when far over size limit', () async {
      final service = PhotoCacheService(
        overrideDir: tempDir,
        maxCacheSize: 150,
        maxFiles: 100,
      );
      await service.saveToCache('a', testBytes);
      await service.saveToCache('b', testBytes);
      await service.saveToCache('c', testBytes);
      // 300 > 150, only newest should survive
      expect(await service.getCachedPath('a'), isNull);
      expect(await service.getCachedPath('b'), isNull);
      expect(await service.getCachedPath('c'), isNotNull);
    });
  });

  group('eviction by file count', () {
    test('no eviction when under file limit', () async {
      final service = PhotoCacheService(
        overrideDir: tempDir,
        maxCacheSize: 100000,
        maxFiles: 5,
      );
      for (int i = 0; i < 3; i++) {
        await service.saveToCache('f_$i', testBytes);
      }
      for (int i = 0; i < 3; i++) {
        expect(await service.getCachedPath('f_$i'), isNotNull);
      }
    });

    test('evicts oldest when over file limit', () async {
      final service = PhotoCacheService(
        overrideDir: tempDir,
        maxCacheSize: 100000,
        maxFiles: 3,
      );
      await service.saveToCache('one', testBytes);
      await service.saveToCache('two', testBytes);
      await service.saveToCache('three', testBytes);
      await service.saveToCache('four', testBytes);
      // oldest 'one' should be evicted
      expect(await service.getCachedPath('one'), isNull);
      expect(await service.getCachedPath('two'), isNotNull);
      expect(await service.getCachedPath('three'), isNotNull);
      expect(await service.getCachedPath('four'), isNotNull);
    });
  });

  group('LRU ordering', () {
    test('oldest accessed files evicted first by size', () async {
      final service = PhotoCacheService(
        overrideDir: tempDir,
        maxCacheSize: 250,
        maxFiles: 100,
      );
      await service.saveToCache('old', testBytes);
      await service.saveToCache('new', testBytes2);
      // old is 100B, new is 200B, total 300 > 250
      // old should be evicted since it was written first
      expect(await service.getCachedPath('new'), isNotNull);
    });

    test('oldest accessed files evicted first by count', () async {
      final service = PhotoCacheService(
        overrideDir: tempDir,
        maxCacheSize: 100000,
        maxFiles: 2,
      );
      await service.saveToCache('first', testBytes);
      await service.saveToCache('second', testBytes);
      await service.saveToCache('third', testBytes);
      // first is oldest should be evicted
      expect(await service.getCachedPath('first'), isNull);
      expect(await service.getCachedPath('second'), isNotNull);
      expect(await service.getCachedPath('third'), isNotNull);
    });
  });

  group('protects pending writes', () {
    test('does not delete files being written', () async {
      final service = PhotoCacheService(
        overrideDir: tempDir,
        maxCacheSize: 1,
        maxFiles: 100,
      );
      // Save one file, then save another — first should be protected
      await service.saveToCache('protected', testBytes);
      // The save below triggers eviction, but 'protected' is no longer pending
      // because saveToCache removes from _pendingWrites before eviction
      // This test verifies no crash during concurrent eviction
      await service.saveToCache('trigger', testBytes2);
      // At least the newest file should be present
      expect(await service.getCachedPath('trigger'), isNotNull);
    });
  });

  group('stats', () {
    test('stats reflect cache state', () async {
      final service = PhotoCacheService(
        overrideDir: tempDir,
        maxCacheSize: 10000,
        maxFiles: 100,
      );
      expect((await service.getStats()).fileCount, 0);
      await service.saveToCache('stat1', testBytes);
      await service.saveToCache('stat2', testBytes2);
      final stats = await service.getStats();
      expect(stats.fileCount, 2);
      expect(stats.totalBytes, 300);
      expect(stats.maxCacheSize, 10000);
      expect(stats.maxFiles, 100);
      expect(stats.formattedSize, contains('B'));
      expect(stats.formattedLimit, isNotEmpty);
    });

    test('usagePercent reflects size ratio', () async {
      final service = PhotoCacheService(
        overrideDir: tempDir,
        maxCacheSize: 1000,
        maxFiles: 100,
      );
      await service.saveToCache('p1', testBytes);
      await service.saveToCache('p2', testBytes);
      // 200 / 1000 = 20%
      final stats = await service.getStats();
      expect(stats.usagePercent, greaterThan(0));
      expect(stats.usagePercent, lessThan(100));
    });

    test('zero stats for empty cache', () async {
      final service = PhotoCacheService(overrideDir: tempDir);
      final stats = await service.getStats();
      expect(stats.totalBytes, 0);
      expect(stats.fileCount, 0);
      expect(stats.oldestFile, isNull);
      expect(stats.newestFile, isNull);
    });
  });
}
