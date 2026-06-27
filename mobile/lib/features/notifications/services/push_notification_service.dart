import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../auth/utils/device_utils.dart';
import '../../../core/errors/failure.dart';
import '../domain/usecases/register_push_token_usecase.dart';
import '../domain/usecases/revoke_push_token_usecase.dart';
import 'notification_navigation_service.dart';

final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background message: ${message.messageId}');
  final notification = message.notification;
  if (notification == null) return;

  await _localNotificationsPlugin.initialize(
    settings: const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    ),
  );

  await _localNotificationsPlugin.show(
    id: message.messageId.hashCode,
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
    payload: jsonEncode(message.data),
  );
}

class PushNotificationService {
  FirebaseMessaging? _fcm;
  final RegisterPushTokenUseCase _registerToken;
  final RevokePushTokenUsecase _revokeToken;
  final NotificationNavigationService _navigationService;
  String? _deviceId;
  bool _initialized = false;
  StreamSubscription<String>? _tokenRefreshSub;

  final StreamController<void> _arrivedController =
      StreamController<void>.broadcast();
  Stream<void> get onNotificationArrived => _arrivedController.stream;

  PushNotificationService({
    required RegisterPushTokenUseCase registerToken,
    required RevokePushTokenUsecase revokeToken,
    required NotificationNavigationService navigationService,
    FirebaseMessaging? fcm,
  }) : _registerToken = registerToken,
       _revokeToken = revokeToken,
       _navigationService = navigationService,
       _fcm = fcm;

  static bool get _firebaseReady => Firebase.apps.isNotEmpty;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    if (!_firebaseReady) return;
    _fcm ??= FirebaseMessaging.instance;

    if (Platform.isIOS) {
      await _fcm!.setAutoInitEnabled(true);
    }

    try {
      await _fcm!.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
      );
    } catch (e) {
      debugPrint('Push permission request failed: $e');
    }

    await _initLocalNotifications();

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _navigationService.onNotificationTap(message);
    });

    final initial = await _fcm!.getInitialMessage();
    if (initial != null) {
      _navigationService.onNotificationTap(initial);
    }

    final deviceData = await DeviceUtils.getDeviceData();
    _deviceId = deviceData.deviceId;
    await registerCurrentToken();

    _tokenRefreshSub?.cancel();
    _tokenRefreshSub = _fcm!.onTokenRefresh.listen((newToken) async {
      await registerCurrentToken(token: newToken);
    });
  }

  Future<void> registerAfterLogin() async {
    if (!_firebaseReady) return;

    final deviceData = await DeviceUtils.getDeviceData();
    _deviceId = deviceData.deviceId;
    await registerCurrentToken();
  }

  Future<void> registerCurrentToken({String? token}) async {
    final String? deviceToken = token ?? await _getToken();
    final deviceId = _deviceId ?? (await DeviceUtils.getDeviceData()).deviceId;
    if (deviceToken == null || deviceToken.isEmpty) return;

    _deviceId = deviceId;

    try {
      await _registerToken(
        RegisterPushTokenParams(deviceId: deviceId, token: deviceToken),
      );
      debugPrint('Push token registered [$deviceId]: $deviceToken');
    } on Failure catch (failure) {
      debugPrint('Push token registration skipped: ${failure.message}');
    }
  }

  Future<String?> _getToken() async {
    if (_fcm == null) return null;
    if (Platform.isIOS) {
      await _fcm!.getAPNSToken();
    }
    return await _fcm!.getToken();
  }

  Future<void> revokeToken() async {
    final deviceId = _deviceId ?? (await DeviceUtils.getDeviceData()).deviceId;

    try {
      await _revokeToken(RevokePushTokenParams(deviceId: deviceId));
    } on Failure {
      // push token revoke skipped
    } finally {
      if (_fcm != null) {
        try {
          await _fcm!.deleteToken();
        } catch (_) {
          debugPrint('FCM deleteToken skipped');
        }
      }
    }
  }

  Future<void> _onForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await _localNotificationsPlugin.show(
      id: message.messageId.hashCode,
      title: notification.title,
      body: notification.body,
      payload: jsonEncode(message.data),
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
    );

    _arrivedController.add(null);
  }

  Future<void> _initLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();

    await _localNotificationsPlugin.initialize(
      settings: InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (details) {
        if (details.payload == null || details.payload!.isEmpty) return;
        try {
          final decoded = jsonDecode(details.payload!);
          if (decoded is Map<String, dynamic>) {
            _navigationService.handleDataTap(decoded.cast<String, String>());
          }
        } catch (_) {
          debugPrint('Failed to decode notification payload');
        }
      },
    );

    if (Platform.isAndroid) {
      final androidPlugin = _localNotificationsPlugin
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

  void dispose() {
    _tokenRefreshSub?.cancel();
    _arrivedController.close();
  }
}
