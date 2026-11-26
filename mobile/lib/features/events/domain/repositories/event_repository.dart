import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/event_entity.dart';

abstract class EventRepository {
  Future<Either<Failure, List<EventEntity>>> getUserEvents();
  Future<Either<Failure, void>> joinEvent(String eventCode);
}
