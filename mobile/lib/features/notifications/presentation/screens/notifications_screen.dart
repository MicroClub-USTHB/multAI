import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/snackbar_extensions.dart';
import '../../../../core/extensions/responsive_extensions.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/errors/error_presentation.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../features/auth/presentation/blocs/auth_bloc.dart';
import 'package:multai_mobile/core/theme/app_theme_colors.dart';
import '../bloc/notifications_bloc.dart';
import '../../domain/entities/notification_entity.dart';
import '../widgets/notification_card.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _initialLoad = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialLoad) {
      _initialLoad = false;
      context.read<NotificationBloc>().add(LoadNotifications());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NotificationBloc, NotificationState>(
      listener: (context, state) {
        if (state is NotificationPushReceived) {
          context.showSuccessSnackBar(state.title);
        }
        if (state is NotificationError) {
          context.showErrorSnackBar(state.errorPresentation.description);
        }
      },
      builder: (context, state) {
        final tt = context.textTheme;
        final cs = context.theme.colorScheme;

        return Scaffold(
          backgroundColor: AppThemeColors.background,
          appBar: AppBar(
            backgroundColor: AppThemeColors.background,
            elevation: 0,
            centerTitle: true,
            title: Text(
              'Notifications',
              style: tt.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppThemeColors.primaryText,
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

    if (state is NotificationInitial || state is NotificationLoading) {
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

    if (state is NotificationOffline) {
      return ErrorStateView(
        title: 'No Internet Connection',
        description: 'Please check your internet connection and try again.',
        illustration: Icons.wifi_off_rounded,
        actionLabel: 'Retry',
        onAction: () =>
            context.read<NotificationBloc>().add(LoadNotifications()),
      );
    }

    if (state is NotificationError) {
      final p = state.errorPresentation;
      return ErrorStateView(
        title: p.title,
        description: p.description,
        illustration: p.illustration,
        actionLabel: p.actionLabel,
        onAction: p.action == ErrorAction.retry
            ? () => context.read<NotificationBloc>().add(LoadNotifications())
            : p.action == ErrorAction.signIn
            ? () {
                context.read<AuthBloc>().add(LogoutRequested());
                context.go(AppRoutes.login);
              }
            : p.action == ErrorAction.goBack
            ? () => context.pop()
            : null,
      );
    }

    return const SizedBox.shrink();
  }

  void _onNotificationTap(
    BuildContext context,
    NotificationEntity notification,
  ) {
    if (!notification.isRead) {
      context.read<NotificationBloc>().add(
        MarkNotificationRead(notificationIds: [notification.id]),
      );
    }

    switch (notification.type) {
      case NotificationType.photoApproval:
        final photoId = notification.payload['photo_id'];
        if (photoId != null) {
          context.push('${AppRoutes.photoApproval}?photoId=$photoId');
        } else {
          context.push(AppRoutes.photoApproval);
        }
      case NotificationType.photoDistributed:
        context.push(AppRoutes.gallery);
      case NotificationType.eventInvite:
        context.push(AppRoutes.events);
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
            color: AppThemeColors.secondaryText.withValues(alpha: 0.4),
          ),
          SizedBox(height: context.heightCalculated(16)),
          Text(
            'No notifications yet',
            style: tt.titleMedium?.copyWith(
              color: AppThemeColors.secondaryText,
            ),
          ),
          SizedBox(height: context.heightCalculated(8)),
          Text(
            "We'll notify you when something happens",
            style: tt.bodySmall?.copyWith(color: AppThemeColors.hintText),
          ),
        ],
      ),
    );
  }
}
