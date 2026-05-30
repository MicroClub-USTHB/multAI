import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../datasources/notifications_remote_datasource.dart';

class NotificationRepositoryImpl implements NotificationsRepository {
  final NotificationRemoteDataSource remoteDataSource;
  NotificationRepositoryImpl({required this.remoteDataSource});
  @override
  Future<Either<Failure, List<NotificationEntity>>> getNotifications() async {
    try {
      final r = await remoteDataSource.getNotifications();
      return Right(r);
    } on Failure catch (F) {
      return Left(F);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<NotificationEntity>>> markAsRead(
    List<String> notificationIds,
  ) async {
    try {
      final r = await remoteDataSource.markAsRead(notificationIds);
      return Right(r);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> registerPushToken({
    required String deviceId,
    required String token,
  }) async {
    try {
      await remoteDataSource.registerPushToken(
        deviceId: deviceId,
        token: token,
      );
      return Right(null);
    } on Failure catch (F) {
      return Left(F);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> revokePushToken(String deviceId) async {
    try {
      await remoteDataSource.revokePushToken(deviceId);
      return Right(null);
    } on Failure catch (F) {
      return Left(F);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
