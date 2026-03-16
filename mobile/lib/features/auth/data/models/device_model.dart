import 'package:uuid/uuid.dart';
import '../../domain/entities/device_entity.dart';
 
class DeviceModel extends DeviceEntity {
  const DeviceModel({
    required super.id,
    required super.deviceName,
    required super.deviceType,
    super.totpSecret,
  });
 
  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id:         UuidValue.fromString(json['id'] as String),
      deviceName: json['device_name'] as String,
      deviceType: json['device_type'] as String,
      totpSecret: json['totp_secret'] as String?,
    );
  }
 
  Map<String, dynamic> toJson() => {
        'id':          id.uuid,
        'device_name': deviceName,
        'device_type': deviceType,
        'totp_secret': totpSecret,
      };
}
 