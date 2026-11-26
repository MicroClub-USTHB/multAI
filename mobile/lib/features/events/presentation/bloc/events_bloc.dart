import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/failure_handler.dart';
import '../../../../core/errors/error_presentation.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/event_entity.dart';
import '../../domain/usecases/get_events_usecase.dart';

part 'events_event.dart';
part 'events_state.dart';

class EventsBloc extends Bloc<EventsEvent, EventsState> {
  final GetUserEventsUseCase _getUserEventsUseCase;
  final JoinEventUseCase _joinEventUseCase;
  final ConnectivityService _connectivityService;
  final FailureHandler _failureHandler;
  StreamSubscription<bool>? _connectivitySub;

  EventsBloc({
    required GetUserEventsUseCase getUserEventsUseCase,
    required JoinEventUseCase joinEventUseCase,
    required ConnectivityService connectivityService,
    FailureHandler? failureHandler,
  }) : _getUserEventsUseCase = getUserEventsUseCase,
       _joinEventUseCase = joinEventUseCase,
       _connectivityService = connectivityService,
       _failureHandler = failureHandler ?? FailureHandler.instance,
       super(EventsInitial()) {
    on<GetUserEventsRequested>(_onGetUserEvents);
    on<JoinEventRequested>(_onJoinEvent);
    on<EventsRetryRequested>(_onEventsRetry);
    on<ResetEvents>(_onResetEvents);
    _connectivitySub = _connectivityService.onStatusChanged.listen((online) {
      if (!online) return;
      if (state is EventsFailure ||
          (state is EventsLoaded && (state as EventsLoaded).isOffline)) {
        add(GetUserEventsRequested());
      }
    });
  }

  @override
  Future<void> close() {
    _connectivitySub?.cancel();
    return super.close();
  }

  Future<void> _onGetUserEvents(
    GetUserEventsRequested event,
    Emitter<EventsState> emit,
  ) async {
    if (state is EventsLoaded) {
      final previous = state as EventsLoaded;
      emit(
        EventsLoaded(
          activeEvents: previous.activeEvents,
          archivedEvents: previous.archivedEvents,
          isOffline: previous.isOffline,
          isRefreshing: true,
        ),
      );
    } else {
      emit(EventsLoading());
    }
    final result = await _getUserEventsUseCase(NoParams());
    result.fold(
      (failure) {
        if (failure is NetworkFailure) {
          emit(EventsOffline());
          return;
        }
        _failureHandler.logFailure(failure, 'EventsBloc');
        if (state is EventsLoaded) {
          final previous = state as EventsLoaded;
          emit(
            EventsLoaded(
              activeEvents: previous.activeEvents,
              archivedEvents: previous.archivedEvents,
              isOffline: true,
              isRefreshing: false,
            ),
          );
        } else {
          emit(
            EventsFailure(
              errorPresentation: _failureHandler.getErrorPresentation(failure),
            ),
          );
        }
      },
      (events) {
        final active = events.where((e) => e.status != 'archived').toList();
        final archived = events.where((e) => e.status == 'archived').toList();
        emit(
          EventsLoaded(
            activeEvents: active,
            archivedEvents: archived,
            isOffline: !_connectivityService.isConnected,
            isRefreshing: false,
          ),
        );
      },
    );
  }

  Future<void> _onJoinEvent(
    JoinEventRequested event,
    Emitter<EventsState> emit,
  ) async {
    final previous = state is EventsLoaded ? state as EventsLoaded : null;
    emit(
      JoinEventLoading(
        activeEvents: previous?.activeEvents ?? const [],
        archivedEvents: previous?.archivedEvents ?? const [],
        isOffline: previous?.isOffline ?? false,
        isRefreshing: previous?.isRefreshing ?? false,
      ),
    );
    final result = await _joinEventUseCase(
      JoinEventParams(eventCode: event.eventCode),
    );
    result.fold(
      (failure) {
        _failureHandler.logFailure(failure, 'EventsBloc');
        final current = state is EventsLoaded
            ? state as EventsLoaded
            : previous;
        emit(
          JoinEventFailure(
            errorPresentation: _failureHandler.getErrorPresentation(failure),
            activeEvents: current?.activeEvents ?? const [],
            archivedEvents: current?.archivedEvents ?? const [],
            isOffline: current?.isOffline ?? false,
            isRefreshing: current?.isRefreshing ?? false,
          ),
        );
      },
      (_) {
        emit(
          JoinEventSuccess(
            activeEvents: previous?.activeEvents ?? const [],
            archivedEvents: previous?.archivedEvents ?? const [],
            isOffline: previous?.isOffline ?? false,
            isRefreshing: previous?.isRefreshing ?? false,
          ),
        );
        add(GetUserEventsRequested());
      },
    );
  }

  void _onResetEvents(ResetEvents event, Emitter<EventsState> emit) {
    emit(EventsInitial());
  }

  Future<void> _onEventsRetry(
    EventsRetryRequested event,
    Emitter<EventsState> emit,
  ) async {
    if (state is EventsLoaded) {
      final previous = state as EventsLoaded;
      emit(
        EventsLoaded(
          activeEvents: previous.activeEvents,
          archivedEvents: previous.archivedEvents,
          isOffline: previous.isOffline,
          isRefreshing: true,
        ),
      );
    } else {
      emit(EventsLoading());
    }
    final result = await _getUserEventsUseCase(NoParams());
    result.fold(
      (failure) {
        if (failure is NetworkFailure) {
          emit(EventsOffline());
          return;
        }
        _failureHandler.logFailure(failure, 'EventsBloc');
        if (state is EventsLoaded) {
          final previous = state as EventsLoaded;
          emit(
            EventsLoaded(
              activeEvents: previous.activeEvents,
              archivedEvents: previous.archivedEvents,
              isOffline: true,
              isRefreshing: false,
            ),
          );
        } else {
          emit(
            EventsFailure(
              errorPresentation: _failureHandler.getErrorPresentation(failure),
            ),
          );
        }
      },
      (events) {
        final active = events.where((e) => e.status != 'archived').toList();
        final archived = events.where((e) => e.status == 'archived').toList();
        emit(
          EventsLoaded(
            activeEvents: active,
            archivedEvents: archived,
            isOffline: !_connectivityService.isConnected,
            isRefreshing: false,
          ),
        );
      },
    );
  }
}
