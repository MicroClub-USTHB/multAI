import 'package:flutter/material.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/responsive_extensions.dart';
import '../../../../../core/theme/theme.dart';
import 'decision_tile.dart';

class RecentDecisionsSection extends StatelessWidget {
  const RecentDecisionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = context.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section title ────────────────────────────────────────────────
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

        // ── Tiles ────────────────────────────────────────────────────────
        const DecisionTile(
          title: 'Sunset Dinner Group',
          subtitle: '2 hours ago',
          status: DecisionStatus.approved,
        ),

        const DecisionTile(
          title: 'Birthday Bash 2024',
          subtitle: 'Yesterday',
          status: DecisionStatus.rejected,
        ),
      ],
    );
  }
}
