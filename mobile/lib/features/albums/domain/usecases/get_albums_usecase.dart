import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/album_entity.dart';
import '../repositories/album_repository.dart';

class GetAlbumsUseCase extends UseCase<List<AlbumEntity>, NoParams> {
  final AlbumRepository _repository;

  GetAlbumsUseCase(this._repository);

  @override
  Future<Either<Failure, List<AlbumEntity>>> call(NoParams params) {
    return _repository.getAlbums();
  }
}
