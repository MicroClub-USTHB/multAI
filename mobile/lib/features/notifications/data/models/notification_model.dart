import 'dart:convert';
import '../../domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.userId,
    required super.type,
    required super.payload,
    super.readAt,
    required super.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> payloadMap = {};
    final rawPayload = json['payload'];
    if (rawPayload is String) {
      payloadMap = jsonDecode(rawPayload) as Map<String, dynamic>;
    } else if (rawPayload is Map<String, dynamic>) {
      payloadMap = rawPayload;
    }

    return NotificationModel(
      id:       json['id'] as String,
      userId:   json['user_id'] as String,
      type:     NotificationTypeX.fromString(json['type'] as String? ?? ''),
      payload:  payloadMap,
      readAt:   json['read_at'] != null
          ? DateTime.parse(json['read_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'type': type.name,
    'payload': payload,
    'read_at': readAt?.toIso8601String(),
    'created_at': createdAt.toIso8601String(),
  };
}

