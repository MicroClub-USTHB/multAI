import 'dart:convert';
import '../../domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.type,
    required super.payload,
    super.readAt,
    required super.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> payloadMap = {};
    try {
      final rawPayload = json['payload'];
      if (rawPayload is String) {
        final decoded = jsonDecode(rawPayload);
        if (decoded is Map<String, dynamic>) {
          payloadMap = decoded;
        }
      } else if (rawPayload is Map<String, dynamic>) {
        payloadMap = rawPayload;
      }
    } catch (_) {
      payloadMap = {};
    }

    DateTime parseDate(dynamic value, {DateTime? fallback}) {
      if (value == null || value is! String) return fallback ?? DateTime.now();
      try {
        return DateTime.parse(value);
      } catch (_) {
        return fallback ?? DateTime.now();
      }
    }

    return NotificationModel(
      id: (json['id'] as String?) ?? '',
      type: NotificationTypeX.fromString(json['type'] as String? ?? ''),
      payload: payloadMap,
      readAt: parseDate(json['read_at'], fallback: null),
      createdAt: parseDate(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'payload': payload,
    'read_at': readAt?.toIso8601String(),
    'created_at': createdAt.toIso8601String(),
  };
}
