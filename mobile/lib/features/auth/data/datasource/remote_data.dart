import '../../../../core/constants/end_points.dart';
import '../../../../core/network/api_client.dart';
import '../models/auth_model.dart';
import '../models/me_model.dart';

abstract class AuthRemoteDataSource {
  Future<String> register(AuthRequestModel request);
  Future<AuthResponseModel> verifyRegister(RegisterVerifyRequestModel request);
  Future<AuthResponseModel> login(AuthRequestModel request);
  Future<AuthResponseModel> refreshToken(String refreshToken);
  Future<String> resendOtp(String pendingToken);
  Future<void> logout();
  Future<void> revokeDevice(String deviceId);
  Future<MeResponseModel> getMe();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  void setAccessToken(String token) => apiClient.setAccessToken(token);

  @override
  Future<String> register(AuthRequestModel request) async {
    final json = await apiClient.post(EndPoints.register, body: request.toJson());
    return json['pending_token'] as String;
  }

  @override
  Future<String> resendOtp(String pendingToken) async {
    final json = await apiClient.post(
      EndPoints.resendOtp,
      body: {'pending_token': pendingToken},
    );
    return json['pending_token'] as String;
  }

  @override
  Future<AuthResponseModel> verifyRegister(
    RegisterVerifyRequestModel request,
  ) async {
    final json = await apiClient.post(
      EndPoints.registerVerify,
      body: request.toJson(),
    );
    return AuthResponseModel.fromJson(json);
  }

  @override
  Future<AuthResponseModel> login(AuthRequestModel request) async {
    final json = await apiClient.post(EndPoints.login, body: request.toJson());
    return AuthResponseModel.fromJson(json);
  }

  @override
  Future<AuthResponseModel> refreshToken(String refreshToken) async {
    final json = await apiClient.post(
      EndPoints.refresh,
      body: {'refresh_token': refreshToken},
    );
    return AuthResponseModel.fromJson(json);
  }

  @override
  Future<void> logout() async {
    await apiClient.postVoid(EndPoints.logout, requiresAuth: true);
  }

  @override
  Future<void> revokeDevice(String deviceId) async {
    await apiClient.postVoid(
      '${EndPoints.revokeDevice}?device_id=$deviceId',
      requiresAuth: true,
    );
  }

  @override
  Future<MeResponseModel> getMe() async {
    final json = await apiClient.get(EndPoints.me);
    return MeResponseModel.fromJson(json);
  }
}
