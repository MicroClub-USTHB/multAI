part of 'events_bloc.dart';

abstract class EventsState {}

class EventsInitial extends EventsState {}

class EventsLoading extends EventsState {}

class EventsLoaded extends EventsState {
  final List<EventEntity> activeEvents;
  final List<EventEntity> archivedEvents;

  EventsLoaded({required this.activeEvents, required this.archivedEvents});
}

class JoinEventSuccess extends EventsState {}

class EventsFailure extends EventsState {
  final String message;
  EventsFailure({required this.message});
}

class JoinEventLoading extends EventsState {}
