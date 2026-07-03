import 'dart:io';
import 'dart:async';
import 'dart:collection';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

class PhotoCacheService {
  static const int _defaultMaxCacheSize = 500 * 1024 * 1024;
  static const int _defaultMaxFiles = 2000;
  static const String _cacheFolder = 'gallery_cache';
  static const Duration _defaultTtl = Duration(days: 7);

  final String? _userId;
  final Directory? _overrideDir;
  final Duration _ttl;
  final int _maxCacheSize;
  final int _maxFiles;

  final LinkedHashMap<String, String> _memoryCache =
      LinkedHashMap<String, String>();
  final Set<String> _pendingWrites = {};
  Future<void>? _lastOp;

  PhotoCacheService({
    String? userId,
    Directory? overrideDir,
    Duration? ttl,
    int? maxCacheSize,
    int? maxFiles,
  }) : _userId = userId,
       _overrideDir = overrideDir,
       _ttl = ttl ?? _defaultTtl,
       _maxCacheSize = maxCacheSize ?? _defaultMaxCacheSize,
       _maxFiles = maxFiles ?? _defaultMaxFiles;

  String get _userPrefix => _userId != null ? '${_userId}_' : '';

  Future<T> _serialize<T>(Future<T> Function() fn) async {
    final prev = _lastOp;
    final completer = Completer<T>();
    _lastOp = completer.future.then((_) {}).catchError((_) {});
    if (prev != null) {
      try {
        await prev;
      } catch (_) {}
    }
    try {
      completer.complete(await fn());
    } catch (e) {
      completer.completeError(e);
    }
    return completer.future;
  }

  Future<Directory> _getCacheDir() async {
    if (_overrideDir != null) {
      final dir = _overrideDir;
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      return dir;
    }
    final base = Platform.isIOS
        ? await getApplicationDocumentsDirectory()
        : await getApplicationCacheDirectory();
    final dir = Directory('${base.path}/$_cacheFolder');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  String _fileKey(String photoId) => '$_userPrefix$photoId';

  Future<String?> getCachedPath(String photoId) async {
    final key = _fileKey(photoId);

    if (_memoryCache.containsKey(key)) return _memoryCache[key];

    final dir = await _getCacheDir();
    final file = File('${dir.path}/$key');
    if (await file.exists()) {
      if (await _isExpired(file)) {
        await file.delete();
        return null;
      }
      _memoryCache[key] = file.path;
      return file.path;
    }

    return null;
  }

  Future<bool> _isExpired(File file) async {
    try {
      final stat = await file.stat();
      final age = DateTime.now().difference(stat.modified);
      return age > _ttl;
    } catch (_) {
      return false;
    }
  }

  Future<String> saveToCache(String photoId, Uint8List bytes) async {
    return _serialize<String>(() async {
      final key = _fileKey(photoId);
      final dir = await _getCacheDir();
      final file = File('${dir.path}/$key');
      _pendingWrites.add(key);
      try {
        await file.writeAsBytes(bytes, flush: true);
        _memoryCache[key] = file.path;
        await _evictIfNeeded(dir);
      } finally {
        _pendingWrites.remove(key);
      }
      return file.path;
    });
  }

  Future<void> _evictIfNeeded(Directory dir) async {
    try {
      final entities = await dir.list().toList();
      final allFiles = <_FileInfo>[];
      final evictable = <_FileInfo>[];
      final protected = _pendingWrites;

      for (final entity in entities) {
        if (entity is! File) continue;
        final key = entity.uri.pathSegments.last;
        try {
          final stat = await entity.stat();
          final info = _FileInfo(
            file: entity,
            size: stat.size,
            accessed: stat.accessed,
            modified: stat.modified,
          );
          allFiles.add(info);
          if (!protected.contains(key)) evictable.add(info);
        } catch (_) {}
      }

      if (allFiles.isEmpty) return;

      int totalSize = allFiles.fold(0, (sum, f) => sum + f.size);
      var totalCount = allFiles.length;

      if (totalSize <= _maxCacheSize && totalCount <= _maxFiles) return;

      DateTime bestTime(_FileInfo info) =>
          info.accessed.year > 2000 ? info.accessed : info.modified;

      evictable.sort((a, b) => bestTime(a).compareTo(bestTime(b)));

      for (final info in evictable) {
        if (totalSize <= _maxCacheSize && totalCount <= _maxFiles) break;
        try {
          await info.file.delete();
          totalSize -= info.size;
          totalCount--;
          _memoryCache.removeWhere((_, v) => v == info.file.path);
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('Cache eviction error: $e');
    }
  }

  Future<void> clearCache() async {
    return _serialize<void>(() async {
      _memoryCache.clear();
      final dir = await _getCacheDir();
      if (await dir.exists()) await dir.delete(recursive: true);
    });
  }

  Future<CacheStats> getStats() async {
    final dir = await _getCacheDir();
    if (!await dir.exists()) {
      return CacheStats(
        totalBytes: 0,
        fileCount: 0,
        maxCacheSize: _maxCacheSize,
        maxFiles: _maxFiles,
      );
    }

    try {
      final entities = await dir.list().toList();
      final files = entities.whereType<File>().toList();
      int totalSize = 0;
      DateTime? oldest;
      DateTime? newest;

      final allStats = await Future.wait(
        files.map((f) async {
          try {
            final stat = await f.stat();
            return (
              size: stat.size,
              modified: stat.modified,
            );
          } catch (_) {
            return (size: 0, modified: DateTime.now());
          }
        }),
      );

      for (final s in allStats) {
        totalSize += s.size;
        if (oldest == null || s.modified.isBefore(oldest)) oldest = s.modified;
        if (newest == null || s.modified.isAfter(newest)) newest = s.modified;
      }

      return CacheStats(
        totalBytes: totalSize,
        fileCount: files.length,
        oldestFile: oldest,
        newestFile: newest,
        maxCacheSize: _maxCacheSize,
        maxFiles: _maxFiles,
      );
    } catch (_) {
      return CacheStats(
        totalBytes: 0,
        fileCount: 0,
        maxCacheSize: _maxCacheSize,
        maxFiles: _maxFiles,
      );
    }
  }
}

class _FileInfo {
  final File file;
  final int size;
  final DateTime accessed;
  final DateTime modified;

  const _FileInfo({
    required this.file,
    required this.size,
    required this.accessed,
    required this.modified,
  });
}

class CacheStats {
  final int totalBytes;
  final int fileCount;
  final DateTime? oldestFile;
  final DateTime? newestFile;
  final int maxCacheSize;
  final int maxFiles;

  const CacheStats({
    required this.totalBytes,
    required this.fileCount,
    this.oldestFile,
    this.newestFile,
    this.maxCacheSize = 500 * 1024 * 1024,
    this.maxFiles = 2000,
  });

  double get usagePercent {
    final sizeRatio = maxCacheSize > 0 ? totalBytes / maxCacheSize : 0.0;
    final countRatio = maxFiles > 0 ? fileCount / maxFiles : 0.0;
    return (sizeRatio > countRatio ? sizeRatio : countRatio) * 100;
  }

  String get formattedSize {
    if (totalBytes < 1024) return '$totalBytes B';
    if (totalBytes < 1024 * 1024) {
      return '${(totalBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(totalBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String get formattedLimit {
    if (maxCacheSize < 1024 * 1024) {
      return '${(maxCacheSize / 1024).toStringAsFixed(0)} KB';
    }
    return '${(maxCacheSize / (1024 * 1024)).toStringAsFixed(0)} MB';
  }
}
