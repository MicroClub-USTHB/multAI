part of 'notifications_bloc.dart';

abstract class NotificationEvent {}

class LoadNotifications extends NotificationEvent {}

class MarkNotificationRead extends NotificationEvent {
  final String notificationId;
  MarkNotificationRead({required this.notificationId});
}

class MarkAllNotificationsRead extends NotificationEvent {}

class PushTokenReceived extends NotificationEvent {
  final String token;
  final String platform;
  PushTokenReceived({required this.token, required this.platform});
}

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
