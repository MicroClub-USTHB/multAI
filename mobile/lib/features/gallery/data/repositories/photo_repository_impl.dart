import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/photo_entity.dart';
import '../../domain/repositories/photo_repository.dart';
import '../cache/photo_cache_service.dart';
import '../datasources/photo_local_datasource.dart';
import '../datasources/photo_remote_datasource.dart';

class PhotoRepositoryImpl implements PhotoRepository {
  final PhotoRemoteDataSource remoteDataSource;
  final PhotoCacheService cacheService;
  final PhotoLocalDataSource localDataSource;

  PhotoRepositoryImpl({
    required this.remoteDataSource,
    required this.cacheService,
    required this.localDataSource,
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
      await localDataSource.cacheAllPhotos(models);
      return Right(models);
    } on NetworkFailure catch (_) {
      final cached = localDataSource.getCachedAllPhotos();
      if (cached != null && cached.isNotEmpty) return Right(cached);
      return Left(const NetworkFailure('No internet connection'));
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(const UnknownFailure('Failed to load photos'));
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
      await localDataSource.cacheEventPhotos(
        eventId,
        result.items,
        result.total,
      );
      return Right((items: result.items, total: result.total));
    } on NetworkFailure catch (_) {
      final cached = localDataSource.getCachedEventPhotos(eventId);
      if (cached != null && cached.items.isNotEmpty) return Right(cached);
      return Left(const NetworkFailure('No internet connection'));
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(const UnknownFailure('Failed to load event photos'));
    }
  }

  @override
  Future<Either<Failure, String>> getPhotoImage(String photoId) async {
    try {
      final cached = await cacheService.getCachedPath(photoId);
      if (cached != null) return Right(cached);

      final bytes = await remoteDataSource.getPhotoImageBytes(photoId);

      final localPath = await cacheService.saveToCache(photoId, bytes);

      return Right(localPath);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(const UnknownFailure('Failed to load photo'));
    }
  }
}
