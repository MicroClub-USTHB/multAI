import 'package:flutter/material.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/responsive_extensions.dart';
import 'decision_tile.dart';

class RecentDecisionsSection extends StatelessWidget {
  const RecentDecisionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.history, size: 18),
            const SizedBox(width: 6),
            Text(
              "RECENT DECISIONS",
              style: context.textTheme.labelMedium,
            ),
          ],
        ),

        SizedBox(height: context.hPadding()),

        const DecisionTile(
          title: "Sunset Dinner Group",
          subtitle: "2 hours ago",
          status: DecisionStatus.approved,
        ),

        const SizedBox(height: 12),

        const DecisionTile(
          title: "Beach Trip",
          subtitle: "Yesterday",
          status: DecisionStatus.rejected,
        ),
      ],
    );
  }
}