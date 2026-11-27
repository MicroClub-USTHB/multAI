import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class ResendOtpUseCase extends UseCase<String, String> {
  final AuthRepository repository;
  ResendOtpUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(String pendingToken) {
    return repository.resendOtp(pendingToken);
  }
}
