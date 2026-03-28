import '../models/auth_model.dart';
import '../models/me_model.dart';
import '../../../../core/errors/failure.dart';
import './remote_data.dart';

class FakeAuthRemoteDataSource implements AuthRemoteDataSource {
  @override
  Future<AuthResponseModel> login(AuthRequestModel request) async {
    await Future.delayed(const Duration(seconds: 1));

    if (request.email == "test@test.com" && request.password == "test1234") {
      return AuthResponseModel(
        accessToken: "fake_access_token",
        refreshToken: "fake_refresh_token",
      );
    } else {
      throw ServerFailure(message: "Invalid credentials");
    }
  }

  @override
  Future<AuthResponseModel> refreshToken(String refreshToken) async {
    return AuthResponseModel(
      accessToken: "new_fake_token",
      refreshToken: refreshToken,
    );
  }

  @override
  Future<void> logout() async {}

  @override
  Future<void> revokeDevice(String deviceId) async {}

  @override
  Future<MeResponseModel> getMe() async {
    return MeResponseModel(
      id: '1',
      email: "test@test.com",
      devices: List.empty(),
    );
  }
}
