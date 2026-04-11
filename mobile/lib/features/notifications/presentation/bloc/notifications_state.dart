part of 'notifications_bloc.dart';

abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<NotificationEntity> notifications;
  final int unreadCount;

  NotificationLoaded({required this.notifications})
    : unreadCount = notifications.where((n) => !n.isRead).length;
}

class NotificationError extends NotificationState {
  final String message;
  NotificationError({required this.message});
}

class NotificationPushReceived extends NotificationState {
  final String title;
  final String body;
  NotificationPushReceived({required this.title, required this.body});
}
