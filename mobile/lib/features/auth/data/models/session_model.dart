import '../../domain/entities/session_entity.dart';

class SessionModel extends SessionEntity {
  const SessionModel({
    required super.sessionId,
    required super.deviceId,
    required super.lastActive,
    required super.expiresAt,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      sessionId: json['session_id']?.toString() ?? '',
      deviceId: json['device_id']?.toString() ?? '',
      lastActive: _parseDate(json['last_active']),
      expiresAt: _parseDate(json['expires_at']),
    );
  }

  static DateTime _parseDate(dynamic value) {
    final raw = value?.toString();
    if (raw == null || raw.isEmpty) {
      return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    }
    return DateTime.parse(raw);
  }

  Map<String, dynamic> toJson() => {
    'session_id': sessionId,
    'device_id': deviceId,
    'last_active': lastActive.toIso8601String(),
    'expires_at': expiresAt.toIso8601String(),
  };
}
