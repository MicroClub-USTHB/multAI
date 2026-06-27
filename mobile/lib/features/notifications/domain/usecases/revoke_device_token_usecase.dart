import 'dart:async';

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../../services/push_notification_service.dart';

class RevokeDeviceTokenUseCase extends UseCase<void, NoParams> {
  final PushNotificationService _pushNotificationService;

  RevokeDeviceTokenUseCase(this._pushNotificationService);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    try {
      await _pushNotificationService.revokeToken();
      return const Right(null);
    } catch (e) {
      return Left(const ServerFailure('An unexpected error occurred'));
    }
  }
}
