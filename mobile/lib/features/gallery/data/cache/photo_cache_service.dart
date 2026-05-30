import 'dart:io';
import 'dart:collection';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

class PhotoCacheService {
  static const int _maxCacheSizeBytes = 500 * 1024 * 1024; // 500MB
  static const String _cacheFolder = 'gallery_cache';

  // ── Memory cache — LRU ────────────────────────────────────────────────────
  final LinkedHashMap<String, String> _memoryCache =
      LinkedHashMap<String, String>();

  // ── Get cache directory ───────────────────────────────────────────────────
  Future<Directory> _getCacheDir() async {
    final base = Platform.isIOS
        ? await getApplicationDocumentsDirectory() // iOS — Documents (survives backup)
        : await getApplicationCacheDirectory(); // Android — cache dir

    final dir = Directory('${base.path}/$_cacheFolder');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  // ── Check if photo is cached ──────────────────────────────────────────────
  Future<String?> getCachedPath(String photoId) async {
    // 1. check memory cache first
    if (_memoryCache.containsKey(photoId)) {
      return _memoryCache[photoId];
    }

    // 2. check disk cache
    final dir = await _getCacheDir();
    final file = File('${dir.path}/$photoId');
    if (await file.exists()) {
      _memoryCache[photoId] = file.path;
      return file.path;
    }

    return null;
  }

  // ── Save photo bytes to cache ─────────────────────────────────────────────
  Future<String> saveToCache(String photoId, Uint8List bytes) async {
    final dir = await _getCacheDir();
    final file = File('${dir.path}/$photoId');
    await file.writeAsBytes(bytes, flush: true);

    // update memory cache
    _memoryCache[photoId] = file.path;

    // cleanup if over limit
    await _cleanupIfNeeded(dir);

    return file.path;
  }

  // ── LRU cleanup ───────────────────────────────────────────────────────────
  Future<void> _cleanupIfNeeded(Directory dir) async {
    try {
      final files = dir.listSync().whereType<File>().toList();
      int totalSize = 0;
      for (final f in files) {
        totalSize += await f.length();
      }

      if (totalSize <= _maxCacheSizeBytes) return;

      // sort by last access — oldest first
      files.sort(
        (a, b) => a.statSync().accessed.compareTo(b.statSync().accessed),
      );

      for (final file in files) {
        if (totalSize <= _maxCacheSizeBytes) break;
        final size = await file.length();
        await file.delete();
        totalSize -= size;
        // remove from memory cache
        _memoryCache.removeWhere((_, v) => v == file.path);
      }
    } catch (e) {
      debugPrint('Cache cleanup error: $e');
    }
  }

  // ── Clear all cache ───────────────────────────────────────────────────────
  Future<void> clearCache() async {
    _memoryCache.clear();
    final dir = await _getCacheDir();
    if (await dir.exists()) await dir.delete(recursive: true);
  }
}
