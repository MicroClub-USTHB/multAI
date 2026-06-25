part of 'notifications_bloc.dart';

abstract class NotificationEvent {}

class LoadNotifications extends NotificationEvent {}

class MarkNotificationRead extends NotificationEvent {
  final List<String> notificationIds;
  MarkNotificationRead({required this.notificationIds});
}

class MarkSingleNotificationRead extends NotificationEvent {
  final String notificationId;
  MarkSingleNotificationRead({required this.notificationId});
}

class MarkAllNotificationsRead extends NotificationEvent {}

class PushNotificationReceived extends NotificationEvent {
  final String title;
  final String body;
  final Map<String, dynamic> data;
  PushNotificationReceived({
    required this.title,
    required this.body,
    required this.data,
  });
}
