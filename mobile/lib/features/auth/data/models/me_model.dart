import '../../domain/entities/user_entity.dart';
import 'device_model.dart';
import 'session_model.dart';

class MeResponseModel extends UserEntity {
  const MeResponseModel({
    required super.id,
    required super.email,
    required super.devices,
    super.session,
    super.isOnboarded,
  });

  factory MeResponseModel.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] is Map
        ? Map<String, dynamic>.from(json['user'] as Map)
        : json;

    final devicesList = (json['devices'] as List<dynamic>? ?? [])
        .map((d) => DeviceModel.fromJson(d as Map<String, dynamic>))
        .toList();

    final sessionJson =
        json['sessions'] as Map<String, dynamic>? ??
        json['session'] as Map<String, dynamic>?;

    return MeResponseModel(
      id: userJson['id']?.toString() ?? '',
      email: userJson['email']?.toString() ?? '',
      devices: devicesList,
      session: sessionJson != null ? SessionModel.fromJson(sessionJson) : null,
      isOnboarded: userJson['is_onboarded'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'devices': devices.map((d) => (d as DeviceModel).toJson()).toList(),
    'sessions': session != null ? (session as SessionModel).toJson() : null,
    'is_onboarded': isOnboarded,
  };
}
