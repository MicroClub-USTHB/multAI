import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/photo_approval_entity.dart';
import '../../domain/repositories/photo_approval_repository.dart';
import '../datasources/photo_approval_remote_datasource.dart';

class PhotoApprovalRepositoryImpl implements PhotoApprovalRepository {
  final PhotoApprovalRemoteDataSource remoteDataSource;

  PhotoApprovalRepositoryImpl({required this.remoteDataSource});

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
      return Right(result);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
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
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
