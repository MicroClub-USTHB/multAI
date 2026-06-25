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

class RegisterVerifyRequestModel extends AuthRequestModel {
  final String otp;

  const RegisterVerifyRequestModel({
    required super.email,
    required super.password,
    required super.deviceName,
    required super.deviceType,
    required super.deviceId,
    required this.otp,
  });

  @override
  Map<String, dynamic> toJson() => {...super.toJson(), 'otp': otp};
}

class AuthResponseModel extends AuthEntity {
  const AuthResponseModel({
    required super.accessToken,
    required super.refreshToken,
    required super.sessionId,
    required super.expiresIn,
    required super.userId,
    super.isNewUser = false,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      accessToken: json['access_token'] as String? ?? '',
      refreshToken: json['refresh_token'] as String? ?? '',
      sessionId: json['session_id'] as String? ?? '',
      expiresIn: json['expires_in'] as int? ?? 0,
      userId: json['user_id']?.toString() ?? '',
      isNewUser: json['is_new_user'] as bool? ?? false,
    );
  }
}
