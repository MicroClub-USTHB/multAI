import 'package:dartz/dartz.dart';

import '../../../../core/constants/storage_keys.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/storage/app_local_storage.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasource/remote_data.dart';
import '../models/auth_model.dart';
import '../../../../core/network/api_client.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final ApiClient apiClient;
  final AppLocalStorage localStorage;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.apiClient,
    required this.localStorage,
  });

  Future<void> _persistTokens(AuthEntity result) async {
    apiClient.setAccessToken(result.accessToken);
    await localStorage.setSecureString(
      StorageKeys.accessToken,
      result.accessToken,
    );
    await localStorage.setSecureString(
      StorageKeys.refreshToken,
      result.refreshToken,
    );
  }

  Future<void> _clearTokens() async {
    apiClient.clearAccessToken();
    await localStorage.removeSecure(StorageKeys.accessToken);
    await localStorage.removeSecure(StorageKeys.refreshToken);
    await localStorage.removePref(StorageKeys.accessToken);
    await localStorage.removePref(StorageKeys.refreshToken);
  }

  Future<String?> _loadAccessToken() async {
    final secureToken = await localStorage.getSecureString(
      StorageKeys.accessToken,
    );
    if (secureToken != null && secureToken.isNotEmpty) {
      return secureToken;
    }

    final legacyToken = localStorage.getString(StorageKeys.accessToken);
    if (legacyToken != null && legacyToken.isNotEmpty) {
      await localStorage.setSecureString(StorageKeys.accessToken, legacyToken);
      return legacyToken;
    }

    return null;
  }

  @override
  Future<Either<Failure, String?>> getToken() async {
    try {
      String? token = apiClient.currentAccessToken;
      if (token == null || token.isEmpty) {
        token = await _loadAccessToken();
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
          deviceType: params.deviceType,
          deviceId: params.deviceId,
        ),
      );
      await _persistTokens(result);
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
      await _persistTokens(result);
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
      await _clearTokens();
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
