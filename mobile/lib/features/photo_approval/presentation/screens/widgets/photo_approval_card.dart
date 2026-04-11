import 'package:flutter/material.dart';
import 'package:multai_mobile/features/photo_approval/domain/entities/photo_approval_entity.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/responsive_extensions.dart';

import '../../../../../core/theme/theme.dart';
import 'decision_action_buttons.dart';
import 'info_banner.dart';

class PhotoApprovalCard extends StatelessWidget {
  final PhotoApprovalEntity approval;
  final bool isDeciding;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const PhotoApprovalCard({
    super.key,
    required this.approval,
    required this.isDeciding,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final tt = context.textTheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.widthCalculated(16)),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.inputBorderColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── PHOTO APPROVAL label ────────────────────────────────────
          Row(
            children: [
              Icon(
                Icons.verified_outlined,
                size: context.iconSize() * 0.85,
                color: AppTheme.warningColor,
              ),
              SizedBox(width: context.widthCalculated(6)),
              Text(
                'PHOTO APPROVAL',
                style: tt.labelSmall?.copyWith(
                  color: AppTheme.warningColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          SizedBox(height: context.heightCalculated(12)),

          // ── Photo placeholder (will be real image when photo URL added) ──
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            child: Container(
              width: double.infinity,
              height: context.heightCalculated(220),
              color: AppTheme.cardColor,
              child: Icon(
                Icons.image_outlined,
                size: context.iconSize() * 3,
                color: AppTheme.secondaryTextColor.withValues(alpha: 0.3),
              ),
            ),
          ),
          SizedBox(height: context.heightCalculated(16)),

          // ── Title ──────────────────────────────────────────────────
          Text(
            'You appeared in this photo',
            style: tt.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.heightCalculated(8)),

          // ── Subtitle ───────────────────────────────────────────────
          Text(
            'Do you want this to be visible to\nothers in the photo?',
            style: tt.bodySmall?.copyWith(
              color: context.theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.heightCalculated(20)),

          // ── Buttons ────────────────────────────────────────────────
          isDeciding
              ? Center(
                  child: CircularProgressIndicator(
                    color: context.theme.colorScheme.primary,
                  ),
                )
              : DecisionActionButtons(onAccept: onAccept, onReject: onReject),
          SizedBox(height: context.heightCalculated(16)),

          // ── Info ───────────────────────────────────────────────────
          const InfoBanner(
            message: 'All users must accept for this photo to go public.',
          ),
        ],
      ),
    );
  }
}
