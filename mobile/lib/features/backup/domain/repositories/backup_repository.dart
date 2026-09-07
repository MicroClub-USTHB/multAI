import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';

abstract class BackupRepository {
  Future<Either<Failure, List<String>>> getCachedPhotoPaths();
  Future<Either<Failure, File>> createBackupZip(List<String> photoPaths);
  Future<Either<Failure, int>> getPhotoCount();
}
