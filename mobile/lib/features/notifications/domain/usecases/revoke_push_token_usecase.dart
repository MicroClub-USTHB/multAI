import 'dart:async';

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/notifications_repository.dart';

class RevokePushTokenParams {
  final String token;
  const RevokePushTokenParams({required this.token});
}

class RevokePushTokenUsecase extends UseCase<void, RevokePushTokenParams> {
  final NotificationsRepository repository;
  RevokePushTokenUsecase(this.repository);
  @override
  Future<Either<Failure, void>> call(RevokePushTokenParams params) {
    return repository.revokePushToken(params.token);
  }
}
