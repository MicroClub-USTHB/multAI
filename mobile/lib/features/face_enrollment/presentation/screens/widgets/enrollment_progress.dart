import 'package:flutter/material.dart';
import 'package:multai_mobile/core/extensions/context_extensions.dart';
import 'package:multai_mobile/core/extensions/responsive_extensions.dart';
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

  double get _progress => widget.totalSteps > 0 ? (widget.currentStep + 1) / widget.totalSteps : 0.0;
  bool get _allRequiredDone => widget.completedRequired >= widget.totalRequired;

  @override
  Widget build(BuildContext context) {
    final tt = context.textTheme;

    return Semantics(
      label: 'Step ${widget.currentStep + 1} of ${widget.totalSteps}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Semantics(
                header: true,
                child: Text(
                  'Identity Verification',
                  style: tt.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppThemeColors.secondaryText,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              if (_allRequiredDone)
                Semantics(
                  label: 'All required photos complete',
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: context.iconSize() * 0.7,
                        color: AppThemeColors.success,
                      ),
                      SizedBox(width: context.widthCalculated(4)),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: context.heightCalculated(4)),
          // Step counter
          AnimatedSwitcher(
            duration: AppThemeMetrics.durationMedium,
              transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SizeTransition(
                sizeFactor: animation,
                alignment: const Alignment(-1, 0),
                child: child,
              ),
            ),
            child: Text(
              'Step ${widget.currentStep + 1} of ${widget.totalSteps}',
              key: ValueKey('step_${widget.currentStep}'),
              style: tt.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppThemeColors.primaryText,
              ),
            ),
          ),
          SizedBox(height: context.heightCalculated(8)),
          // Progress bar
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
                    color: _allRequiredDone
                        ? AppThemeColors.success
                        : AppThemeColors.primaryAccent,
                    minHeight: context.heightCalculated(6),
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
