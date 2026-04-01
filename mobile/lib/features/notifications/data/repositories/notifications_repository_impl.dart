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
  Future<Either<Failure, void>> markAsRead(String notificationId) async {
    try {
      await remoteDataSource.markAsRead(notificationId);
      return const Right(null);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAllAsRead() async {
    try {
      await remoteDataSource.markAllAsRead();
      return Right(null);
    } on Failure catch (F) {
      return Left(F);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> registerPushToken({
    required String token,
    required String platform,
  }) async {
    try {
      await remoteDataSource.registerPushToken(
        token: token,
        platform: platform,
      );
      return Right(null);
    } on Failure catch (F) {
      return Left(F);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> revokePushToken(String token) async {
    try {
      await remoteDataSource.revokePushToken(token);
      return Right(null);
    } on Failure catch (F) {
      return Left(F);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
