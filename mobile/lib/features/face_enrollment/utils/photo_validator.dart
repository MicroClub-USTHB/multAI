import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../../core/errors/failure.dart';

class PhotoProcessor {
  static const int _maxFileSizeBytes = 5 * 1024 * 1024; // 5MB
  static const Set<String> _allowedExtensions = {
    'jpg',
    'jpeg',
    'png',
    'heic',
    'webp',
  };

  /// Processes a photo: Validates type -> Validates size -> Compresses
  static Future<Either<Failure, File>> processAndValidate(
    String filePath,
  ) async {
    try {
      final file = File(filePath);

      // 1. Quick Check: Existence
      if (!await file.exists()) {
        return const Left(FileNotFoundFailure('File does not exist.'));
      }

      // 2. Quick Check: Extension (Use Set.contains for O(1) lookup)
      final ext = p.extension(filePath).replaceFirst('.', '').toLowerCase();
      if (!_allowedExtensions.contains(ext)) {
        return const Left(
          InvalidFileFormatFailure('Invalid format. Use JPG, PNG, HEIC, or WEBP.'),
        );
      }

      // 3. Heavy Check: Initial Size (Fail if even the raw file is astronomically large)
      // Note: We check size before compression to avoid processing 100MB+ files.
      final int initialSize = await file.length();
      if (initialSize > _maxFileSizeBytes * 2) {
        // Allow some headroom before compression
        return const Left(
          FileTooLargeFailure('Original image is too large.'),
        );
      }

      // 4. Transform: Compression
      final compressedFile = await _compressImage(file);

      // 5. Final Size Validation
      if (await compressedFile.length() > _maxFileSizeBytes) {
        return const Left(
          FileTooLargeFailure('Photo exceeds 5MB limit after compression.'),
        );
      }

      return Right(compressedFile);
    } catch (e) {
      return Left(UnknownFailure('Failed to process photo'));
    }
  }

  static Future<File> _compressImage(File file) async {
    final tempDir = await getTemporaryDirectory();
    final targetPath = p.join(
      tempDir.path,
      '${DateTime.now().microsecondsSinceEpoch}.jpg',
    );

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 70,
      minWidth: 1080,
      minHeight: 1080,
      format: CompressFormat.jpeg,
    );

    // If compression fails, return original; otherwise return new File
    return result != null ? File(result.path) : file;
  }

  static String getContentType(String filePath) {
    final ext = p.extension(filePath).replaceFirst('.', '').toLowerCase();
    final mimeTypes = {
      'png': 'image/png',
      'heic': 'image/heic',
      'webp': 'image/webp',
    };
    return mimeTypes[ext] ?? 'image/jpeg';
  }
}
