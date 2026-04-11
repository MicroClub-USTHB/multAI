import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/photo_approval_repository.dart';

class DecidePhotoParams {
  final String photoId;
  final String decision; // 'approved' | 'rejected'
  const DecidePhotoParams({required this.photoId, required this.decision});
}

class DecidePhotoApprovalUseCase extends UseCase<String, DecidePhotoParams> {
  final PhotoApprovalRepository repository;
  DecidePhotoApprovalUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(DecidePhotoParams params) {
    return repository.decide(
      photoId: params.photoId,
      decision: params.decision,
    );
  }
}
