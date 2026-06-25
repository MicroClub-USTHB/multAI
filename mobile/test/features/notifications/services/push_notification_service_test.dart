import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:multai_mobile/features/notifications/services/push_notification_service.dart';
import 'package:multai_mobile/features/notifications/services/notification_navigation_service.dart';
import 'package:multai_mobile/features/notifications/domain/usecases/register_push_token_usecase.dart';
import 'package:multai_mobile/features/notifications/domain/usecases/revoke_push_token_usecase.dart';
import 'package:multai_mobile/core/errors/failure.dart';
import 'package:dartz/dartz.dart';

class MockRegisterPushTokenUseCase extends Mock implements RegisterPushTokenUseCase {}
class MockRevokePushTokenUsecase extends Mock implements RevokePushTokenUsecase {}
class MockNotificationNavigationService extends Mock implements NotificationNavigationService {}

void main() {
  late MockRegisterPushTokenUseCase registerToken;
  late MockRevokePushTokenUsecase revokeToken;
  late MockNotificationNavigationService navigationService;
  late PushNotificationService service;

  setUp(() {
    registerToken = MockRegisterPushTokenUseCase();
    revokeToken = MockRevokePushTokenUsecase();
    navigationService = MockNotificationNavigationService();

    service = PushNotificationService(
      registerToken: registerToken,
      revokeToken: revokeToken,
      navigationService: navigationService,
    );
  });

  group('PushNotificationService', () {
    test('revokeToken calls revoke use case', () async {
      when(() => revokeToken(any())).thenAnswer((_) async => const Right(null));

      await service.revokeToken();

      verify(() => revokeToken(any())).called(1);
    });

    test('revokeToken handles failure gracefully', () async {
      when(() => revokeToken(any())).thenAnswer(
        (_) async => const Left(ServerFailure('Server error', 500)),
      );

      await service.revokeToken();

      verify(() => revokeToken(any())).called(1);
    });

    test('registerCurrentToken calls register use case when token provided', () async {
      when(() => registerToken(any())).thenAnswer((_) async => const Right(null));

      await service.registerCurrentToken(token: 'test-token');

      verify(() => registerToken(any())).called(1);
    });

    test('registerCurrentToken handles failure gracefully', () async {
      when(() => registerToken(any())).thenAnswer(
        (_) async => const Left(ServerFailure('Server error', 500)),
      );

      await service.registerCurrentToken(token: 'test-token');

      verify(() => registerToken(any())).called(1);
    });
  });
}
