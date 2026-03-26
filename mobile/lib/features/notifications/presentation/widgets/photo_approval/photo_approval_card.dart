import 'package:flutter/material.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/responsive_extensions.dart';


import '../../../../../core/theme/theme.dart';
import 'photo_stack_image.dart';
import 'decision_action_buttons.dart';
import 'info_banner.dart';

class PhotoApprovalCard extends StatelessWidget {
  const PhotoApprovalCard({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = context.textTheme;
    final cs = context.theme.colorScheme;

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
          // ── PHOTO APPROVAL label ──────────────────────────────────────
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

          // ── Photo ─────────────────────────────────────────────────────
          const PhotoStackImage(),
          SizedBox(height: context.heightCalculated(16)),

          // ── Title ─────────────────────────────────────────────────────
          Text(
            'You appeared in this photo\nwith 2 others',
            style: tt.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.heightCalculated(8)),

          // ── Subtitle ──────────────────────────────────────────────────
          Text(
            'Do you want this to be visible to\nothers in the photo?',
            style: tt.bodySmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.heightCalculated(20)),

          // ── Buttons ───────────────────────────────────────────────────
          DecisionActionButtons(onAccept: () {}, onReject: () {}),
          SizedBox(height: context.heightCalculated(16)),

          // ── Info banner ───────────────────────────────────────────────
          const InfoBanner(
            message: 'All users must accept for this photo to go public.',
          ),
        ],
      ),
    );
  }
}
