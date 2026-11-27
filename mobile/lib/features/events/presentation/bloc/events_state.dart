part of 'events_bloc.dart';

abstract class EventsState {}

class EventsInitial extends EventsState {}

class EventsLoading extends EventsState {}

class EventsLoaded extends EventsState {
  final List<EventEntity> activeEvents;
  final List<EventEntity> archivedEvents;
  final bool isOffline;
  final bool isRefreshing;

  EventsLoaded({
    required this.activeEvents,
    required this.archivedEvents,
    this.isOffline = false,
    this.isRefreshing = false,
  });
}

class EventsOffline extends EventsState {
  final List<EventEntity> cachedEvents;

  EventsOffline({this.cachedEvents = const []});
}

class EventsFailure extends EventsState {
  final ErrorPresentation errorPresentation;
  EventsFailure({required this.errorPresentation});
}

// Join flow states extend EventsLoaded so the events list (and the rest of the
// screen) stays visible while joining or when the code is rejected.
class JoinEventLoading extends EventsLoaded {
  JoinEventLoading({
    super.activeEvents = const [],
    super.archivedEvents = const [],
    super.isOffline = false,
    super.isRefreshing = false,
  });
}

class JoinEventSuccess extends EventsLoaded {
  JoinEventSuccess({
    super.activeEvents = const [],
    super.archivedEvents = const [],
    super.isOffline = false,
    super.isRefreshing = false,
  });
}

class JoinEventFailure extends EventsLoaded {
  final ErrorPresentation errorPresentation;

  JoinEventFailure({
    required this.errorPresentation,
    super.activeEvents = const [],
    super.archivedEvents = const [],
    super.isOffline = false,
    super.isRefreshing = false,
  });
}
