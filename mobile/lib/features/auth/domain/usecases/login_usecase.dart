import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase extends UseCase<AuthEntity, LoginParams> {
  final AuthRepository repository;
  LoginUseCase(this.repository);

  bool _isRegister = false;

  LoginUseCase asRegister() {
    _isRegister = true;
    return this;
  }

  @override
  Future<Either<Failure, AuthEntity>> call(LoginParams params) {
    if (_isRegister) {
      return repository.register(params);
    }
    return repository.login(params);
  }

  Future<Either<Failure, AuthEntity>> callWithRegister(LoginParams params, {bool isRegister = false}) {
    if (isRegister) {
      return repository.register(params);
    }
    return repository.login(params);
  }
}
