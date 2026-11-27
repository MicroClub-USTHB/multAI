import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/album_repository.dart';

class AddPhotosToAlbumUseCase extends UseCase<void, AddPhotosParams> {
  final AlbumRepository _repository;

  AddPhotosToAlbumUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(AddPhotosParams params) {
    return _repository.addPhotosToAlbum(params.albumName, params.photoPaths);
  }
}

class AddPhotosParams extends Equatable {
  final String albumName;
  final List<String> photoPaths;

  const AddPhotosParams({
    required this.albumName,
    required this.photoPaths,
  });

  @override
  List<Object> get props => [albumName, photoPaths];
}
