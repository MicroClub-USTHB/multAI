import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/face_photo_entity.dart';
import '../repositories/face_enrollment_repository.dart';
 
class UploadFacePhotosParams {
  final List<FacePhotoEntity> photos;
  const UploadFacePhotosParams({required this.photos});
}
 
class UploadFacePhotosUseCase
    extends UseCase<void, UploadFacePhotosParams> {
  final FaceEnrollmentRepository repository;
 
  UploadFacePhotosUseCase(this.repository);
 
  @override
  Future<Either<Failure, void>> call(UploadFacePhotosParams params) {
    return repository.uploadFacePhotos(params.photos);
  }
}
 