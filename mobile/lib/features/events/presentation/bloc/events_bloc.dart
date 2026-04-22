import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/event_entity.dart';
import '../../domain/usecases/get_events_usecase.dart';

part 'events_event.dart';
part 'events_state.dart';

class EventsBloc extends Bloc<EventsEvent, EventsState> {
  final GetUserEventsUseCase _getUserEventsUseCase;
  final JoinEventUseCase _joinEventUseCase;

  EventsBloc({
    required GetUserEventsUseCase getUserEventsUseCase,
    required JoinEventUseCase joinEventUseCase,
  }) : _getUserEventsUseCase = getUserEventsUseCase,
       _joinEventUseCase = joinEventUseCase,
       super(EventsInitial()) {
    on<GetUserEventsRequested>(_onGetUserEvents);
    on<JoinEventRequested>(_onJoinEvent);
  }

  Future<void> _onGetUserEvents(
    GetUserEventsRequested event,
    Emitter<EventsState> emit,
  ) async {
    emit(EventsLoading());
    final result = await _getUserEventsUseCase(NoParams());
    result.fold((failure) => emit(EventsFailure(message: failure.message)), (
      events,
    ) {
      final active = events.where((e) => e.status != 'archived').toList();
      final archived = events.where((e) => e.status == 'archived').toList();
      emit(EventsLoaded(activeEvents: active, archivedEvents: archived));
    });
  }

  Future<void> _onJoinEvent(
    JoinEventRequested event,
    Emitter<EventsState> emit,
  ) async {
    emit(JoinEventLoading());
    final result = await _joinEventUseCase(
      JoinEventParams(eventCode: event.eventCode),
    );
    result.fold((failure) => emit(EventsFailure(message: failure.message)), (
      _,
    ) {
      emit(JoinEventSuccess());
      add(GetUserEventsRequested());
    });
  }
}
