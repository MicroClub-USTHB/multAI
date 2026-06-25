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
  Future<bool> isEnrollmentDone() {
    return localDataSource.isEnrollmentDone();
  }

  @override
  Future<void> saveEnrollmentDone() {
    return localDataSource.saveEnrollmentDone();
  }
}
