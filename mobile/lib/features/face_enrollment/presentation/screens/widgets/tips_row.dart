import 'package:flutter/material.dart';
import '../../../../../../core/extensions/extensions.dart';
import '../../../../../../core/theme/theme.dart';

class TipsRow extends StatelessWidget {
  const TipsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: context.widthCalculated(8),
      runSpacing: context.heightCalculated(8),
      children: const [
        _TipChip(label: 'No Blur', isDone: false),
        _TipChip(label: 'Single Face Only', isDone: false),
        _TipChip(label: 'Good Lighting', isDone: false),
      ],
    );
  }
}

class _TipChip extends StatelessWidget {
  final String label;
  final bool isDone;

  const _TipChip({required this.label, required this.isDone});

  @override
  Widget build(BuildContext context) {
    final tt = context.textTheme;

    // ── colors ──────────────────────────────────────────────────────────────
    final bgColor = isDone
        ? Colors.green.withValues(alpha: 0.15)
        : AppTheme.tipsBgColor;

    final iconColor = isDone ? Colors.green : AppTheme.secondaryTextColor;
    final textColor = isDone ? Colors.green : AppTheme.primaryTextColor;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.widthCalculated(12),
        vertical: context.heightCalculated(8),
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isDone ? Icons.check_circle_outline : Icons.warning_amber_rounded,
            size: context.iconSize() * 0.85,
            color: iconColor,
          ),
          SizedBox(width: context.widthCalculated(6)),
          Text(
            label,
            style: tt.labelMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
