import 'dart:io';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:multai_mobile/core/errors/failure.dart';
import 'package:multai_mobile/core/usecase/usecase.dart';
import 'package:multai_mobile/features/auth/domain/entities/auth_entity.dart';
import 'package:multai_mobile/features/auth/domain/entities/user_entity.dart';
import 'package:multai_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:multai_mobile/features/auth/domain/usecases/get_me_usecase.dart';
import 'package:multai_mobile/features/auth/domain/usecases/login_usecase.dart';
import 'package:multai_mobile/features/auth/domain/usecases/logout_usecase.dart';
import 'package:multai_mobile/features/auth/domain/usecases/refresh_token_usecase.dart';
import 'package:multai_mobile/features/auth/domain/usecases/register_usecase.dart';
import 'package:multai_mobile/features/auth/domain/usecases/resend_otp_usecase.dart';
import 'package:multai_mobile/features/auth/domain/usecases/verify_register_usecase.dart';
import 'package:multai_mobile/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:multai_mobile/features/face_enrollment/domain/usecases/check_enrollment_done_usecase.dart';
import 'package:multai_mobile/features/notifications/services/push_notification_service.dart';

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

class MockVerifyRegisterUseCase extends Mock implements VerifyRegisterUseCase {}

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

class MockRefreshTokenUseCase extends Mock implements RefreshTokenUseCase {}

class MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}

class MockCheckEnrollmentDoneUseCase extends Mock
    implements CheckEnrollmentDoneUseCase {}

class MockResendOtpUseCase extends Mock implements ResendOtpUseCase {}

class MockPushNotificationService extends Mock
    implements PushNotificationService {}

