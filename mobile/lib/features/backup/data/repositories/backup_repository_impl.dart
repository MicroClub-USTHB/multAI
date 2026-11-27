import 'dart:io';
import 'package:archive/archive.dart';
import 'package:dartz/dartz.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/repositories/backup_repository.dart';

class BackupRepositoryImpl implements BackupRepository {
  @override
  Future<Either<Failure, List<String>>> getCachedPhotoPaths() async {
    try {
      final dir = await _getCacheDir();
      if (!await dir.exists()) return const Right([]);

      final files = await dir
          .list()
          .where((e) => e is File)
          .cast<File>()
          .toList();

      // Cached files are stored as "<userId>_<photoId>" with no extension,
      // so we cannot filter by suffix. Everything in gallery_cache is an image.
      final paths = <String>[];
      for (final file in files) {
        try {
          if (await file.length() > 0) {
            paths.add(file.path);
          }
        } catch (_) {}
      }

      return Right(paths);
    } catch (e) {
      debugPrint('Failed to get cached photo paths: $e');
      return Left(CacheFailure('Failed to read cached photos: $e'));
    }
  }

  @override
  Future<Either<Failure, File>> createBackupZip(
    List<String> photoPaths, {
    void Function(int completed, int total)? onProgress,
  }) async {
    try {
      final archive = Archive();

      for (int i = 0; i < photoPaths.length; i++) {
        final file = File(photoPaths[i]);
        if (!await file.exists()) {
          onProgress?.call(i + 1, photoPaths.length);
          continue;
        }

        final bytes = await file.readAsBytes();
        if (bytes.isEmpty) {
          onProgress?.call(i + 1, photoPaths.length);
          continue;
        }

        final ext = _imageExtension(bytes);
        final baseName = file.path.split('/').last;
        // Cached files have no extension; append one so the extracted image
        // is recognised by viewers/gallery apps.
        final fileName = baseName.contains('.')
            ? 'photo_${i + 1}_$baseName'
            : 'photo_${i + 1}_$baseName.$ext';
        archive.addFile(ArchiveFile(fileName, bytes.length, bytes));

        onProgress?.call(i + 1, photoPaths.length);
      }

      final zipData = ZipEncoder().encode(archive);

      final outputDir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final zipFile = File('${outputDir.path}/multai_backup_$timestamp.zip');
      await zipFile.writeAsBytes(zipData, flush: true);

      return Right(zipFile);
    } catch (e) {
      debugPrint('Failed to create backup ZIP: $e');
      return Left(CacheFailure('Failed to create backup: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> getPhotoCount() async {
    try {
      final dir = await _getCacheDir();
      if (!await dir.exists()) return const Right(0);

      final files = await dir
          .list()
          .where((e) => e is File)
          .cast<File>()
          .toList();

      int count = 0;
      for (final file in files) {
        try {
          if (await file.length() > 0) count++;
        } catch (_) {}
      }

      return Right(count);
    } catch (e) {
      return const Right(0);
    }
  }

  /// Detects a sensible file extension from the image's magic bytes. Cached
  /// photos are stored without an extension, so the ZIP entries need one.
  String _imageExtension(List<int> bytes) {
    if (bytes.length >= 3 &&
        bytes[0] == 0xFF &&
        bytes[1] == 0xD8 &&
        bytes[2] == 0xFF) {
      return 'jpg';
    }
    if (bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return 'png';
    }
    if (bytes.length >= 12 &&
        bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x45 &&
        bytes[10] == 0x42 &&
        bytes[11] == 0x50) {
      return 'webp';
    }
    if (bytes.length >= 2 && bytes[0] == 0xFF && bytes[1] == 0xD8) {
      return 'jpg';
    }
    return 'jpg';
  }

  Future<Directory> _getCacheDir() async {
    final base = Platform.isIOS
        ? await getApplicationDocumentsDirectory()
        : await getApplicationCacheDirectory();
    return Directory('${base.path}/gallery_cache');
  }
}
