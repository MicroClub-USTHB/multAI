import 'dart:async';

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/notifications_repository.dart';

class RegisterPushTokenParams {
  final String deviceId;
  final String token;
  const RegisterPushTokenParams({required this.deviceId, required this.token});
}

class RegisterPushTokenUseCase extends UseCase<void, RegisterPushTokenParams> {
  final NotificationsRepository repository;
  RegisterPushTokenUseCase(this.repository);
  @override
  Future<Either<Failure, void>> call(RegisterPushTokenParams params) {
    return repository.registerPushToken(
      deviceId: params.deviceId,
      token: params.token,
    );
  }
}
