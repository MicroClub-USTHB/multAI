import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:multai_mobile/core/usecase/usecase.dart';
import 'package:multai_mobile/core/errors/failure.dart';
import 'package:multai_mobile/core/network/connectivity_service.dart';
import 'package:multai_mobile/features/notifications/domain/entities/notification_entity.dart';
import 'package:multai_mobile/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:multai_mobile/features/notifications/domain/usecases/mark_as_read_usecase.dart';
import 'package:multai_mobile/features/notifications/domain/usecases/register_push_token_usecase.dart';
import 'package:multai_mobile/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:multai_mobile/features/notifications/services/push_notification_service.dart';

class MockGetNotificationsUsecase extends Mock
    implements GetNotificationsUsecase {}

class MockMarkAsRead extends Mock implements MarkAsReadUsecase {}

class MockRegisterPushToken extends Mock implements RegisterPushTokenUseCase {}

class FakeConnectivityService extends Mock implements ConnectivityService {
  final _controller = StreamController<bool>.broadcast();
  bool _connected = false;

  @override
  Stream<bool> get onStatusChanged => _controller.stream;

  @override
  bool get isConnected => _connected;

  void emitOnline(bool online) {
    _connected = online;
    _controller.add(online);
  }

  void closeStream() => _controller.close();
}

class FakePushNotificationService extends Mock
    implements PushNotificationService {
  final _arrivedController = StreamController<void>.broadcast();

  @override
  Stream<void> get onNotificationArrived => _arrivedController.stream;

  void closeStream() => _arrivedController.close();
}

NotificationEntity _notification({String id = '1', bool read = false}) =>
    NotificationEntity(
      id: id,
      type: NotificationType.system,
      payload: {'title': 'Test', 'body': 'Body'},
      readAt: read ? DateTime(2026, 6, 1) : null,
      createdAt: DateTime(2026, 6, 1),
    );

void main() {
  late FakeConnectivityService connectivity;
  late FakePushNotificationService pushService;
  late MockGetNotificationsUsecase mockGetNotifications;
  late MockMarkAsRead mockMarkAsRead;
  late MockRegisterPushToken mockRegisterPushToken;
  late NotificationBloc bloc;

  setUpAll(() {
    registerFallbackValue(NoParams());
  });

  setUp(() {
    connectivity = FakeConnectivityService();
    pushService = FakePushNotificationService();
    mockGetNotifications = MockGetNotificationsUsecase();
    mockMarkAsRead = MockMarkAsRead();
    mockRegisterPushToken = MockRegisterPushToken();
    when(
      () => mockGetNotifications(any()),
    ).thenAnswer((_) async => Right(<NotificationEntity>[]));
    bloc = NotificationBloc(
      getNotifications: mockGetNotifications,
      markAsRead: mockMarkAsRead,
      registerPushToken: mockRegisterPushToken,
      connectivityService: connectivity,
      pushNotificationService: pushService,
    );
  });

  tearDown(() async {
    await bloc.close();
    connectivity.closeStream();
    pushService.closeStream();
  });

  group('NotificationBloc — offline scenarios', () {
    test(
      'offline-with-cache → emits NotificationOffline with cached data',
      () async {
        final cached = [_notification(), _notification(id: '2')];
        when(
          () => mockGetNotifications(any()),
        ).thenAnswer((_) async => Right(cached));

        final future = expectLater(
          bloc.stream,
          emitsInOrder([
            isA<NotificationLoading>(),
            isA<NotificationOffline>(),
          ]),
        );
        bloc.add(LoadNotifications());
        await future;
      },
    );

    test('offline-with-no-cache → emits NotificationOffline', () async {
      when(() => mockGetNotifications(any())).thenAnswer(
        (_) async => Left(const NetworkFailure('No internet connection')),
      );

      final future = expectLater(
        bloc.stream,
        emitsInOrder([isA<NotificationLoading>(), isA<NotificationOffline>()]),
      );
      bloc.add(LoadNotifications());
      await future;
    });

    test('reconnect triggers another load with online state', () async {
      int callCount = 0;
      when(() => mockGetNotifications(any())).thenAnswer((_) async {
        callCount++;
        return Right(<NotificationEntity>[]);
      });

      // First load while offline → NotificationOffline
      final future1 = expectLater(
        bloc.stream,
        emitsInOrder([isA<NotificationLoading>(), isA<NotificationOffline>()]),
      );
      bloc.add(LoadNotifications());
      await future1;
      expect(callCount, 1);

      // Reconnect triggers reload → now NotificationLoaded
      final future2 = expectLater(
        bloc.stream,
        emitsInOrder([isA<NotificationLoading>(), isA<NotificationLoaded>()]),
      );
      connectivity.emitOnline(true);
      await future2;
      expect(callCount, 2);
    });

    test('close() cancels connectivity subscription', () async {
      int callCount = 0;
      when(() => mockGetNotifications(any())).thenAnswer((_) async {
        callCount++;
        return Right(<NotificationEntity>[]);
      });

      // First load while offline
      final future1 = expectLater(
        bloc.stream,
        emitsInOrder([isA<NotificationLoading>(), isA<NotificationOffline>()]),
      );
      bloc.add(LoadNotifications());
      await future1;

      await bloc.close();

      connectivity.emitOnline(true);
      await Future.delayed(const Duration(milliseconds: 50));
      expect(callCount, 1);
    });
  });
}
