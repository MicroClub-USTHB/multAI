import 'dart:convert';
import '../../../../core/storage/app_local_storage.dart';
import '../../domain/entities/notification_entity.dart';
import '../models/notification_model.dart';

class NotificationsLocalDataSource {
  final AppLocalStorage localStorage;

  NotificationsLocalDataSource({required this.localStorage});

  static const _cacheKey = 'cached_notifications';

  Future<void> cacheNotifications(
    List<NotificationEntity> notifications,
  ) async {
    final jsonList = notifications
        .map(
          (e) => NotificationModel(
            id: e.id,
            type: e.type,
            payload: e.payload,
            readAt: e.readAt,
            createdAt: e.createdAt,
          ).toJson(),
        )
        .toList();
    await localStorage.setString(
      _cacheKey,
      jsonEncode({'notifications': jsonList}),
    );
  }

  List<NotificationEntity>? getCachedNotifications() {
    final raw = localStorage.getString(_cacheKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final list = json['notifications'] as List<dynamic>?;
      if (list == null || list.isEmpty) return null;
      return list
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> clearCache() async {
    await localStorage.remove(_cacheKey);
  }
}
