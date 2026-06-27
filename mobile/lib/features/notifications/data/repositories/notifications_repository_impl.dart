import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../datasources/notifications_local_datasource.dart';
import '../datasources/notifications_remote_datasource.dart';

class NotificationRepositoryImpl implements NotificationsRepository {
  final NotificationRemoteDataSource remoteDataSource;
  final NotificationsLocalDataSource localDataSource;

  NotificationRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<NotificationEntity>>> getNotifications() async {
    try {
      final r = await remoteDataSource.getNotifications();
      await localDataSource.cacheNotifications(r);
      return Right(r);
    } on NetworkFailure catch (_) {
      final cached = localDataSource.getCachedNotifications();
      if (cached != null && cached.isNotEmpty) return Right(cached);
      return Left(const NetworkFailure('No internet connection'));
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(const ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, List<NotificationEntity>>> markAsRead(
    List<String> notificationIds,
  ) async {
    try {
      final r = await remoteDataSource.markAsRead(notificationIds);
      final cached = localDataSource.getCachedNotifications();
      if (cached != null) {
        final updated = cached.map((n) {
          if (notificationIds.contains(n.id)) {
            return NotificationEntity(
              id: n.id,
              type: n.type,
              payload: n.payload,
              readAt: DateTime.now(),
              createdAt: n.createdAt,
            );
          }
          return n;
        }).toList();
        await localDataSource.cacheNotifications(updated);
      }
      return Right(r);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(const ServerFailure('An unexpected error occurred'));
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
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(const ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, void>> revokePushToken(String deviceId) async {
    try {
      await remoteDataSource.revokePushToken(deviceId);
      return Right(null);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(const ServerFailure('An unexpected error occurred'));
    }
  }
}
