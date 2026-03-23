import 'package:flutter/material.dart';

import '../../../../../../core/extensions/extensions.dart';
import '../../../../../../core/theme/theme.dart';
 
class StepProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
 
  const StepProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });
 
  double get _progress => currentStep / totalSteps;
 
  @override
  Widget build(BuildContext context) {
    final tt = context.textTheme;
    final cs = context.theme.colorScheme;
 
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Step $currentStep of $totalSteps',
              style: tt.labelMedium?.copyWith(color: cs.onSurface),
            ),
            Text(
              '${(_progress * 100).toInt()}%',
              style: tt.labelMedium?.copyWith(color: cs.primary),
            ),
          ],
        ),
        SizedBox(height: context.heightCalculated(8)),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          child: LinearProgressIndicator(
            value: _progress,
            backgroundColor: AppTheme.inputBorderColor,
            color: cs.primary,
            minHeight: context.heightCalculated(4),
          ),
        ),
      ],
    );
  }
}
 
