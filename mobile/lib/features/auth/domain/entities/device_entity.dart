import 'package:uuid/uuid.dart';
 
class DeviceEntity {
  final UuidValue id;
  final UuidValue userId;
  final String deviceName;
  final String deviceFingerprint;
  final String platform;
  final bool revoked;
  final DateTime? lastSeen;
  final DateTime createdAt;
 
  const DeviceEntity({
    required this.id,
    required this.userId,
    required this.deviceName,
    required this.deviceFingerprint,
    required this.platform,
    required this.revoked,
    this.lastSeen,
    required this.createdAt,
  });
}
 