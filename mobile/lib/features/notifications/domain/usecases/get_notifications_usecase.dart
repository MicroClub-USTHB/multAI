import 'package:dartz/dartz.dart';
import 'package:multai_mobile/core/usecase/usecase.dart';
import '../../../../core/errors/failure.dart';
import '../entities/notification_entity.dart';
import '../repositories/notifications_repository.dart';

class GetNotificationsUsecase
    extends UseCase<List<NotificationEntity>, NoParams> {
  final NotificationsRepository repository;

  GetNotificationsUsecase(this.repository);

  @override
  Future<Either<Failure, List<NotificationEntity>>> call(NoParams params) {
    return repository.getNotifications();
  }
}
