import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/photo_entity.dart';
import '../repositories/photo_repository.dart';

class GetMyPhotosParams {
  final String? eventId;
  final String sort;
  final int limit;
  final int offset;

  const GetMyPhotosParams({
    this.eventId,
    this.sort = 'desc',
    this.limit = 50,
    this.offset = 0,
  });
}

class GetMyPhotosUseCase extends UseCase<List<PhotoEntity>, GetMyPhotosParams> {
  final PhotoRepository repository;
  GetMyPhotosUseCase(this.repository);

  @override
  Future<Either<Failure, List<PhotoEntity>>> call(GetMyPhotosParams params) {
    return repository.getMyPhotos(
      eventId: params.eventId,
      sort: params.sort,
      limit: params.limit,
      offset: params.offset,
    );
  }
}
