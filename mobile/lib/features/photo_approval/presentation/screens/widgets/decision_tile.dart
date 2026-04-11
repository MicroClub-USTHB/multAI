import 'package:flutter/material.dart';
import '../../../../../core/extensions/responsive_extensions.dart';
import '../../../../../../../core/theme/theme.dart';
import '../../../../../core/extensions/context_extensions.dart';

class DecisionTile extends StatelessWidget {
  final String photoId;
  final DateTime? decidedAt;
  final bool isApproved;

  const DecisionTile({
    super.key,
    required this.photoId,
    required this.isApproved,
    this.decidedAt,
  });

  @override
  Widget build(BuildContext context) {
    final tt = context.textTheme;

    final badgeColor = isApproved
        ? AppTheme.successColor.withValues(alpha: 0.15)
        : AppTheme.errorColor.withValues(alpha: 0.15);

    final badgeTextColor = isApproved
        ? AppTheme.successColor
        : AppTheme.errorColor;

    return Container(
      margin: EdgeInsets.only(bottom: context.heightCalculated(8)),
      padding: EdgeInsets.symmetric(
        horizontal: context.widthCalculated(12),
        vertical: context.heightCalculated(12),
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Row(
        children: [
          // ── thumbnail placeholder ──────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            child: Container(
              width: context.widthCalculated(48),
              height: context.widthCalculated(48),
              color: AppTheme.cardColor,
              child: Icon(
                Icons.image_outlined,
                size: context.iconSize(),
                color: AppTheme.secondaryTextColor,
              ),
            ),
          ),
          SizedBox(width: context.widthCalculated(12)),

          // ── photo id + time ────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Photo #${photoId.substring(0, 8)}',
                  style: tt.titleSmall?.copyWith(
                    color: AppTheme.primaryTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (decidedAt != null) ...[
                  SizedBox(height: context.heightCalculated(2)),
                  Text(
                    _timeAgo(decidedAt!),
                    style: tt.labelSmall?.copyWith(
                      color: AppTheme.secondaryTextColor,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ── status badge ───────────────────────────────────────────
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.widthCalculated(10),
              vertical: context.heightCalculated(4),
            ),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isApproved
                      ? Icons.check_circle_outline
                      : Icons.cancel_outlined,
                  size: context.iconSize() * 0.75,
                  color: badgeTextColor,
                ),
                SizedBox(width: context.widthCalculated(4)),
                Text(
                  isApproved ? 'Approved' : 'Rejected',
                  style: tt.labelSmall?.copyWith(
                    color: badgeTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}