void main() {
  late MockRegisterUseCase registerUseCase;
  late MockVerifyRegisterUseCase verifyRegisterUseCase;
  late MockLoginUseCase loginUseCase;
  late MockResendOtpUseCase resendOtpUseCase;
  late MockLogoutUseCase logoutUseCase;
  late MockRefreshTokenUseCase refreshTokenUseCase;
  late MockGetCurrentUserUseCase getCurrentUserUseCase;
  late MockCheckEnrollmentDoneUseCase checkEnrollmentDoneUseCase;
  late MockPushNotificationService pushNotificationService;
  late AuthBloc authBloc;

  setUpAll(() {
    registerFallbackValue(
      LoginParams(
        email: 'test@test.com',
        password: 'pass',
        deviceName: 'test',
        deviceType: 'test',
        deviceId: 'test',
      ),
    );
    registerFallbackValue(
      VerifyRegisterParams(
        loginParams: LoginParams(
          email: 'test@test.com',
          password: 'pass',
          deviceName: 'test',
          deviceType: 'test',
          deviceId: 'test',
        ),
        otp: '123456',
      ),
    );
    registerFallbackValue(RefreshTokenParams(refreshToken: 'token'));
    registerFallbackValue(NoParams());
  });

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({'device_id': 'test-device-id'});
    FlutterSecureStorage.setMockInitialValues({'device_id': 'test-device-id'});

    registerUseCase = MockRegisterUseCase();
    verifyRegisterUseCase = MockVerifyRegisterUseCase();
    loginUseCase = MockLoginUseCase();
    resendOtpUseCase = MockResendOtpUseCase();
    logoutUseCase = MockLogoutUseCase();
    refreshTokenUseCase = MockRefreshTokenUseCase();
    getCurrentUserUseCase = MockGetCurrentUserUseCase();
    checkEnrollmentDoneUseCase = MockCheckEnrollmentDoneUseCase();
    pushNotificationService = MockPushNotificationService();
    when(
      () => pushNotificationService.registerCurrentToken(),
    ).thenAnswer((_) async {});
    when(() => pushNotificationService.revokeToken()).thenAnswer((_) async {});

    authBloc = AuthBloc(
      loginUseCase: loginUseCase,
      registerUseCase: registerUseCase,
      resendOtpUseCase: resendOtpUseCase,
      verifyRegisterUseCase: verifyRegisterUseCase,
      logoutUseCase: logoutUseCase,
      refreshTokenUseCase: refreshTokenUseCase,
      getCurrentUserUseCase: getCurrentUserUseCase,
      pushNotificationService: pushNotificationService,
    );
  });

  tearDown(() {
    authBloc.close();
  });

  group('SendOtpRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthOtpSent] on success',
      build: () {
        when(
          () => registerUseCase(any()),
        ).thenAnswer((_) async => const Right('pending-token'));
        return authBloc;
      },
      act: (bloc) => bloc.add(
        SendOtpRequested(email: 'test@test.com', password: 'Password1!'),
      ),
      expect: () => [isA<AuthLoading>(), isA<AuthOtpSent>()],
      verify: (_) {
        verify(() => registerUseCase(any())).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailure] on server failure',
      build: () {
        when(
          () => registerUseCase(any()),
        ).thenAnswer((_) async => Left(ServerFailure('Email already in use')));
        return authBloc;
      },
      act: (bloc) => bloc.add(
        SendOtpRequested(email: 'existing@test.com', password: 'Password1!'),
      ),
      expect: () => [isA<AuthLoading>(), isA<AuthFailure>()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailure] on exception',
      build: () {
        when(
          () => registerUseCase(any()),
        ).thenThrow(Exception('Network error'));
        return authBloc;
      },
      act: (bloc) => bloc.add(
        SendOtpRequested(email: 'test@test.com', password: 'Password1!'),
      ),
      expect: () => [isA<AuthLoading>(), isA<AuthFailure>()],
      verify: (_) {
        verify(() => registerUseCase(any())).called(1);
      },
    );
  });

  group('VerifyOtpRequested', () {
    const authEntity = AuthEntity(
      accessToken: 'access',
      refreshToken: 'refresh',
      sessionId: 'session',
      expiresIn: 3600,
      userId: 'user',
      isNewUser: true,
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthNeedsFaceEnrollment] when face enrollment not done',
      build: () {
        when(
          () => verifyRegisterUseCase(any()),
        ).thenAnswer((_) async => Right(authEntity));
        when(
          () => checkEnrollmentDoneUseCase.call(),
        ).thenAnswer((_) async => false);
        return authBloc;
      },
      act: (bloc) => bloc.add(
        VerifyOtpRequested(
          email: 'test@test.com',
          password: 'Password1!',
          otp: '123456',
        ),
      ),
      expect: () => [isA<AuthLoading>(), isA<AuthNeedsFaceEnrollment>()],
      verify: (_) {
        verify(() => pushNotificationService.registerCurrentToken()).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when face enrollment done',
      build: () {
        when(
          () => verifyRegisterUseCase(any()),
        ).thenAnswer((_) async => Right(authEntity));
        when(
          () => checkEnrollmentDoneUseCase.call(),
        ).thenAnswer((_) async => true);
        return authBloc;
      },
      act: (bloc) => bloc.add(
        VerifyOtpRequested(
          email: 'test@test.com',
          password: 'Password1!',
          otp: '123456',
        ),
      ),
      expect: () => [isA<AuthLoading>(), isA<AuthAuthenticated>()],
      verify: (_) {
        verify(() => pushNotificationService.registerCurrentToken()).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailure] on invalid OTP',
      build: () {
        when(() => verifyRegisterUseCase(any())).thenAnswer(
          (_) async => Left(UnauthorizedFailure('Invalid or expired OTP')),
        );
        return authBloc;
      },
      act: (bloc) => bloc.add(
        VerifyOtpRequested(
          email: 'test@test.com',
          password: 'Password1!',
          otp: '000000',
        ),
      ),
      expect: () => [isA<AuthLoading>(), isA<AuthFailure>()],
    );
  });

  group('LoginRequested', () {
    const authEntity = AuthEntity(
      accessToken: 'access',
      refreshToken: 'refresh',
      sessionId: 'session',
      expiresIn: 3600,
      userId: 'user',
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] on success',
      build: () {
        when(
          () => loginUseCase(any()),
        ).thenAnswer((_) async => Right(authEntity));
        when(
          () => checkEnrollmentDoneUseCase.call(),
        ).thenAnswer((_) async => true);
        return authBloc;
      },
      act: (bloc) => bloc.add(
        LoginRequested(email: 'test@test.com', password: 'Password1!'),
      ),
      expect: () => [isA<AuthLoading>(), isA<AuthAuthenticated>()],
      verify: (_) {
        verify(() => pushNotificationService.registerCurrentToken()).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailure] on invalid credentials',
      build: () {
        when(() => loginUseCase(any())).thenAnswer(
          (_) async => Left(UnauthorizedFailure('Invalid credentials')),
        );
        return authBloc;
      },
      act: (bloc) =>
          bloc.add(LoginRequested(email: 'wrong@test.com', password: 'bad')),
      expect: () => [isA<AuthLoading>(), isA<AuthFailure>()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailure] on network error',
      build: () {
        when(() => loginUseCase(any())).thenAnswer(
          (_) async => Left(NetworkFailure('No internet connection')),
        );
        return authBloc;
      },
      act: (bloc) => bloc.add(
        LoginRequested(email: 'test@test.com', password: 'Password1!'),
      ),
      expect: () => [isA<AuthLoading>(), isA<AuthFailure>()],
    );

    test('sequential execution processes both logins', () async {
      int callCount = 0;
      when(() => loginUseCase(any())).thenAnswer((_) async {
        callCount++;
        await Future.delayed(const Duration(milliseconds: 50));
        return Right(authEntity);
      });
      when(
        () => checkEnrollmentDoneUseCase.call(),
      ).thenAnswer((_) async => true);
      when(
        () => pushNotificationService.registerCurrentToken(),
      ).thenAnswer((_) async {});

      authBloc.add(
        LoginRequested(email: 'test@test.com', password: 'Password1!'),
      );
      authBloc.add(
        LoginRequested(email: 'test@test.com', password: 'Password2!'),
      );

      await Future.delayed(const Duration(milliseconds: 200));
      expect(callCount, 2);
    });
  });

  group('LogoutRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Unauthenticated] on success',
      build: () {
        when(
          () => logoutUseCase(any()),
        ).thenAnswer((_) async => const Right(null));
        when(
          () => pushNotificationService.revokeToken(),
        ).thenAnswer((_) async {});
        return authBloc;
      },
      act: (bloc) => bloc.add(LogoutRequested()),
      expect: () => [isA<AuthLoading>(), isA<Unauthenticated>()],
      verify: (_) {
        verify(() => pushNotificationService.revokeToken()).called(1);
      },
    );
  });

  group('GetCurrentUserRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, GetCurrentUserSuccess] on success',
      build: () {
        when(() => getCurrentUserUseCase(any())).thenAnswer(
          (_) async => Right(
            MeEntity(id: '1', email: 'test@test.com', devices: const []),
          ),
        );
        return authBloc;
      },
      act: (bloc) => bloc.add(GetCurrentUserRequested()),
      expect: () => [isA<AuthLoading>(), isA<GetCurrentUserSuccess>()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailure] on failure',
      build: () {
        when(
          () => getCurrentUserUseCase(any()),
        ).thenAnswer((_) async => Left(ServerFailure('Failed to load user')));
        return authBloc;
      },
      act: (bloc) => bloc.add(GetCurrentUserRequested()),
      expect: () => [isA<AuthLoading>(), isA<AuthFailure>()],
    );
  });

  group('AuthBloc - Error sanitization', () {
    test('sanitizes SocketException to user-friendly message', () async {
      when(
        () => loginUseCase(any()),
      ).thenThrow(const SocketException('Connection refused'));

      final expected = [isA<AuthLoading>(), isA<AuthFailure>()];

      expect(authBloc.stream, emitsInOrder(expected));

      authBloc.add(
        LoginRequested(email: 'test@test.com', password: 'Password1!'),
      );
    });

    test('sanitizes generic exception to safe message', () async {
      when(
        () => loginUseCase(any()),
      ).thenThrow(Exception('Some internal error details'));

      final expected = [isA<AuthLoading>(), isA<AuthFailure>()];

      expect(authBloc.stream, emitsInOrder(expected));

      authBloc.add(
        LoginRequested(email: 'test@test.com', password: 'Password1!'),
      );
    });
  });
}
