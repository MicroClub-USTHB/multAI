import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;

import '../../../../core/errors/failure.dart';

class PhotoValidator {
  static const int _maxFileSizeBytes = 5 * 1024 * 1024; // 5MB
  static const List<String> _allowedExtensions = [
    'jpg',
    'jpeg',
    'png',
    'heic',
    'webp',
  ];

  /// Validates a photo file by checking existence, compressing, size, and format.
  static Future<Either<Failure, File>> validate(String filePath) async {
    try {
      var file = await _resolveFile(filePath);

      if (!await file.exists()) {
        return const Left(FileNotFoundFailure(
          message: 'Photo file not found. Please try again.',
        ));
      }

      // Compress the file
      file = await _compressFile(file);

      // Check file size
      if (await file.length() > _maxFileSizeBytes) {
        return const Left(FileTooLargeFailure(
          message: 'Photo is too large. Maximum size is 5MB.',
        ));
      }

      // Check file extension
      final ext = p.extension(file.path).replaceFirst('.', '').toLowerCase();
      if (!_allowedExtensions.contains(ext)) {
        return const Left(InvalidFileFormatFailure(
          message: 'Invalid format. Use JPG, PNG, HEIC, or WEBP.',
        ));
      }

      return Right(file);
    } catch (e) {
      return const Left(FileNotFoundFailure(
        message: 'Photo file not found. Please try again.',
      ));
    }
  }

  /// Resolves the file from a path or content URI (Android only)
  static Future<File> _resolveFile(String path) async {
    if (path.startsWith('content://') && !kIsWeb) {
      final tempDir = Directory.systemTemp;
      final fileName = p.basename(path);
      final tempFile = File('${tempDir.path}/$fileName');

      final byteData = await const MethodChannel('flutter/photo')
          .invokeMethod<ByteData>('readFileBytes', {'uri': path});

      if (byteData == null) {
        throw Exception('Failed to read bytes from content URI');
      }

      await tempFile.writeAsBytes(byteData.buffer.asUint8List());
      return tempFile;
    }

    return File(path);
  }

  /// Compresses the file to reduce size while keeping quality
  static Future<File> _compressFile(File file) async {
    final targetPath =
        '${Directory.systemTemp.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

    final compressedXFile = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 70,
      minWidth: 1080,
      minHeight: 1080,
    );

    return compressedXFile != null ? File(compressedXFile.path) : file;
  }

  /// Returns the MIME type based on the file extension
  static String getContentType(String filePath) {
    final ext = p.extension(filePath).replaceFirst('.', '').toLowerCase();
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'heic':
        return 'image/heic';
      case 'webp':
        return 'image/webp';
      case 'jpg':
      case 'jpeg':
      default:
        return 'image/jpeg';
    }
  }
}