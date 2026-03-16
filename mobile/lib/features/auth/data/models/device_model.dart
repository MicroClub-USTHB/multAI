import 'package:uuid/uuid.dart';
import '../../domain/entities/device_entity.dart';
 
class DeviceModel extends DeviceEntity {
  const DeviceModel({
    required super.id,
    required super.userId,
    required super.deviceName,
    required super.deviceFingerprint,
    required super.platform,
    required super.revoked,
    super.lastSeen,
    required super.createdAt,
  });
 
  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id:                UuidValue.fromString(json['id'] as String),
      userId:            UuidValue.fromString(json['user_id'] as String),
      deviceName:        json['device_name'] as String,
      deviceFingerprint: json['device_fingerprint'] as String,
      platform:          json['platform'] as String,
      revoked:           json['revoked'] as bool,
      lastSeen:          json['last_seen'] != null
          ? DateTime.parse(json['last_seen'] as String)
          : null,
      createdAt:         DateTime.parse(json['created_at'] as String),
    );
  }
 
  Map<String, dynamic> toJson() => {
        'id':                 id.uuid,
        'user_id':            userId.uuid,
        'device_name':        deviceName,
        'device_fingerprint': deviceFingerprint,
        'platform':           platform,
        'revoked':            revoked,
        'last_seen':          lastSeen?.toIso8601String(),
        'created_at':         createdAt.toIso8601String(),
      };
}