import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failure_handler.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/event_entity.dart';
import '../../domain/usecases/get_events_usecase.dart';

part 'events_event.dart';
part 'events_state.dart';

class EventsBloc extends Bloc<EventsEvent, EventsState> {
  final GetUserEventsUseCase _getUserEventsUseCase;
  final JoinEventUseCase _joinEventUseCase;
  final NetworkInfo _networkInfo;
  final FailureHandler _failureHandler;
  StreamSubscription<bool>? _connectivitySubscription;

  EventsBloc({
    required GetUserEventsUseCase getUserEventsUseCase,
    required JoinEventUseCase joinEventUseCase,
    required NetworkInfo networkInfo,
    FailureHandler? failureHandler,
  }) : _getUserEventsUseCase = getUserEventsUseCase,
       _joinEventUseCase = joinEventUseCase,
       _networkInfo = networkInfo,
       _failureHandler = failureHandler ?? FailureHandler.instance,
       super(EventsInitial()) {
    on<GetUserEventsRequested>(_onGetUserEvents);
    on<JoinEventRequested>(_onJoinEvent);
    on<EventsRetryRequested>(_onEventsRetry);
    _listenToConnectivity();
  }

  void _listenToConnectivity() {
    _connectivitySubscription = _networkInfo.onConnectivityChanged.listen((
      isConnected,
    ) {
      if (isConnected &&
          state is EventsLoaded &&
          (state as EventsLoaded).isOffline) {
        add(GetUserEventsRequested());
      }
      if (isConnected && state is EventsFailure) {
        add(GetUserEventsRequested());
      }
    });
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
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
              message: _failureHandler.getUserFriendlyMessage(failure),
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
    emit(JoinEventLoading());
    final result = await _joinEventUseCase(
      JoinEventParams(eventCode: event.eventCode),
    );
    result.fold(
      (failure) {
        _failureHandler.logFailure(failure, 'EventsBloc');
        emit(
          EventsFailure(
            message: _failureHandler.getUserFriendlyMessage(failure),
          ),
        );
      },
      (_) {
        emit(JoinEventSuccess());
        add(GetUserEventsRequested());
      },
    );
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
              message: _failureHandler.getUserFriendlyMessage(failure),
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
            isRefreshing: false,
          ),
        );
      },
    );
  }
}
