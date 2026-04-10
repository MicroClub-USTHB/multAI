import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/event_entity.dart';
import '../../domain/repositories/event_repository.dart';
import '../datasources/events_remote_datasource.dart';

class EventsRepositoryImpl implements EventRepository {
  final EventsRemoteDataSource remoteDataSource;

  EventsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<EventEntity>>> getUserEvents() async {
    try {
      final models = await remoteDataSource.getUserEvents();
      return Right(models.map((m) => m.toEntity()).toList());
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
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
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
