import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/photo_entity.dart';
import '../repositories/photo_repository.dart';

class GetEventPhotosParams {
  final String eventId;
  final String sort;
  final int limit;
  final int offset;

  const GetEventPhotosParams({
    required this.eventId,
    this.sort = 'desc',
    this.limit = 50,
    this.offset = 0,
  });
}

class GetEventPhotosUseCase
    extends
        UseCase<({List<PhotoEntity> items, int total}), GetEventPhotosParams> {
  final PhotoRepository repository;
  GetEventPhotosUseCase(this.repository);

  @override
  Future<Either<Failure, ({List<PhotoEntity> items, int total})>> call(
    GetEventPhotosParams params,
  ) {
    return repository.getEventPhotos(
      eventId: params.eventId,
      sort: params.sort,
      limit: params.limit,
      offset: params.offset,
    );
  }
}
