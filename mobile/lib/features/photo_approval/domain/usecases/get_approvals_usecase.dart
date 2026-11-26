import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/photo_approval_entity.dart';
import '../repositories/photo_approval_repository.dart';

class GetApprovalsParams {
  final String? status;
  final int limit;
  final int offset;

  const GetApprovalsParams({this.status, this.limit = 50, this.offset = 0});
}

class GetApprovalsUsecase
    extends UseCase<List<PhotoApprovalEntity>, GetApprovalsParams> {
  final PhotoApprovalRepository repository;
  GetApprovalsUsecase({required this.repository});
  @override
  Future<Either<Failure, List<PhotoApprovalEntity>>> call(
    GetApprovalsParams params,
  ) {
    return repository.getApprovals(
      status: params.status,
      limit: params.limit,
      offset: params.offset,
    );
  }
}
