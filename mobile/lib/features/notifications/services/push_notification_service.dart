// lib/features/notifications/services/push_notification_service.dart
// Handles FCM (Android) and APN (iOS) token management + foreground messages

import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../auth/utils/device_utils.dart';
import '../../../core/errors/failure.dart';
import '../domain/usecases/register_push_token_usecase.dart';
import '../domain/usecases/revoke_push_token_usecase.dart';

// ── Background message handler — must be top-level ────────────────────────────
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // background handler — no-op
}

class PushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  final RegisterPushTokenUseCase _registerToken;
  final RevokePushTokenUsecase _revokeToken;
  String? _deviceId;

  // callback when notification tapped
  final void Function(RemoteMessage)? onNotificationTap;

  PushNotificationService({
    required RegisterPushTokenUseCase registerToken,
    required RevokePushTokenUsecase revokeToken,
    this.onNotificationTap,
  }) : _registerToken = registerToken,
       _revokeToken = revokeToken;

  // ── Initialize ─────────────────────────────────────────────────────────────
  Future<void> init() async {
    // ── 1. request permission ──────────────────────────────────────────────
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );

    // ── 2. setup local notifications (for foreground) ──────────────────────
    await _initLocalNotifications();

    // ── 3. register background handler ────────────────────────────────────
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // ── 4. handle foreground messages ─────────────────────────────────────
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // ── 5. handle notification tap when app in background ─────────────────
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      onNotificationTap?.call(message);
    });

    // ── 6. handle notification tap when app was terminated ────────────────
    final initial = await _fcm.getInitialMessage();
    if (initial != null) {
      onNotificationTap?.call(initial);
    }

    // ── 7. get and register token ──────────────────────────────────────────
    final deviceData = await DeviceUtils.getDeviceData();
    _deviceId = deviceData.deviceId;
    await _registerDeviceToken();

    // ── 8. listen for token refresh ───────────────────────────────────────
    _fcm.onTokenRefresh.listen((newToken) async {
      await _registerDeviceToken(token: newToken);
    });
  }

  // ── Register device token to backend ──────────────────────────────────────
  Future<void> _registerDeviceToken({String? token}) async {
    final String? deviceToken = token ?? await _getToken();
    final deviceId = _deviceId ?? (await DeviceUtils.getDeviceData()).deviceId;
    if (deviceToken == null || deviceToken.isEmpty) return;

    try {
      await _registerToken(
        RegisterPushTokenParams(deviceId: deviceId, token: deviceToken),
      );
    } on Failure catch (failure) {
      // push token registration skipped
    }
  }

  // ── Get FCM token (Android) or APN token (iOS) ────────────────────────────
  Future<String?> _getToken() async {
    if (Platform.isIOS) {
      await _fcm.getAPNSToken();
    }
    return await _fcm.getToken();
  }

  // ── Revoke token on logout ────────────────────────────────────────────────
  Future<void> revokeToken() async {
    final deviceId = _deviceId ?? (await DeviceUtils.getDeviceData()).deviceId;

    try {
      await _revokeToken(RevokePushTokenParams(deviceId: deviceId));
    } on Failure {
      // push token revoke skipped
    } finally {
      await _fcm.deleteToken();
    }
  }

  // ── Handle foreground message ──────────────────────────────────────────────
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
    );
  }

  // ── Init local notifications ───────────────────────────────────────────────
  Future<void> _initLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();

    await _localNotifications.initialize(
      settings: InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (details) {
        // notification tapped
      },
    );

    // create Android notification channel
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
