import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/errors/failure_handler.dart';
import '../../../../core/errors/error_presentation.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/mark_as_read_usecase.dart';
import '../../domain/usecases/register_push_token_usecase.dart';
import '../../services/push_notification_service.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetNotificationsUsecase _getNotifications;
  final MarkAsReadUsecase _markAsRead;
  final FailureHandler _failureHandler;
  final RegisterPushTokenUseCase _registerPushToken;
  final ConnectivityService _connectivityService;
  final PushNotificationService _pushNotificationService;
  StreamSubscription<bool>? _connectivitySub;
  StreamSubscription<void>? _notificationArrivedSub;

  NotificationBloc({
    required GetNotificationsUsecase getNotifications,
    required MarkAsReadUsecase markAsRead,
    required RegisterPushTokenUseCase registerPushToken,
    required ConnectivityService connectivityService,
    required PushNotificationService pushNotificationService,
    FailureHandler? failureHandler,
  }) : _getNotifications = getNotifications,
       _markAsRead = markAsRead,
       _registerPushToken = registerPushToken,
       _connectivityService = connectivityService,
       _pushNotificationService = pushNotificationService,
       _failureHandler = failureHandler ?? FailureHandler.instance,
       super(NotificationInitial()) {
    on<LoadNotifications>(_onLoad);
    on<MarkNotificationRead>(_onMarkRead);
    on<MarkSingleNotificationRead>(_onMarkSingleRead);
    on<MarkAllNotificationsRead>(_onMarkAllRead);
    on<PushTokenReceived>(_onPushTokenReceived);
    on<PushNotificationReceived>(_onPushReceived);
    _connectivitySub = _connectivityService.onStatusChanged.listen((online) {
      if (online) add(LoadNotifications());
    });
    _notificationArrivedSub = _pushNotificationService.onNotificationArrived
        .listen((_) {
          add(LoadNotifications());
        });
  }

  @override
  Future<void> close() {
    _connectivitySub?.cancel();
    _notificationArrivedSub?.cancel();
    return super.close();
  }

  Future<void> _onLoad(
    LoadNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is NotificationLoading) return;
    emit(NotificationLoading());

    final result = await _getNotifications(NoParams());
    result.fold(
      (failure) {
        if (failure is NetworkFailure || !_connectivityService.isConnected) {
          emit(NotificationOffline());
        } else {
          _failureHandler.logFailure(failure, 'NotificationBloc');
          emit(
            NotificationError(
              errorPresentation:
                  _failureHandler.getErrorPresentation(failure),
            ),
          );
        }
      },
      (list) {
        if (!_connectivityService.isConnected) {
          emit(NotificationOffline(cachedNotifications: list));
        } else {
          emit(NotificationLoaded(notifications: list));
        }
      },
    );
  }

  Future<void> _onMarkRead(
    MarkNotificationRead event,
    Emitter<NotificationState> emit,
  ) async {
    final previousState = state;

    final result = await _markAsRead(
      MarkAsReadParams(notificationId: event.notificationIds),
    );

    result.fold(
      (failure) {
        _failureHandler.logFailure(failure, 'NotificationBloc');
        if (previousState is NotificationLoaded) {
          final updated = previousState.notifications.map((n) {
            if (event.notificationIds.contains(n.id)) {
              return n.copyWith(readAt: n.readAt ?? DateTime.now());
            }
            return n;
          }).toList();
          emit(NotificationLoaded(notifications: updated));
        } else {
          emit(
            NotificationError(
              errorPresentation:
                  _failureHandler.getErrorPresentation(failure),
            ),
          );
        }
      },
      (updated) {
        if (updated.isNotEmpty) {
          emit(NotificationLoaded(notifications: updated));
        } else if (previousState is NotificationLoaded) {
          final localUpdated = previousState.notifications.map((n) {
            if (event.notificationIds.contains(n.id)) {
              return n.copyWith(readAt: n.readAt ?? DateTime.now());
            }
            return n;
          }).toList();
          emit(NotificationLoaded(notifications: localUpdated));
        }
      },
    );
  }

  Future<void> _onMarkSingleRead(
    MarkSingleNotificationRead event,
    Emitter<NotificationState> emit,
  ) async {
    add(MarkNotificationRead(notificationIds: [event.notificationId]));
  }

  Future<void> _onMarkAllRead(
    MarkAllNotificationsRead event,
    Emitter<NotificationState> emit,
  ) async {
    final currentState = state;
    if (currentState is! NotificationLoaded) return;

    final unreadIds = currentState.notifications
        .where((n) => !n.isRead)
        .map((n) => n.id)
        .toList();

    if (unreadIds.isEmpty) return;

    add(MarkNotificationRead(notificationIds: unreadIds));
  }

  Future<void> _onPushTokenReceived(
    PushTokenReceived event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await _registerPushToken(
        RegisterPushTokenParams(deviceId: event.deviceId, token: event.token),
      );
    } catch (e) {
      debugPrint('Push token registration failed: $e');
    }
  }

  void _onPushReceived(
    PushNotificationReceived event,
    Emitter<NotificationState> emit,
  ) {
    emit(NotificationPushReceived(title: event.title, body: event.body));
    add(LoadNotifications());
  }
}
