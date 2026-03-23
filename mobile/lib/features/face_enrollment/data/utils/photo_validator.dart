import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
 
/// Validates a photo file before upload.
/// Checks: existence, size, format.
class PhotoValidator {
  static const int _maxFileSizeBytes = 5 * 1024 * 1024; // 5MB
  static const List<String> _allowedExtensions = ['jpg', 'jpeg', 'png'];
 
  static Future<Either<Failure, File>> validate(String filePath) async {
    final file = File(filePath);
 
    // ── 1. file exists ─────────────────────────────────────────────────────
    if (!await file.exists()) {
      return const Left(
        FileNotFoundFailure(message: 'Photo file not found. Please try again.'),
      );
    }
 
    // ── 2. file size ───────────────────────────────────────────────────────
    final size = await file.length();
    if (size > _maxFileSizeBytes) {
      return const Left(
        FileTooLargeFailure(message: 'Photo is too large. Maximum size is 5MB.'),
      );
    }
 
    // ── 3. file format ─────────────────────────────────────────────────────
    final ext = filePath.split('.').last.toLowerCase();
    if (!_allowedExtensions.contains(ext)) {
      return const Left(
        InvalidFileFormatFailure(
          message: 'Invalid format. Use JPG or PNG photos.',
        ),
      );
    }
 
    return Right(file);
  }
 
  /// Returns content type based on file extension.
  static String getContentType(String filePath) {
    final ext = filePath.split('.').last.toLowerCase();
    switch (ext) {
      case 'png':
        return 'png';
      case 'jpg':
      case 'jpeg':
      default:
        return 'jpeg';
    }
  }
}