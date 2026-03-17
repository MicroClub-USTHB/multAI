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
      sessionId:  json['session_id'] as String,
      deviceId:   json['device_id']  as String,
      lastActive: DateTime.parse(json['last_active'] as String),
      expiresAt:  DateTime.parse(json['expires_at']  as String),
    );
  }
 
  Map<String, dynamic> toJson() => {
        'session_id': sessionId,
        'device_id':  deviceId,
        'last_active': lastActive.toIso8601String(),
        'expires_at':  expiresAt.toIso8601String(),
      };
}
 