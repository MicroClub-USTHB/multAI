import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/album_entity.dart';

abstract class AlbumRepository {
  Future<Either<Failure, List<AlbumEntity>>> getAlbums();
  Future<Either<Failure, AlbumEntity>> createAlbum(String name);
  Future<Either<Failure, void>> addPhotosToAlbum(
    String albumName,
    List<String> photoPaths,
  );
  Future<Either<Failure, List<String>>> getAlbumPhotos(String albumName);
  Future<Either<Failure, void>> deleteAlbum(String name);
}
