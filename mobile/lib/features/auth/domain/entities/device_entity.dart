import 'package:uuid/uuid.dart';
 
class DeviceEntity {
  final UuidValue id;
  final String deviceName;
  final String deviceType;
  final String? totpSecret;
 
  const DeviceEntity({
    required this.id,
    required this.deviceName,
    required this.deviceType,
    this.totpSecret,
  });
}
 