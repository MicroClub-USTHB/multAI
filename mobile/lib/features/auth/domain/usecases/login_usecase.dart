import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';
 
class LoginUseCase extends UseCase<AuthEntity, LoginParams> {
  final AuthRepository repository;
  LoginUseCase(this.repository);
 
  @override
  Future<Either<Failure, AuthEntity>> call(LoginParams params) {
    return repository.login(params);
  }
}
 