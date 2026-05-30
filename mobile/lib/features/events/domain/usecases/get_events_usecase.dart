import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/event_entity.dart';
import '../repositories/event_repository.dart';

class GetUserEventsUseCase extends UseCase<List<EventEntity>, NoParams> {
  final EventRepository repository;
  GetUserEventsUseCase(this.repository);

  @override
  Future<Either<Failure, List<EventEntity>>> call(NoParams params) {
    return repository.getUserEvents();
  }
}

class JoinEventParams {
  final String eventCode;
  const JoinEventParams({required this.eventCode});
}

class JoinEventUseCase extends UseCase<void, JoinEventParams> {
  final EventRepository repository;
  JoinEventUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(JoinEventParams params) {
    return repository.joinEvent(params.eventCode);
  }
}
