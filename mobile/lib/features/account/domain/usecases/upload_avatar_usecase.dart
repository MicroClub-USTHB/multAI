import 'package:dartz/dartz.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/errors/failure.dart';
import '../repositories/account_repository.dart';

class UploadAvatarUseCase implements UseCase<String, UploadAvatarParams> {
  final AccountRepository repository;

  UploadAvatarUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(UploadAvatarParams params) {
    return repository.uploadAvatar(params.filePath);
  }
}

class UploadAvatarParams {
  final String filePath;

  const UploadAvatarParams({required this.filePath});
}
