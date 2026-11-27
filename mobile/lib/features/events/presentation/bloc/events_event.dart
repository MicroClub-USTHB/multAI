part of 'events_bloc.dart';

abstract class EventsEvent {}

class GetUserEventsRequested extends EventsEvent {}

class JoinEventRequested extends EventsEvent {
  final String eventCode;
  JoinEventRequested({required this.eventCode});
}

class EventsRetryRequested extends EventsEvent {}

class ResetEvents extends EventsEvent {}
