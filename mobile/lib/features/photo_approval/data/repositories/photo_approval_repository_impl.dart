import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/photo_approval_entity.dart';
import '../../domain/repositories/photo_approval_repository.dart';
import '../datasources/photo_approval_local_datasource.dart';
import '../datasources/photo_approval_remote_datasource.dart';

class PhotoApprovalRepositoryImpl implements PhotoApprovalRepository {
  final PhotoApprovalRemoteDataSource remoteDataSource;
  final PhotoApprovalLocalDataSource localDataSource;

  PhotoApprovalRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<PhotoApprovalEntity>>> getApprovals({
    String? status,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final result = await remoteDataSource.getApprovals(
        status: status,
        limit: limit,
        offset: offset,
      );
      await localDataSource.cacheApprovals(result);
      return Right(result);
    } on Failure catch (f) {
      final cached = await localDataSource.getCachedApprovals();
      if (cached != null && cached.isNotEmpty) return Right(cached);
      return Left(f);
    } catch (e) {
      return Left(const UnknownFailure('Failed to load approvals'));
    }
  }

  @override
  Future<Either<Failure, String>> decide({
    required String photoId,
    required String decision,
  }) async {
    try {
      final result = await remoteDataSource.decide(
        photoId: photoId,
        decision: decision,
      );
      return Right(result);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(const UnknownFailure('Failed to process decision'));
    }
  }
}
