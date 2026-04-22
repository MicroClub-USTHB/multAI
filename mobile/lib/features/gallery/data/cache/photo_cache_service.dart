import 'dart:collection';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/constants/storage_keys.dart';
import '../../../../core/storage/app_local_storage.dart';

class _GalleryCacheEntry {
  final String path;
  final int sizeBytes;
  final int lastAccessedMs;

  const _GalleryCacheEntry({
    required this.path,
    required this.sizeBytes,
    required this.lastAccessedMs,
  });

  factory _GalleryCacheEntry.fromJson(Map<String, dynamic> json) {
    return _GalleryCacheEntry(
      path: json['path'] as String,
      sizeBytes: (json['size_bytes'] as num).toInt(),
      lastAccessedMs: (json['last_accessed_ms'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    'path': path,
    'size_bytes': sizeBytes,
    'last_accessed_ms': lastAccessedMs,
  };

  _GalleryCacheEntry copyWith({
    String? path,
    int? sizeBytes,
    int? lastAccessedMs,
  }) {
    return _GalleryCacheEntry(
      path: path ?? this.path,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      lastAccessedMs: lastAccessedMs ?? this.lastAccessedMs,
    );
  }
}

class PhotoCacheService {
  static const int _maxCacheSizeBytes = 500 * 1024 * 1024; // 500MB
  static const Duration _maxEntryAge = Duration(days: 30);
  static const String _cacheFolder = 'gallery_cache';

  final AppLocalStorage localStorage;
  final LinkedHashMap<String, String> _memoryCache =
      LinkedHashMap<String, String>();

  Map<String, _GalleryCacheEntry>? _manifest;

  PhotoCacheService({required this.localStorage});

  Future<Map<String, _GalleryCacheEntry>> _loadManifest() async {
    if (_manifest != null) return _manifest!;

    final raw = localStorage.getJson(StorageKeys.galleryCacheManifest);
    if (raw == null) {
      _manifest = <String, _GalleryCacheEntry>{};
      return _manifest!;
    }

    _manifest = raw.map(
      (photoId, value) => MapEntry(
        photoId,
        _GalleryCacheEntry.fromJson(Map<String, dynamic>.from(value as Map)),
      ),
    );
    return _manifest!;
  }

  Future<void> _saveManifest(Map<String, _GalleryCacheEntry> manifest) async {
    _manifest = manifest;
    await localStorage.setJson(StorageKeys.galleryCacheManifest, {
      for (final entry in manifest.entries) entry.key: entry.value.toJson(),
    });
  }

  Future<Directory> _getCacheDir() async {
    final base = Platform.isIOS
        ? await getApplicationDocumentsDirectory()
        : await getApplicationCacheDirectory();

    final dir = Directory('${base.path}/$_cacheFolder');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<String?> getCachedPath(String photoId) async {
    final cachedPath = _memoryCache[photoId];
    if (cachedPath != null) {
      final cachedFile = File(cachedPath);
      if (await cachedFile.exists()) {
        await _touch(photoId, cachedPath);
        return cachedPath;
      }
      _memoryCache.remove(photoId);
    }

    final manifest = await _loadManifest();
    final entry = manifest[photoId];
    if (entry == null) return null;

    final file = File(entry.path);
    if (!await file.exists()) {
      manifest.remove(photoId);
      await _saveManifest(manifest);
      return null;
    }

    _memoryCache[photoId] = file.path;
    manifest[photoId] = entry.copyWith(
      lastAccessedMs: DateTime.now().millisecondsSinceEpoch,
    );
    await _saveManifest(manifest);
    return file.path;
  }

  Future<String> saveToCache(String photoId, Uint8List bytes) async {
    final dir = await _getCacheDir();
    final file = File('${dir.path}/$photoId');
    await file.writeAsBytes(bytes, flush: true);

    final manifest = await _loadManifest();
    final entry = _GalleryCacheEntry(
      path: file.path,
      sizeBytes: bytes.length,
      lastAccessedMs: DateTime.now().millisecondsSinceEpoch,
    );

    _memoryCache[photoId] = file.path;
    manifest[photoId] = entry;
    await _saveManifest(manifest);

    await _cleanupIfNeeded();
    return file.path;
  }

  Future<void> _touch(String photoId, String path) async {
    final manifest = await _loadManifest();
    final entry = manifest[photoId];
    if (entry == null) return;

    manifest[photoId] = entry.copyWith(
      path: path,
      lastAccessedMs: DateTime.now().millisecondsSinceEpoch,
    );
    await _saveManifest(manifest);
  }

  Future<void> _cleanupIfNeeded() async {
    try {
      final manifest = await _loadManifest();
      if (manifest.isEmpty) return;

      final now = DateTime.now();
      final removable = <MapEntry<String, _GalleryCacheEntry>>[];
      int totalSize = 0;

      for (final entry in manifest.entries) {
        totalSize += entry.value.sizeBytes;
        final file = File(entry.value.path);
        if (!await file.exists() ||
            now.difference(
                  DateTime.fromMillisecondsSinceEpoch(
                    entry.value.lastAccessedMs,
                  ),
                ) >
                _maxEntryAge) {
          removable.add(entry);
        }
      }

      for (final entry in removable) {
        final file = File(entry.value.path);
        if (await file.exists()) {
          try {
            await file.delete();
          } catch (_) {
            // Ignore failed deletions and keep the manifest consistent.
          }
        }
        manifest.remove(entry.key);
        _memoryCache.remove(entry.key);
        totalSize -= entry.value.sizeBytes;
      }

      if (totalSize <= _maxCacheSizeBytes) {
        await _saveManifest(manifest);
        return;
      }

      final ordered = manifest.entries.toList()
        ..sort(
          (a, b) => a.value.lastAccessedMs.compareTo(b.value.lastAccessedMs),
        );

      for (final entry in ordered) {
        if (totalSize <= _maxCacheSizeBytes) break;

        final file = File(entry.value.path);
        if (await file.exists()) {
          try {
            await file.delete();
          } catch (_) {
            continue;
          }
        }

        manifest.remove(entry.key);
        _memoryCache.remove(entry.key);
        totalSize -= entry.value.sizeBytes;
      }

      await _saveManifest(manifest);
    } catch (e) {
      debugPrint('Cache cleanup error: $e');
    }
  }

  Future<void> clearCache() async {
    _memoryCache.clear();
    _manifest = <String, _GalleryCacheEntry>{};
    await localStorage.removePref(StorageKeys.galleryCacheManifest);

    final dir = await _getCacheDir();
    if (await dir.exists()) await dir.delete(recursive: true);
  }
}
