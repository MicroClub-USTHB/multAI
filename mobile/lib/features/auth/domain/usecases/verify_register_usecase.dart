import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

class VerifyRegisterParams {
  final LoginParams loginParams;
  final String otp;

  const VerifyRegisterParams({required this.loginParams, required this.otp});
}

class VerifyRegisterUseCase extends UseCase<AuthEntity, VerifyRegisterParams> {
  final AuthRepository repository;
  VerifyRegisterUseCase(this.repository);

  @override
  Future<Either<Failure, AuthEntity>> call(VerifyRegisterParams params) {
    return repository.verifyRegister(params.loginParams, params.otp);
  }
}
