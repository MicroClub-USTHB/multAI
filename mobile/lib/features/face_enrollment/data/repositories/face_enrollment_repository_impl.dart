import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/face_photo_entity.dart';
import '../../domain/repositories/face_enrollment_repository.dart';
import '../datasources/face_enrollment_local_datasource.dart';
import '../datasources/face_enrollment_remote_datasource.dart';
import '../models/face_photo_model.dart';

class FaceEnrollmentRepositoryImpl implements FaceEnrollmentRepository {
  final FaceEnrollmentRemoteDataSource remoteDataSource;
  final FaceEnrollmentLocalDataSource localDataSource;

  FaceEnrollmentRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, void>> uploadFacePhotos(
    List<FacePhotoEntity> photos,
  ) async {
    try {
      final models = photos
          .map((p) => FacePhotoModel(type: p.type, filePath: p.filePath))
          .toList();

      await remoteDataSource.uploadFacePhotos(models);
      return const Right(null);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(const UnknownFailure('Failed to upload photos'));
    }
  }

  @override
  Future<bool> isEnrollmentDone() async {
    // Fast path: this account already completed enrollment on this device.
    if (await localDataSource.isEnrollmentDone()) return true;

    // The device flag is cleared on logout, but enrollment belongs to the
    // account (it can have been completed on another device, before a
    // reinstall, or by a different account on this device previously). Ask the
    // backend, which reports it as `is_onboarded` on GET /user/auth/me, and
    // cache a positive answer locally.
    try {
      final enrolled = await remoteDataSource.isEnrollmentDoneOnServer();
      if (enrolled) {
        // Caching is an optimisation only; never let a storage error change the
        // answer we got from the server.
        try {
          await localDataSource.saveEnrollmentDone();
        } catch (_) {}
      }
      return enrolled;
    } on Failure {
      // Offline or the request failed: fall back to what this device knows.
      return false;
    }
  }

  @override
  Future<void> saveEnrollmentDone() {
    return localDataSource.saveEnrollmentDone();
  }
}
