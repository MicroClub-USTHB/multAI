import '../../../../core/network/api_client.dart';
import '../../../../core/constants/end_points.dart';
import '../models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications();
  Future<List<NotificationModel>> markAsRead(List<String> notificationIds);
  Future<void> registerPushToken({
    required String token,
    required String platform,
  });
  Future<void> revokePushToken(String token);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final ApiClient apiClient;
  NotificationRemoteDataSourceImpl({required this.apiClient});
  @override
  Future<List<NotificationModel>> getNotifications() async {
    final json = await apiClient.get(EndPoints.notifications);
    return _parseList(json);
  }

  @override
  Future<List<NotificationModel>> markAsRead(List<String> notificationIds) async {
    final json = await apiClient.post(
      EndPoints.notificationsReads,
      body: {'notification_ids' : notificationIds},
      requiresAuth: true,
    );
    return  _parseList(json);
  }

  @override
  Future<void> registerPushToken({
    required String token,
    required String platform,
  }) async {
    await apiClient.post(
      EndPoints.registerPushToken,
      body: {'token': token, 'platform': platform},
      requiresAuth: true,
    );
  }

  @override
  Future<void> revokePushToken(String token) async {
    await apiClient.post(
      EndPoints.revokePushToken,
      body: {'token': token},
      requiresAuth: true,
    );
  }
   List<NotificationModel> _parseList(Map<String, dynamic> json) {
    final list = json['notifications'] as List<dynamic>? ?? [];
    return list
        .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
