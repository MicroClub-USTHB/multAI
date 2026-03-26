import 'package:dartz/dartz.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/errors/failure.dart';
import '../repositories/account_repository.dart';
import '../entities/account_entity.dart';

class GetAccountDataUseCase implements UseCase<AccountEntity, NoParams> {
  final AccountRepository repository;

  GetAccountDataUseCase(this.repository);

  @override
  Future<Either<Failure, AccountEntity>> call(NoParams params) {
    return repository.getAccountData();
  }
}
