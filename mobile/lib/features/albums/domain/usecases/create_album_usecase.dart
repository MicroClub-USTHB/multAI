import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/album_entity.dart';
import '../repositories/album_repository.dart';

class CreateAlbumUseCase extends UseCase<AlbumEntity, CreateAlbumParams> {
  final AlbumRepository _repository;

  CreateAlbumUseCase(this._repository);

  @override
  Future<Either<Failure, AlbumEntity>> call(CreateAlbumParams params) {
    return _repository.createAlbum(params.name);
  }
}

class CreateAlbumParams extends Equatable {
  final String name;

  const CreateAlbumParams({required this.name});

  @override
  List<Object> get props => [name];
}
