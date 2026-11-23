import 'dart:async';

import 'package:dartz/dartz.dart';

import '../../../../core/constants/storage_keys.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/failure_handler.dart';
import '../../../../core/storage/app_local_storage.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasource/remote_data.dart';
import '../datasource/auth_local_datasource.dart';
import '../models/auth_model.dart';
import '../../../../core/network/api_client.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final ApiClient apiClient;
  final LocalStorage localStorage;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.apiClient,
    required this.localStorage,
    required this.localDataSource,
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
    // Remember which account the device-local data (albums, caches) belongs
    // to, so a different account signing in on this device never reads it.
    if (result.userId.isNotEmpty) {
      await localStorage.setString(StorageKeys.currentUserId, result.userId);
    }
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
    if (secureToken != null && secureToken.isNotEmpty) return secureToken;
    return null;
  }

  @override
  Future<Either<Failure, String?>> getToken() async {
    try {
      String? token = apiClient.currentAccessToken;
      if (token == null || token.isEmpty) {
        token = await _loadAccessToken();
        if (token != null) apiClient.setAccessToken(token);
      }
      return Right(token);
    } catch (e) {
      FailureHandler.instance.logFailure(
        UnknownFailure('Failed to retrieve session'),
        'AuthRepository',
      );
      return Left(const ServerFailure('Failed to retrieve session'));
    }
  }

  Future<Either<Failure, AuthEntity>> _authenticate(
    Future<AuthResponseModel> Function() request,
    LoginParams params,
  ) async {
    try {
      final result = await request();
      await _persistTokens(result);
      return Right(result);
    } on Failure catch (f) {
      FailureHandler.instance.logFailure(f, 'AuthRepository');
      return Left(f);
    } catch (e) {
      FailureHandler.instance.logFailure(
        UnknownFailure('Authentication failed'),
        'AuthRepository',
      );
      return Left(ServerFailure('Authentication failed. Please try again.'));
    }
  }

  @override
  Future<Either<Failure, String>> register(LoginParams params) async {
    try {
      final pendingToken = await remoteDataSource.register(
        AuthRequestModel(
          email: params.email.trim().toLowerCase(),
          password: params.password,
          deviceName: params.deviceName,
          deviceType: params.deviceType,
          deviceId: params.deviceId,
        ),
      );
      return Right(pendingToken);
    } on Failure catch (f) {
      FailureHandler.instance.logFailure(f, 'AuthRepository');
      return Left(f);
    } catch (e) {
      FailureHandler.instance.logFailure(
        UnknownFailure('Registration failed'),
        'AuthRepository',
      );
      return Left(ServerFailure('Registration failed. Please try again.'));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> verifyRegister(
    LoginParams params,
    String otp,
  ) async {
    return _authenticate(
      () => remoteDataSource.verifyRegister(
        RegisterVerifyRequestModel(
          email: params.email.trim().toLowerCase(),
          password: params.password,
          deviceName: params.deviceName,
          deviceType: params.deviceType,
          deviceId: params.deviceId,
          otp: otp,
        ),
      ),
      params,
    );
  }

  @override
  Future<Either<Failure, String>> resendOtp(String pendingToken) async {
    try {
      final newPendingToken = await remoteDataSource.resendOtp(pendingToken);
      return Right(newPendingToken);
    } on Failure catch (f) {
      FailureHandler.instance.logFailure(f, 'AuthRepository');
      return Left(f);
    } catch (e) {
      FailureHandler.instance.logFailure(
        UnknownFailure('Failed to resend OTP'),
        'AuthRepository',
      );
      return Left(ServerFailure('Failed to resend OTP. Please try again.'));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> login(LoginParams params) async {
    return _authenticate(
      () => remoteDataSource.login(
        AuthRequestModel(
          email: params.email.trim().toLowerCase(),
          password: params.password,
          deviceName: params.deviceName,
          deviceType: params.deviceType,
          deviceId: params.deviceId,
        ),
      ),
      params,
    );
  }

  @override
  Future<Either<Failure, AuthEntity>> refreshToken(String refreshToken) async {
    try {
      final result = await remoteDataSource.refreshToken(refreshToken);
      await _persistTokens(result);
      return Right(result);
    } on Failure catch (f) {
      FailureHandler.instance.logFailure(f, 'AuthRepository');
      await _clearTokens();
      return Left(f);
    } catch (e) {
      FailureHandler.instance.logFailure(
        UnknownFailure('Token refresh failed'),
        'AuthRepository',
      );
      await _clearTokens();
      return Left(
        const UnauthorizedFailure('Session expired. Please sign in again.'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    // Local-first: capture the token for the server call, then clear the
    // local session immediately. The remote revocation must never gate the
    // sign-out UI (it used to wait up to the full request timeout).
    var accessToken = apiClient.currentAccessToken;
    try {
      accessToken ??= await _loadAccessToken();
      await _clearTokens();
      await localDataSource.clearCachedMe();
      await _clearAccountScopedCache();
    } catch (e) {
      FailureHandler.instance.logFailure(
        UnknownFailure('Failed to clear local session: $e'),
        'AuthRepository',
      );
      apiClient.clearAccessToken();
    }
    unawaited(_revokeRemoteSession(accessToken));
    return const Right(null);
  }

  /// Clears per-account local state that would otherwise leak into the next
  /// account signed in on this device: cached profile/avatar, cached events
  /// and approvals, and the face-enrollment flag (which is device-wide, so a
  /// new account would otherwise inherit the previous account's enrollment).
  Future<void> _clearAccountScopedCache() async {
    await localStorage.remove(StorageKeys.currentUserId);
    await localStorage.remove(StorageKeys.faceEnrollmentDone);
    await localStorage.remove(StorageKeys.cachedEvents);
    await localStorage.remove(StorageKeys.galleryCacheManifest);
    await localStorage.removeSecure(StorageKeys.cachedAccount);
    await localStorage.removeSecure(StorageKeys.cachedApprovals);
  }

  /// Best-effort server-side revocation using the token captured before the
  /// local session was cleared. Failures are ignored: the user is already out.
  Future<void> _revokeRemoteSession(String? accessToken) async {
    if (accessToken == null || accessToken.isEmpty) return;
    try {
      await remoteDataSource
          .logout(accessToken: accessToken)
          .timeout(const Duration(seconds: 5));
    } catch (_) {}
  }

  @override
  Future<Either<Failure, MeEntity>> getMe() async {
    try {
      final result = await remoteDataSource.getMe();
      await localDataSource.cacheMe(result);
      if (result.id.isNotEmpty) {
        await localStorage.setString(StorageKeys.currentUserId, result.id);
      }
      return Right(result);
    } on Failure catch (f) {
      FailureHandler.instance.logFailure(f, 'AuthRepository');
      final cached = await localDataSource.getCachedMe();
      if (cached != null) {
        return Right(cached);
      }
      return Left(f);
    } catch (e) {
      FailureHandler.instance.logFailure(
        UnknownFailure('Failed to load user data'),
        'AuthRepository',
      );
      return Left(ServerFailure('Failed to load user data'));
    }
  }
}
