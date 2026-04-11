import 'package:dartz/dartz.dart';
import 'package:multai_mobile/core/errors/failure.dart';
import 'package:multai_mobile/core/usecase/usecase.dart';
import 'package:multai_mobile/features/notifications/domain/entities/notification_entity.dart';
import '../repositories/notifications_repository.dart';

class MarkAsReadParams {
  final List<String> notificationId;
  const MarkAsReadParams({required this.notificationId});
}

class MarkAsReadUsecase extends UseCase<void, MarkAsReadParams> {
  final NotificationsRepository repository;
  MarkAsReadUsecase(this.repository);
  @override
  Future<Either<Failure,List<NotificationEntity>>> call(MarkAsReadParams params) {
    return repository.markAsRead(params.notificationId);
  }
}
