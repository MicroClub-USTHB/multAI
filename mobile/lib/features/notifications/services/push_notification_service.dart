import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../auth/utils/device_utils.dart';
import '../../../core/errors/failure.dart';
import '../domain/usecases/register_push_token_usecase.dart';
import '../domain/usecases/revoke_push_token_usecase.dart';
import 'notification_navigation_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  final notification = message.notification;
  if (notification == null) return;

  final localNotifications = FlutterLocalNotificationsPlugin();
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const ios = DarwinInitializationSettings();
  await localNotifications.initialize(
    settings: InitializationSettings(android: android, iOS: ios),
  );

  await localNotifications.show(
    id: message.hashCode,
    title: notification.title,
    body: notification.body,
    notificationDetails: NotificationDetails(
      android: AndroidNotificationDetails(
        'multiai_channel',
        'MultiAi Notifications',
        channelDescription: 'MultiAi push notifications',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    ),
    payload: message.data['type'],
  );
}

class PushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  final RegisterPushTokenUseCase _registerToken;
  final RevokePushTokenUsecase _revokeToken;
  final NotificationNavigationService _navigationService;
  String? _deviceId;
  bool _initialized = false;

  PushNotificationService({
    required RegisterPushTokenUseCase registerToken,
    required RevokePushTokenUsecase revokeToken,
    required NotificationNavigationService navigationService,
  }) : _registerToken = registerToken,
       _revokeToken = revokeToken,
       _navigationService = navigationService;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    if (Platform.isIOS) {
      await _fcm.setAutoInitEnabled(true);
    }

    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );

    await _initLocalNotifications();

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _navigationService.onNotificationTap(message);
    });

    final initial = await _fcm.getInitialMessage();
    if (initial != null) {
      _navigationService.onNotificationTap(initial);
    }

    final deviceData = await DeviceUtils.getDeviceData();
    _deviceId = deviceData.deviceId;
    await registerCurrentToken();

    _fcm.onTokenRefresh.listen((newToken) async {
      await registerCurrentToken(token: newToken);
    });
  }

  Future<void> registerCurrentToken({String? token}) async {
    final String? deviceToken = token ?? await _getFcmToken();
    final deviceId = _deviceId ?? (await DeviceUtils.getDeviceData()).deviceId;
    if (deviceToken == null || deviceToken.isEmpty) return;

    try {
      await _registerToken(
        RegisterPushTokenParams(deviceId: deviceId, token: deviceToken),
      );
    } on Failure {
      // push token registration skipped
    }
  }

  Future<String?> _getFcmToken() async {
    if (Platform.isIOS) {
      await _fcm.getAPNSToken();
    }
    return await _fcm.getToken();
  }

  Future<void> revokeToken() async {
    final deviceId = _deviceId ?? (await DeviceUtils.getDeviceData()).deviceId;

    try {
      await _revokeToken(RevokePushTokenParams(deviceId: deviceId));
    } on Failure {
      // push token revoke skipped
    }
    try {
      await _fcm.deleteToken();
    } catch (_) {}
  }

  Future<void> _onForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await _localNotifications.show(
      id: message.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'multiai_channel',
          'MultiAi Notifications',
          channelDescription: 'MultiAi push notifications',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: message.data['type'],
    );
  }

  Future<void> _initLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();

    await _localNotifications.initialize(
      settings: InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (details) {
        final payload = details.payload;
        if (payload != null) {
          _navigationService.handleDeepLink(
            Uri.parse('/$payload'),
          );
        }
      },
    );

    if (Platform.isAndroid) {
      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          'multiai_channel',
          'MultiAi Notifications',
          description: 'MultiAi push notifications',
          importance: Importance.high,
        ),
      );
    }
  }
}
