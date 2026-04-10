import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/mark_as_read_usecase.dart';
import '../../domain/usecases/register_push_token_usecase.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetNotificationsUsecase _getNotifications;
  final MarkAsReadUsecase _markAsRead;
  final RegisterPushTokenUseCase _registerPushToken;

  NotificationBloc({
    required GetNotificationsUsecase getNotifications,
    required MarkAsReadUsecase markAsRead,
    required RegisterPushTokenUseCase registerPushToken,
  }) : _getNotifications = getNotifications,
       _markAsRead = markAsRead,
       _registerPushToken = registerPushToken,
       super(NotificationInitial()) {
    on<LoadNotifications>(_onLoad);
    on<MarkNotificationRead>(_onMarkRead);
    on<MarkSingleNotificationRead>(_onMarkSingleRead);
    on<MarkAllNotificationsRead>(_onMarkAllRead);
    on<PushTokenReceived>(_onPushTokenReceived);
    on<PushNotificationReceived>(_onPushReceived);
  }

  // ── Load ───────────────────────────────────────────────────────────────────
  Future<void> _onLoad(
    LoadNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());

    final result = await _getNotifications(NoParams());
    result.fold(
      (failure) => emit(NotificationError(message: failure.message)),
      (list) => emit(NotificationLoaded(notifications: list)),
    );
  }

  Future<void> _onMarkRead(
    MarkNotificationRead event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await _markAsRead(
      MarkAsReadParams(notificationId: event.notificationIds),
    );

    result.fold(
      (failure) => emit(NotificationError(message: failure.message)),
    
      (updated) => emit(NotificationLoaded(notifications: updated)),
    );
  }

  // ── Mark single — wraps as list ────────────────────────────────────────────
  Future<void> _onMarkSingleRead(
    MarkSingleNotificationRead event,
    Emitter<NotificationState> emit,
  ) async {
    add(MarkNotificationRead(notificationIds: [event.notificationId]));
  }

  // ── Mark all — sends all unread IDs ───────────────────────────────────────
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

  // ── Register push token ────────────────────────────────────────────────────
  Future<void> _onPushTokenReceived(
    PushTokenReceived event,
    Emitter<NotificationState> emit,
  ) async {
    await _registerPushToken(
      RegisterPushTokenParams(token: event.token, platform: event.platform),
    );
    // silent — no state change
  }

  // ── Foreground push received — reload list ────────────────────────────────
  void _onPushReceived(
    PushNotificationReceived event,
    Emitter<NotificationState> emit,
  ) {
    emit(NotificationPushReceived(title: event.title, body: event.body));
    add(LoadNotifications());
  }
}


