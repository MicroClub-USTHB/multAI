
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/photo_repository.dart';
 
class GetPhotoImageParams {
  final String photoId;
  const GetPhotoImageParams({required this.photoId});
}
 
class GetPhotoImageUseCase extends UseCase<String, GetPhotoImageParams> {
  final PhotoRepository repository;
  GetPhotoImageUseCase(this.repository);
 
  @override
  Future<Either<Failure, String>> call(GetPhotoImageParams params) {
    return repository.getPhotoImage(params.photoId);
  }
}
 