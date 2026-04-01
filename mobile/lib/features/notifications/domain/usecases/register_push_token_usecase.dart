import 'dart:async';

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/notifications_repository.dart';

class RegisterPushTokenParams {
  final String token;
  final String platform;
  const RegisterPushTokenParams({required this.token, required this.platform});
}

class RegisterPushTokenUseCase extends UseCase<void, RegisterPushTokenParams> {
  final NotificationsRepository repository;
  RegisterPushTokenUseCase(this.repository);
  @override
  FutureOr<Either<Failure, void>> call(RegisterPushTokenParams params) {
    return repository.registerPushToken(token: params.token, platform: params.platform);
  }
}
