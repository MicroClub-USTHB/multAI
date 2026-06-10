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

class JoinEventSuccess extends EventsState {}

class EventsFailure extends EventsState {
  final String message;
  EventsFailure({required this.message});
}

class JoinEventLoading extends EventsState {}
