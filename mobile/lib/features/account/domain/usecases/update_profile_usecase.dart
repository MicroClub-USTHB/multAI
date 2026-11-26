import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/account_entity.dart';
import '../repositories/account_repository.dart';

class UpdateProfileParams {
  final String name;
  const UpdateProfileParams({required this.name});
}

class UpdateProfileUseCase extends UseCase<AccountEntity, UpdateProfileParams> {
  final AccountRepository repository;
  UpdateProfileUseCase(this.repository);

  @override
  Future<Either<Failure, AccountEntity>> call(UpdateProfileParams params) {
    return repository.updateProfile(params.name);
  }
}
