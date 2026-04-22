import '../../domain/entities/auth_entity.dart';

class AuthRequestModel {
  final String email;
  final String password;
  final String deviceName;
  final String deviceType;
  final String deviceId;

  const AuthRequestModel({
    required this.email,
    required this.password,
    required this.deviceName,
    required this.deviceType,
    required this.deviceId,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'device_name': deviceName,
    'device_type': deviceType,
    'device_id': deviceId,
  };
}

class AuthResponseModel extends AuthEntity {
  const AuthResponseModel({
    required super.accessToken,
    required super.refreshToken,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'access_token': accessToken,
    'refresh_token': refreshToken,
  };
}
