import 'dart:async';

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/notifications_repository.dart';

class MarkAllAsReadUsecase extends UseCase<void, NoParams> {
  final NotificationsRepository repository;
  MarkAllAsReadUsecase(this.repository);
  @override
  FutureOr<Either<Failure, void>> call(NoParams params) {
    return repository.markAllAsRead();
  }
}
