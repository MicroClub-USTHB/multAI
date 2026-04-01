import 'package:flutter/material.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/theme/theme.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationTile extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback onTap;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tt = context.textTheme;
    final cs = context.theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: context.heightCalculated(8)),
        padding: EdgeInsets.all(context.widthCalculated(14)),
        decoration: BoxDecoration(
          color: notification.isRead
              ? AppTheme.surfaceColor
              : cs.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: notification.isRead
                ? AppTheme.inputBorderColor
                : cs.primary.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── icon ───────────────────────────────────────────────────
            Container(
              padding: EdgeInsets.all(context.widthCalculated(8)),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: Icon(
                _iconFor(notification.type),
                size: context.iconSize(),
                color: cs.primary,
              ),
            ),
            SizedBox(width: context.widthCalculated(12)),

            // ── content ────────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: tt.titleSmall?.copyWith(
                      fontWeight: notification.isRead
                          ? FontWeight.w500
                          : FontWeight.bold,
                      color: AppTheme.primaryTextColor,
                    ),
                  ),
                  if (notification.body.isNotEmpty) ...[
                    SizedBox(height: context.heightCalculated(4)),
                    Text(
                      notification.body,
                      style: tt.labelSmall?.copyWith(
                        color: AppTheme.secondaryTextColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  SizedBox(height: context.heightCalculated(6)),
                  Text(
                    _timeAgo(notification.createdAt),
                    style: tt.labelSmall?.copyWith(
                      color: AppTheme.hintTextColor,
                    ),
                  ),
                ],
              ),
            ),

            // ── unread dot ─────────────────────────────────────────────
            if (!notification.isRead)
              Container(
                width: context.widthCalculated(8),
                height: context.widthCalculated(8),
                margin: EdgeInsets.only(top: context.heightCalculated(4)),
                decoration: BoxDecoration(
                  color: cs.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(NotificationType type) {
    switch (type) {
      case NotificationType.photoApproval:
        return Icons.verified_outlined;
      case NotificationType.photoDistributed:
        return Icons.image_outlined;
      case NotificationType.eventInvite:
        return Icons.calendar_month_outlined;
      case NotificationType.system:
        return Icons.info_outline;
      case NotificationType.unknown:
        return Icons.notifications_outlined;
    }
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}
