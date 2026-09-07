import 'package:flutter/material.dart';
import 'package:multai_mobile/core/theme/app_theme_colors.dart';
import 'package:multai_mobile/core/theme/app_theme_metrics.dart';

class EnrollmentProgress extends StatefulWidget {
  final int currentStep;
  final int totalSteps;
  final int completedRequired;
  final int totalRequired;

  const EnrollmentProgress({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.completedRequired,
    required this.totalRequired,
  });

  @override
  State<EnrollmentProgress> createState() => _EnrollmentProgressState();
}

class _EnrollmentProgressState extends State<EnrollmentProgress> {
  double _previousProgress = 0.0;

  @override
  void didUpdateWidget(EnrollmentProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentStep != widget.currentStep) {
      _previousProgress = oldWidget.totalSteps > 0
          ? (oldWidget.currentStep + 1) / oldWidget.totalSteps
          : 0.0;
    }
  }

  double get _progress => widget.totalSteps > 0
      ? (widget.currentStep + 1) / widget.totalSteps
      : 0.0;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Semantics(
      label: 'Step ${widget.currentStep + 1} of ${widget.totalSteps}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Step ${widget.currentStep + 1} of ${widget.totalSteps}',
            key: ValueKey('step_${widget.currentStep}'),
            style: tt.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppThemeColors.secondaryText,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppThemeMetrics.radiusSm),
            child: Semantics(
              value: '${(_progress * 100).toInt()} percent complete',
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: _previousProgress, end: _progress),
                duration: AppThemeMetrics.durationMedium,
                curve: AppThemeMetrics.curveStandard,
                builder: (context, value, _) {
                  return LinearProgressIndicator(
                    value: value,
                    backgroundColor: AppThemeColors.inputBorder,
                    color: AppThemeColors.primaryAccent,
                    minHeight: 4,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
