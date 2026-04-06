import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/notification_entity.dart';

abstract class NotificationsRepository {
  Future<Either<Failure, List<NotificationEntity>>> getNotifications();
  Future<Either<Failure, List<NotificationEntity>>> markAsRead(
    List<String> notificationIds,
  );  Future<Either<Failure, void>> registerPushToken({
    required String token,
    required String platform,
  });
  Future<Either<Failure, void>> revokePushToken(String token);
}

