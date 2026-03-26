import 'package:flutter/material.dart';
import '../../../../../core/extensions/responsive_extensions.dart';
import '../../../../../../../core/theme/theme.dart';
import '../../../../../core/extensions/context_extensions.dart';

enum DecisionStatus { approved, rejected }

class DecisionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final DecisionStatus status;
  final String? imageUrl;

  const DecisionTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.status,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final tt = context.textTheme;
    final isApproved = status == DecisionStatus.approved;

    // ── colors from AppTheme ────────────────────────────────────────────
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
          // ── thumbnail ────────────────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            child: imageUrl != null
                ? Image.network(
                    imageUrl!,
                    width: context.widthCalculated(48),
                    height: context.widthCalculated(48),
                    fit: BoxFit.cover,
                  )
                : Container(
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

          // ── title + subtitle ─────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: tt.titleSmall?.copyWith(
                    color: AppTheme.primaryTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: context.heightCalculated(2)),
                Text(
                  subtitle,
                  style: tt.labelSmall?.copyWith(
                    color: AppTheme.secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),

          // ── status badge ─────────────────────────────────────────────
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
}
