import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/responsive_extensions.dart';
import 'package:multai_mobile/core/theme/app_theme_metrics.dart';
import '../../../notifications/domain/entities/notification_entity.dart';
import 'package:multai_mobile/core/theme/app_palette.dart';

class NotificationCard extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback onTap;

  const NotificationCard({
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
        margin: EdgeInsets.only(bottom: context.heightCalculated(10)),
        padding: EdgeInsets.all(context.widthCalculated(14)),
        decoration: BoxDecoration(
          color: notification.isRead
              ? context.colors.surface
              : cs.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppThemeMetrics.radiusMd),
          border: Border.all(
            color: notification.isRead
                ? context.colors.inputBorder
                : cs.primary.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── icon container ────────────────────────────────────────
            Container(
              padding: EdgeInsets.all(context.widthCalculated(10)),
              decoration: BoxDecoration(
                color: _iconBgColor(notification.type, cs, context.colors),
                borderRadius: BorderRadius.circular(AppThemeMetrics.radiusSm),
              ),
              child: Icon(
                _iconFor(notification.type),
                size: context.iconSize(),
                color: _iconColor(notification.type, cs, context.colors),
              ),
            ),
            SizedBox(width: context.widthCalculated(12)),

            // ── content ───────────────────────────────────────────────
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
                      color: context.colors.primaryText,
                    ),
                  ),
                  if (notification.body.isNotEmpty) ...[
                    SizedBox(height: context.heightCalculated(4)),
                    Text(
                      notification.body,
                      style: tt.labelSmall?.copyWith(
                        color: context.colors.secondaryText,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  SizedBox(height: context.heightCalculated(8)),

                  // ── CTA for photo approval ─────────────────────────
                  if (notification.type == NotificationType.photoApproval)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.widthCalculated(10),
                        vertical: context.heightCalculated(4),
                      ),
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(
                          AppThemeMetrics.radiusSm,
                        ),
                      ),
                      child: Text(
                        'Tap to review photo →',
                        style: tt.labelSmall?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                  SizedBox(height: context.heightCalculated(6)),
                  Text(
                    _timeAgo(notification.createdAt),
                    style: tt.labelSmall?.copyWith(
                      color: context.colors.hintText,
                    ),
                  ),
                ],
              ),
            ),

            // ── unread dot ────────────────────────────────────────────
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

  Color _iconBgColor(
    NotificationType type,
    ColorScheme cs,
    AppPalette colors,
  ) {
    switch (type) {
      case NotificationType.photoApproval:
        return colors.warning.withValues(alpha: 0.15);
      case NotificationType.photoDistributed:
        return colors.success.withValues(alpha: 0.15);
      default:
        return cs.primary.withValues(alpha: 0.15);
    }
  }

  Color _iconColor(NotificationType type, ColorScheme cs, AppPalette colors) {
    switch (type) {
      case NotificationType.photoApproval:
        return colors.warning;
      case NotificationType.photoDistributed:
        return colors.success;
      default:
        return cs.primary;
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
