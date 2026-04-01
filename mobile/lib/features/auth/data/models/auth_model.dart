import '../../domain/entities/auth_entity.dart';

class AuthRequestModel {
  final String email;
  final String password;
  final String deviceName;
  final String platform;
  final String deviceId;
  final String deviceFingerprint;

  const AuthRequestModel({
    required this.email,
    required this.password,
    required this.deviceName,
    required this.platform,
    required this.deviceId,
    required this.deviceFingerprint,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'device_name': deviceName,
    'platform': platform,
    'device_id': deviceId,
    'device_fingerprint': deviceFingerprint,
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
