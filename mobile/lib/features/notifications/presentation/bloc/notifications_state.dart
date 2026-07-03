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

class NotificationOffline extends NotificationState {
  final List<NotificationEntity> cachedNotifications;

  NotificationOffline({this.cachedNotifications = const []});
}

class NotificationError extends NotificationState {
  final ErrorPresentation errorPresentation;
  NotificationError({required this.errorPresentation});
}

class NotificationPushReceived extends NotificationState {
  final String title;
  final String body;
  NotificationPushReceived({required this.title, required this.body});
}
