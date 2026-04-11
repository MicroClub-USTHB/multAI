import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/photo_entity.dart';
import '../../domain/repositories/photo_repository.dart';
import '../cache/photo_cache_service.dart';
import '../datasources/photo_remote_datasource.dart';

class PhotoRepositoryImpl implements PhotoRepository {
  final PhotoRemoteDataSource remoteDataSource;
  final PhotoCacheService cacheService;

  PhotoRepositoryImpl({
    required this.remoteDataSource,
    required this.cacheService,
  });

  @override
  Future<Either<Failure, List<PhotoEntity>>> getMyPhotos({
    String? eventId,
    String sort = 'desc',
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final models = await remoteDataSource.getMyPhotos(
        eventId: eventId,
        sort: sort,
        limit: limit,
        offset: offset,
      );
      return Right(models);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ({List<PhotoEntity> items, int total})>>
  getEventPhotos({
    required String eventId,
    String sort = 'desc',
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final result = await remoteDataSource.getEventPhotos(
        eventId: eventId,
        sort: sort,
        limit: limit,
        offset: offset,
      );
      return Right(result);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> getPhotoImage(String photoId) async {
    try {
      // ── 1. check cache first ─────────────────────────────────────────────
      final cached = await cacheService.getCachedPath(photoId);
      if (cached != null) return Right(cached);

      // ── 2. download from backend ─────────────────────────────────────────
      final bytes = await remoteDataSource.getPhotoImageBytes(photoId);

      // ── 3. save to cache ─────────────────────────────────────────────────
      final localPath = await cacheService.saveToCache(photoId, bytes);

      return Right(localPath);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
