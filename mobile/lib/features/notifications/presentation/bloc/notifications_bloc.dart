import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure_handler.dart';
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
  final FailureHandler _failureHandler;

  NotificationBloc({
    required GetNotificationsUsecase getNotifications,
    required MarkAsReadUsecase markAsRead,
    required RegisterPushTokenUseCase registerPushToken,
    FailureHandler? failureHandler,
  }) : _getNotifications = getNotifications,
       _markAsRead = markAsRead,
       _failureHandler = failureHandler ?? FailureHandler.instance,
       super(NotificationInitial()) {
    on<LoadNotifications>(_onLoad);
    on<MarkNotificationRead>(_onMarkRead);
    on<MarkSingleNotificationRead>(_onMarkSingleRead);
    on<MarkAllNotificationsRead>(_onMarkAllRead);
    on<PushNotificationReceived>(_onPushReceived);
  }

  Future<void> _onLoad(
    LoadNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());

    final result = await _getNotifications(NoParams());
    result.fold((failure) {
      _failureHandler.logFailure(failure, 'NotificationBloc');
      emit(
        NotificationError(
          message: _failureHandler.getUserFriendlyMessage(failure),
        ),
      );
    }, (list) => emit(NotificationLoaded(notifications: list)));
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
              message: _failureHandler.getUserFriendlyMessage(failure),
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

  void _onPushReceived(
    PushNotificationReceived event,
    Emitter<NotificationState> emit,
  ) {
    emit(NotificationPushReceived(title: event.title, body: event.body));
    add(LoadNotifications());
  }
}
