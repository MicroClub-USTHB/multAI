import 'package:dartz/dartz.dart';

import '../../../../core/constants/storage_keys.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/failure_handler.dart';
import '../../../../core/security/secure_logger.dart';
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
  final LocalStorage localStorage;

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
  }

  Future<String?> _loadAccessToken() async {
    final secureToken = await localStorage.getSecureString(
      StorageKeys.accessToken,
    );
    if (secureToken != null && secureToken.isNotEmpty) {
      return secureToken;
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
      SecureLogger.error('AuthRepository', 'getToken failed', e);
      return Left(const ServerFailure(message: 'Failed to retrieve session'));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> login(LoginParams params) async {
    try {
      final sanitizedEmail = params.email.trim().toLowerCase();
      final result = await remoteDataSource.login(
        AuthRequestModel(
          email: sanitizedEmail,
          password: params.password,
          deviceName: params.deviceName,
          deviceType: params.deviceType,
          deviceId: params.deviceId,
        ),
      );
      await _persistTokens(result);
      SecureLogger.info('AuthRepository', 'Login successful');
      return Right(result);
    } on Failure catch (f) {
      FailureHandler.logFailure(f, 'AuthRepository');
      return Left(f);
    } catch (e) {
      SecureLogger.error('AuthRepository', 'Login failed', e);
      return Left(ServerFailure(message: 'Login failed. Please try again.'));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> refreshToken(String refreshToken) async {
    try {
      final result = await remoteDataSource.refreshToken(refreshToken);
      await _persistTokens(result);
      return Right(result);
    } on Failure catch (f) {
      FailureHandler.logFailure(f, 'AuthRepository');
      await _clearTokens();
      return Left(f);
    } catch (e) {
      SecureLogger.error('AuthRepository', 'Token refresh failed', e);
      await _clearTokens();
      return Left(const UnauthorizedFailure(
        message: 'Session expired. Please sign in again.',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      await _clearTokens();
      SecureLogger.info('AuthRepository', 'Logout successful');
      return const Right(null);
    } on Failure catch (f) {
      FailureHandler.logFailure(f, 'AuthRepository');
      await _clearTokens();
      return const Right(null);
    } catch (e) {
      SecureLogger.error('AuthRepository', 'Logout failed', e);
      await _clearTokens();
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, MeEntity>> getMe() async {
    try {
      final result = await remoteDataSource.getMe();
      return Right(result);
    } on Failure catch (f) {
      FailureHandler.logFailure(f, 'AuthRepository');
      return Left(f);
    } catch (e) {
      SecureLogger.error('AuthRepository', 'getMe failed', e);
      return Left(ServerFailure(message: 'Failed to load user data'));
    }
  }
}
