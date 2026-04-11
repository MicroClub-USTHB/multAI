import 'package:flutter/material.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/responsive_extensions.dart';
import '../../../domain/entities/photo_approval_entity.dart';
import '../../../../../core/theme/theme.dart';
import 'decision_tile.dart';

class RecentDecisionsSection extends StatelessWidget {
  final List<PhotoApprovalEntity> decisions;

  const RecentDecisionsSection({super.key, required this.decisions});

  @override
  Widget build(BuildContext context) {
    final tt = context.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section title ──────────────────────────────────────────────
        Row(
          children: [
            Icon(
              Icons.history,
              size: context.iconSize() * 0.85,
              color: AppTheme.secondaryTextColor,
            ),
            SizedBox(width: context.widthCalculated(6)),
            Text(
              'RECENT DECISIONS',
              style: tt.labelMedium?.copyWith(
                color: AppTheme.secondaryTextColor,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        SizedBox(height: context.heightCalculated(12)),

        // ── Tiles ─────────────────────────────────────────────────────
        ...decisions.map(
          (decision) => DecisionTile(
            photoId: decision.photoId,
            decidedAt: decision.decidedAt,
            isApproved: decision.decision.isApproved,
          ),
        ),
      ],
    );
  }
}
