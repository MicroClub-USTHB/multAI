import '../../domain/entities/user_entity.dart';
import 'device_model.dart';
import 'session_model.dart';

class MeResponseModel extends UserEntity {
  const MeResponseModel({
    required super.id,
    required super.email,
    required super.devices,
    super.session,
  });

  factory MeResponseModel.fromJson(Map<String, dynamic> json) {
    final devicesList = (json['devices'] as List<dynamic>? ?? [])
        .map((d) => DeviceModel.fromJson(d as Map<String, dynamic>))
        .toList();

    final sessionJson = json['session'] as Map<String, dynamic>?;

    return MeResponseModel(
      id: json['id'] as String,
      email: json['email'] as String,
      devices: devicesList,
      session: sessionJson != null ? SessionModel.fromJson(sessionJson) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'devices': devices.map((d) => (d as DeviceModel).toJson()).toList(),
    'session': session != null ? (session as SessionModel).toJson() : null,
  };
}
