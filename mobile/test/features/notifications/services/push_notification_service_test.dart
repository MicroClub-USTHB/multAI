import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:multai_mobile/features/notifications/services/push_notification_service.dart';
import 'package:multai_mobile/features/notifications/services/notification_navigation_service.dart';
import 'package:multai_mobile/features/notifications/domain/usecases/register_push_token_usecase.dart';
import 'package:multai_mobile/features/notifications/domain/usecases/revoke_push_token_usecase.dart';
import 'package:multai_mobile/core/errors/failure.dart';
import 'package:dartz/dartz.dart';

class MockRegisterPushTokenUseCase extends Mock
    implements RegisterPushTokenUseCase {}

class MockRevokePushTokenUsecase extends Mock
    implements RevokePushTokenUsecase {}

class MockNotificationNavigationService extends Mock
    implements NotificationNavigationService {}

class MockFirebaseMessaging extends Mock implements FirebaseMessaging {}

void main() {
  late MockRegisterPushTokenUseCase registerToken;
  late MockRevokePushTokenUsecase revokeToken;
  late MockNotificationNavigationService navigationService;
  late MockFirebaseMessaging fcm;
  late PushNotificationService service;

  setUpAll(() {
    registerFallbackValue(
      const RegisterPushTokenParams(deviceId: 'test', token: 'test'),
    );
    registerFallbackValue(const RevokePushTokenParams(deviceId: 'test'));
  });

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    FlutterSecureStorage.setMockInitialValues({'device_id': 'test-device-id'});

    registerToken = MockRegisterPushTokenUseCase();
    revokeToken = MockRevokePushTokenUsecase();
    navigationService = MockNotificationNavigationService();
    fcm = MockFirebaseMessaging();

    when(() => fcm.getToken()).thenAnswer((_) async => null);
    when(() => fcm.deleteToken()).thenAnswer((_) async {});

    service = PushNotificationService(
      registerToken: registerToken,
      revokeToken: revokeToken,
      navigationService: navigationService,
      fcm: fcm,
    );
  });

  group('PushNotificationService', () {
    test('revokeToken calls revoke use case and deletes FCM token', () async {
      when(() => revokeToken(any())).thenAnswer((_) async => const Right(null));

      await service.revokeToken();

      verify(() => revokeToken(any())).called(1);
      verify(() => fcm.deleteToken()).called(1);
    });

    test('revokeToken handles failure gracefully', () async {
      when(
        () => revokeToken(any()),
      ).thenAnswer((_) async => const Left(ServerFailure('Server error', 500)));

      await service.revokeToken();

      verify(() => revokeToken(any())).called(1);
      verify(() => fcm.deleteToken()).called(1);
    });

    test(
      'registerCurrentToken calls register use case when token provided',
      () async {
        when(
          () => registerToken(any()),
        ).thenAnswer((_) async => const Right(null));

        await service.registerCurrentToken(token: 'test-token');

        verify(() => registerToken(any())).called(1);
      },
    );

    test('registerCurrentToken handles failure gracefully', () async {
      when(
        () => registerToken(any()),
      ).thenAnswer((_) async => const Left(ServerFailure('Server error', 500)));

      await service.registerCurrentToken(token: 'test-token');

      verify(() => registerToken(any())).called(1);
    });
  });
}
