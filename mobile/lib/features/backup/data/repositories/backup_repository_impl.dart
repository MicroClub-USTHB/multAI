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

      final paths = <String>[];
      for (final file in files) {
        final ext = file.path.split('.').last.toLowerCase();
        if (['jpg', 'jpeg', 'png', 'webp', 'heic'].contains(ext)) {
          paths.add(file.path);
        }
      }

      return Right(paths);
    } catch (e) {
      debugPrint('Failed to get cached photo paths: $e');
      return Left(CacheFailure('Failed to read cached photos: $e'));
    }
  }

  @override
  Future<Either<Failure, File>> createBackupZip(
    List<String> photoPaths,
  ) async {
    try {
      final archive = Archive();

      for (int i = 0; i < photoPaths.length; i++) {
        final file = File(photoPaths[i]);
        if (!await file.exists()) continue;

        final bytes = await file.readAsBytes();
        final fileName = 'photo_${i + 1}_${file.path.split('/').last}';
        archive.addFile(ArchiveFile(fileName, bytes.length, bytes));
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
        final ext = file.path.split('.').last.toLowerCase();
        if (['jpg', 'jpeg', 'png', 'webp', 'heic'].contains(ext)) {
          count++;
        }
      }

      return Right(count);
    } catch (e) {
      return const Right(0);
    }
  }

  Future<Directory> _getCacheDir() async {
    final base = Platform.isIOS
        ? await getApplicationDocumentsDirectory()
        : await getApplicationCacheDirectory();
    return Directory('${base.path}/gallery_cache');
  }
}
