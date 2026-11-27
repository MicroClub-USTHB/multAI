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
      id: json['id']?.toString() ?? '',
      deviceName: json['device_name']?.toString() ?? '',
      deviceType: json['device_type']?.toString() ?? '',
      totpSecret: json['totp_secret']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'device_name': deviceName,
    'device_type': deviceType,
    'totp_secret': totpSecret,
  };
}
