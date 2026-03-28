import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasource/remote_data.dart';
import '../models/auth_model.dart';
import '../../../../core/network/api_client.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.apiClient,
    //
    required this.sharedPreferences,
  });

  //

  @override
  Future<Either<Failure, String?>> getToken() async {
    try {
      String? token = apiClient.currentAccessToken;
      if (token == null || token.isEmpty) {
        token = sharedPreferences.getString('access_token');
        if (token != null) {
          apiClient.setAccessToken(token);
        }
      }
      return Right(token);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> login(LoginParams params) async {
    try {
      final result = await remoteDataSource.login(
        AuthRequestModel(
          email: params.email,
          password: params.password,
          deviceName: params.deviceName,
          platform: params.platform,
          deviceId: params.deviceId,
          deviceFingerprint: params.deviceFingerprint,
        ),
      );
      apiClient.setAccessToken(result.accessToken);
      await sharedPreferences.setString('access_token', result.accessToken);
      return Right(result);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> refreshToken(String refreshToken) async {
    try {
      final result = await remoteDataSource.refreshToken(refreshToken);
      apiClient.setAccessToken(result.accessToken);
      return Right(result);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      apiClient.clearAccessToken();
      await sharedPreferences.remove('access_token');
      return const Right(null);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, MeEntity>> getMe() async {
    try {
      final result = await remoteDataSource.getMe();
      return Right(result);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
