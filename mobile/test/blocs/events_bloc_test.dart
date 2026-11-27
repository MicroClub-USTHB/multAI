import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:multai_mobile/core/usecase/usecase.dart';
import 'package:multai_mobile/core/errors/failure.dart';
import 'package:multai_mobile/core/network/connectivity_service.dart';
import 'package:multai_mobile/features/events/domain/entities/event_entity.dart';
import 'package:multai_mobile/features/events/domain/usecases/get_events_usecase.dart';
import 'package:multai_mobile/features/events/presentation/bloc/events_bloc.dart';

class MockGetUserEventsUseCase extends Mock implements GetUserEventsUseCase {}

class MockJoinEventUseCase extends Mock implements JoinEventUseCase {}

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

EventEntity _event({String id = '1', String status = 'active'}) => EventEntity(
  id: id,
  name: 'Event $id',
  eventDate: DateTime(2026, 6, 1),
  status: status,
  joinedAt: DateTime(2026, 5, 1),
);

void main() {
  late FakeConnectivityService connectivity;
  late MockGetUserEventsUseCase mockGetEvents;
  late MockJoinEventUseCase mockJoinEvent;
  late EventsBloc bloc;

  setUpAll(() {
    registerFallbackValue(NoParams());
  });

  setUp(() {
    connectivity = FakeConnectivityService();
    mockGetEvents = MockGetUserEventsUseCase();
    mockJoinEvent = MockJoinEventUseCase();
    bloc = EventsBloc(
      getUserEventsUseCase: mockGetEvents,
      joinEventUseCase: mockJoinEvent,
      connectivityService: connectivity,
    );
  });

  tearDown(() async {
    await bloc.close();
    connectivity.closeStream();
  });

  group('EventsBloc — offline scenarios', () {
    test('offline-with-cache → emits EventsLoaded (not Offline)', () async {
      final cached = [_event(id: '1'), _event(id: '2', status: 'archived')];
      when(() => mockGetEvents(any())).thenAnswer((_) async => Right(cached));

      final future = expectLater(
        bloc.stream,
        emitsInOrder([isA<EventsLoading>(), isA<EventsLoaded>()]),
      );
      bloc.add(GetUserEventsRequested());
      await future;
    });

    test('offline-with-no-cache → emits EventsOffline', () async {
      when(() => mockGetEvents(any())).thenAnswer(
        (_) async => Left(const NetworkFailure('No internet connection')),
      );

      final future = expectLater(
        bloc.stream,
        emitsInOrder([isA<EventsLoading>(), isA<EventsOffline>()]),
      );
      bloc.add(GetUserEventsRequested());
      await future;
    });

    test('reconnect triggers another load', () async {
      int callCount = 0;
      when(() => mockGetEvents(any())).thenAnswer((_) async {
        callCount++;
        return Right(<EventEntity>[]);
      });

      // First load
      final future1 = expectLater(
        bloc.stream,
        emitsInOrder([isA<EventsLoading>(), isA<EventsLoaded>()]),
      );
      bloc.add(GetUserEventsRequested());
      await future1;
      expect(callCount, 1);

      // Connectivity restored → triggers second load
      // During refresh, BLoC emits EventsLoaded(isRefreshing: true) then EventsLoaded
      final future2 = expectLater(
        bloc.stream,
        emitsInOrder([isA<EventsLoaded>(), isA<EventsLoaded>()]),
      );
      connectivity.emitOnline(true);
      await future2;
      expect(callCount, 2);
    });

    test('close() cancels connectivity subscription', () async {
      int callCount = 0;
      when(() => mockGetEvents(any())).thenAnswer((_) async {
        callCount++;
        return Right(<EventEntity>[]);
      });

      // Load once
      final future1 = expectLater(
        bloc.stream,
        emitsInOrder([isA<EventsLoading>(), isA<EventsLoaded>()]),
      );
      bloc.add(GetUserEventsRequested());
      await future1;

      // Close the bloc
      await bloc.close();

      // Reconnect after close — should NOT trigger another load
      connectivity.emitOnline(true);
      await Future.delayed(const Duration(milliseconds: 50));
      expect(callCount, 1);
    });
  });
}
