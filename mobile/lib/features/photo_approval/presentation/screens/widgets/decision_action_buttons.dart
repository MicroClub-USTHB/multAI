import 'package:flutter/material.dart';

import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/responsive_extensions.dart';
import '../../../../../core/theme/theme.dart';

class DecisionActionButtons extends StatelessWidget {
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const DecisionActionButtons({
    super.key,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final tt = context.textTheme;
    final cs = context.theme.colorScheme;

    return Column(
      children: [
        // ── Accept ─────────────────────────────────────────────────────
        SizedBox(
          width: double.infinity,
          height: context.heightCalculated(52),
          child: ElevatedButton(
            onPressed: onAccept,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: cs.onPrimary,
                  size: context.iconSize(),
                ),
                SizedBox(width: context.widthCalculated(8)),
                Text(
                  'Accept',
                  style: tt.titleMedium?.copyWith(
                    color: cs.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: context.heightCalculated(12)),

        // ── Reject ─────────────────────────────────────────────────────
        SizedBox(
          width: double.infinity,
          height: context.heightCalculated(52),
          child: OutlinedButton(
            onPressed: onReject,
            child: Text(
              'Reject',
              style: tt.titleMedium?.copyWith(
                color: AppTheme.primaryTextColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
