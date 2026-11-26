import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/photo_approval_entity.dart';

abstract class PhotoApprovalRepository {
  Future<Either<Failure, List<PhotoApprovalEntity>>> getApprovals({
    String? status,
    int limit = 50,
    int offset = 0,
  });

  Future<Either<Failure, String>> decide({
    required String photoId,
    required String decision,
  });
}
