import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

class RefreshTokenParams {
  final String refreshToken;
  const RefreshTokenParams({required this.refreshToken});
}

class RefreshTokenUseCase extends UseCase<AuthEntity, RefreshTokenParams> {
  final AuthRepository repository;
  RefreshTokenUseCase(this.repository);

  @override
  Future<Either<Failure, AuthEntity>> call(RefreshTokenParams params) {
    return repository.refreshToken(params.refreshToken);
  }
}
