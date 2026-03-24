import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:path/path.dart' as p;
import '../../../core/errors/failure.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Validates a photo file before upload.
class PhotoValidator {
  static const int _maxFileSizeBytes = 5 * 1024 * 1024; // 5MB
  static const List<String> _allowedExtensions = [
    'jpg',
    'jpeg',
    'png',
    'heic',
    'webp'
  ];

  /// Validates a file path or content URI.
  static Future<Either<Failure, File>> validate(String filePath) async {
    File file;

    try {
      file = await _resolveFile(filePath);
    } catch (e) {
      return const Left(
        FileNotFoundFailure(
            message: 'Photo file not found. Please try again.'),
      );
    }

    // ── 1. file exists ───────────────────────────────────────────────
    if (!await file.exists()) {
      return const Left(
        FileNotFoundFailure(
            message: 'Photo file not found. Please try again.'),
      );
    }

    // ── 2. file size ───────────────────────────────────────────────
    final size = await file.length();
    if (size > _maxFileSizeBytes) {
      return const Left(
        FileTooLargeFailure(message: 'Photo is too large. Maximum size is 5MB.'),
      );
    }

    // ── 3. file format ─────────────────────────────────────────────
    final ext = p.extension(file.path).replaceFirst('.', '').toLowerCase();
    if (!_allowedExtensions.contains(ext)) {
      return const Left(
        InvalidFileFormatFailure(
            message: 'Invalid format. Use JPG, PNG, HEIC, or WEBP photos.'),
      );
    }

    return Right(file);
  }

  /// Resolves content URIs or direct file paths into File objects
  static Future<File> _resolveFile(String path) async {
    if (path.startsWith('content://') && !kIsWeb) {
      // Android content URI → copy to temp file
      final tempDir = Directory.systemTemp;
      final fileName = path.split('/').last;
      final tempFile = File('${tempDir.path}/$fileName');
      final byteData = await MethodChannel('flutter/photo')
          .invokeMethod<ByteData>('readFileBytes', {'uri': path});
      await tempFile.writeAsBytes(byteData!.buffer.asUint8List());
      return tempFile;
    }
    // iOS PH:// or normal path → direct
    return File(path);
  }

  /// Returns content type based on file extension.
  static String getContentType(String filePath) {
    final ext = p.extension(filePath).replaceFirst('.', '').toLowerCase();
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'heic':
        return 'image/heic';
      case 'webp':
        return 'image/webp';
      default:
        return 'application/octet-stream';
    }
  }
}