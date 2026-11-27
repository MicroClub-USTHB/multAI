import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/face_photo_entity.dart';

abstract class FaceEnrollmentRepository {
  Future<Either<Failure, void>> uploadFacePhotos(List<FacePhotoEntity> photos);

  Future<bool> isEnrollmentDone();

  Future<void> saveEnrollmentDone();
}
