import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/mark_as_read_usecase.dart';
import '../../domain/usecases/mark_all_as_read_usecase.dart';
import '../../domain/usecases/register_push_token_usecase.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetNotificationsUsecase _getNotifications;
  final MarkAsReadUsecase _markAsRead;
  final MarkAllAsReadUsecase _markAllAsRead;
  final RegisterPushTokenUseCase _registerPushToken;

  NotificationBloc({
    required GetNotificationsUsecase getNotifications,
    required MarkAsReadUsecase markAsRead,
    required MarkAllAsReadUsecase markAllAsRead,
    required RegisterPushTokenUseCase registerPushToken,
  }) : _getNotifications = getNotifications,
       _markAsRead = markAsRead,
       _markAllAsRead = markAllAsRead,
       _registerPushToken = registerPushToken,
       super(NotificationInitial()) {
    on<LoadNotifications>(_onLoad);
    on<MarkNotificationRead>(_onMarkRead);
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

  // ── Mark one read ──────────────────────────────────────────────────────────
  Future<void> _onMarkRead(
    MarkNotificationRead event,
    Emitter<NotificationState> emit,
  ) async {
    final currentState = state;
    if (currentState is! NotificationLoaded) return;

    await _markAsRead(MarkAsReadParams(notificationId: event.notificationId));

    // update local state without re-fetching
    final updated = currentState.notifications.map((n) {
      if (n.id == event.notificationId) {
        return NotificationEntity(
          id: n.id,
          userId: n.userId,
          type: n.type,
          payload: n.payload,
          readAt: DateTime.now(),
          createdAt: n.createdAt,
        );
      }
      return n;
    }).toList();

    emit(NotificationLoaded(notifications: updated));
  }

  // ── Mark all read ──────────────────────────────────────────────────────────
  Future<void> _onMarkAllRead(
    MarkAllNotificationsRead event,
    Emitter<NotificationState> emit,
  ) async {
    final currentState = state;
    if (currentState is! NotificationLoaded) return;

    await _markAllAsRead(NoParams());

    final now = DateTime.now();
    final updated = currentState.notifications.map((n) {
      return NotificationEntity(
        id: n.id,
        userId: n.userId,
        type: n.type,
        payload: n.payload,
        readAt: n.readAt ?? now,
        createdAt: n.createdAt,
      );
    }).toList();

    emit(NotificationLoaded(notifications: updated));
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

  // ── Foreground push received ───────────────────────────────────────────────
  void _onPushReceived(
    PushNotificationReceived event,
    Emitter<NotificationState> emit,
  ) {
    emit(NotificationPushReceived(title: event.title, body: event.body));

    // reload notifications list
    add(LoadNotifications());
  }
}
