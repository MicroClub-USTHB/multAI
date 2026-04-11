import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/snackbar_extensions.dart';
import '../../../../core/extensions/responsive_extensions.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/theme.dart';
import '../bloc/notifications_bloc.dart';
import '../../domain/entities/notification_entity.dart';
import '../widgets/notification_card.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NotificationBloc, NotificationState>(
      listener: (context, state) {
        if (state is NotificationPushReceived) {
          context.showSuccessSnackBar(state.title);
        }
        if (state is NotificationError) {
          context.showErrorSnackBar(state.message);
        }
      },
      builder: (context, state) {
        final tt = context.textTheme;
        final cs = context.theme.colorScheme;

        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          appBar: AppBar(
            backgroundColor: AppTheme.backgroundColor,
            elevation: 0,
            centerTitle: true,
            title: Text(
              'Notifications',
              style: tt.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryTextColor,
              ),
            ),
            actions: [
              if (state is NotificationLoaded && state.unreadCount > 0)
                TextButton(
                  onPressed: () => context.read<NotificationBloc>().add(
                    MarkAllNotificationsRead(),
                  ),
                  child: Text(
                    'Mark all read',
                    style: tt.labelMedium?.copyWith(color: cs.primary),
                  ),
                ),
            ],
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, NotificationState state) {
    final cs = context.theme.colorScheme;

    if (state is NotificationInitial) {
      context.read<NotificationBloc>().add(LoadNotifications());
      return Center(child: CircularProgressIndicator(color: cs.primary));
    }

    if (state is NotificationLoading) {
      return Center(child: CircularProgressIndicator(color: cs.primary));
    }

    if (state is NotificationLoaded) {
      if (state.notifications.isEmpty) return _buildEmpty(context);

      return RefreshIndicator(
        color: cs.primary,
        onRefresh: () async =>
            context.read<NotificationBloc>().add(LoadNotifications()),
        child: ListView.builder(
          padding: EdgeInsets.symmetric(
            horizontal: context.hPadding(),
            vertical: context.heightCalculated(12),
          ),
          itemCount: state.notifications.length,
          itemBuilder: (context, index) {
            final notification = state.notifications[index];
            return NotificationCard(
              notification: notification,
              onTap: () => _onNotificationTap(context, notification),
            );
          },
        ),
      );
    }

    return const SizedBox.shrink();
  }

  // ── Handle tap based on notification type ─────────────────────────────────
  void _onNotificationTap(
    BuildContext context,
    NotificationEntity notification,
  ) {
    // mark as read
    if (!notification.isRead) {
      context.read<NotificationBloc>().add(
        MarkNotificationRead(notificationIds: [notification.id]),
      );
    }

    // navigate based on type
    switch (notification.type) {
      case NotificationType.photoApproval:
        context.push(AppRoutes.photoApproval);
        break;
      case NotificationType.photoDistributed:
        context.push(AppRoutes.gallery);
        break;
      case NotificationType.eventInvite:
        context.push(AppRoutes.events);
        break;
      case NotificationType.system:
      case NotificationType.unknown:
        break;
    }
  }

  Widget _buildEmpty(BuildContext context) {
    final tt = context.textTheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_outlined,
            size: context.iconSize() * 3,
            color: AppTheme.secondaryTextColor.withValues(alpha: 0.4),
          ),
          SizedBox(height: context.heightCalculated(16)),
          Text(
            'No notifications yet',
            style: tt.titleMedium?.copyWith(color: AppTheme.secondaryTextColor),
          ),
          SizedBox(height: context.heightCalculated(8)),
          Text(
            "We'll notify you when something happens",
            style: tt.bodySmall?.copyWith(color: AppTheme.hintTextColor),
          ),
        ],
      ),
    );
  }
}
