import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/event_entity.dart';
import '../../domain/repositories/event_repository.dart';
import '../datasources/events_local_datasource.dart';
import '../datasources/events_remote_datasource.dart';

class EventsRepositoryImpl implements EventRepository {
  final EventsRemoteDataSource remoteDataSource;
  final EventsLocalDataSource localDataSource;

  EventsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<EventEntity>>> getUserEvents() async {
    try {
      final models = await remoteDataSource.getUserEvents();
      await localDataSource.cacheEvents(models);
      return Right(models.map((m) => m.toEntity()).toList());
    } on Failure {
      final cached = await localDataSource.getCachedEvents();
      if (cached != null && cached.isNotEmpty) {
        return Right(cached.map((m) => m.toEntity()).toList());
      }
      return Left(const NetworkFailure('No internet connection'));
    } catch (e) {
      return Left(const UnknownFailure('Failed to load events'));
    }
  }

  @override
  Future<Either<Failure, void>> joinEvent(String eventCode) async {
    try {
      await remoteDataSource.joinEvent(eventCode);
      return const Right(null);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(const UnknownFailure('Failed to join event'));
    }
  }
}
