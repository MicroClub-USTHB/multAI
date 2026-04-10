import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/photo_entity.dart';

abstract class PhotoRepository {
  
  Future<Either<Failure, List<PhotoEntity>>> getMyPhotos({
    String? eventId,
    String sort = 'desc',
    int limit = 50,
    int offset = 0,
  });

  Future<Either<Failure, ({List<PhotoEntity> items, int total})>>
  getEventPhotos({
    required String eventId,
    String sort = 'desc',
    int limit = 50,
    int offset = 0,
  });


  Future<Either<Failure, String>> getPhotoImage(String photoId);
}
