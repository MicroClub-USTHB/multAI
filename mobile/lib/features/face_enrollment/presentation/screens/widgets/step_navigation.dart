import 'package:flutter/material.dart';
import 'package:multai_mobile/core/extensions/context_extensions.dart';
import 'package:multai_mobile/core/extensions/responsive_extensions.dart';
import 'package:multai_mobile/core/theme/app_theme_colors.dart';
import 'package:multai_mobile/core/theme/app_theme_metrics.dart';

class StepNavigation extends StatelessWidget {
  final bool canGoPrevious;
  final bool canGoNext;
  final bool isLastPage;
  final bool isOptional;
  final bool allRequiredDone;
  final bool isSubmitting;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback? onSkipOptional;
  final VoidCallback? onSubmit;

  const StepNavigation({
    super.key,
    required this.canGoPrevious,
    required this.canGoNext,
    this.isLastPage = false,
    this.isOptional = false,
    this.allRequiredDone = false,
    this.isSubmitting = false,
    this.onPrevious,
    this.onNext,
    this.onSkipOptional,
    this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final tt = context.textTheme;
    final cs = context.theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Skip optional
        if (isOptional && onSkipOptional != null)
          Padding(
            padding: EdgeInsets.only(
              bottom: context.heightCalculated(12),
            ),
            child: Semantics(
              label: 'Skip optional photos',
              button: true,
              child: SizedBox(
                height: 44,
                child: TextButton(
                  onPressed: isSubmitting ? null : onSkipOptional,
                  child: Text(
                    'Skip Optional Photos',
                    style: tt.labelLarge?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.6),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ),
          ),

        // Submit button
        if (isLastPage || (allRequiredDone && isOptional))
          Semantics(
            label: isSubmitting
                ? 'Submitting enrollment'
                : allRequiredDone
                    ? 'Complete enrollment'
                    : 'Upload required photos first',
            button: true,
            child: SizedBox(
              width: double.infinity,
              height: context.heightCalculated(54),
              child: ElevatedButton(
                onPressed:
                    allRequiredDone && !isSubmitting ? onSubmit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: allRequiredDone
                      ? AppThemeColors.primaryAccent
                      : AppThemeColors.enrollDisabled,
                  foregroundColor:
                      allRequiredDone ? Colors.black : Colors.white,
                  disabledBackgroundColor: AppThemeColors.enrollDisabled,
                  disabledForegroundColor:
                      Colors.white.withValues(alpha: 0.6),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppThemeMetrics.radiusMd),
                  ),
                  elevation: allRequiredDone ? 1 : 0,
                ),
                child: AnimatedSwitcher(
                  duration: AppThemeMetrics.durationFast,
                  child: isSubmitting
                      ? Row(
                          key: const ValueKey('submitting'),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: context.heightCalculated(20),
                              width: context.heightCalculated(20),
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: cs.onPrimary,
                              ),
                            ),
                            SizedBox(
                                width: context.widthCalculated(10)),
                            Text(
                              'Uploading...',
                              style: tt.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          key: const ValueKey('submit'),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              allRequiredDone
                                  ? 'Complete Enrollment'
                                  : 'Upload Required Photos',
                              style: tt.titleLarge?.copyWith(
                                color: allRequiredDone
                                    ? Colors.black
                                    : Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (allRequiredDone) ...[
                              SizedBox(
                                  width: context.widthCalculated(6)),
                              Icon(
                                Icons.arrow_forward,
                                color: Colors.black,
                                size: context.iconSize(),
                              ),
                            ],
                          ],
                        ),
                ),
              ),
            ),
          ),

        // Previous / Next row
        if (!isLastPage)
          Padding(
            padding: EdgeInsets.only(
              top: context.heightCalculated(isOptional ? 4 : 12),
            ),
            child: Row(
              children: [
                // Previous
                Semantics(
                  label: 'Previous step',
                  button: true,
                  child: AnimatedOpacity(
                    opacity: canGoPrevious ? 1.0 : 0.0,
                    duration: AppThemeMetrics.durationFast,
                    child: SizedBox(
                      height: 44,
                      child: TextButton.icon(
                        onPressed:
                            canGoPrevious && !isSubmitting ? onPrevious : null,
                        icon: Icon(
                          Icons.arrow_back,
                          size: context.iconSize() * 0.9,
                        ),
                        label: Text(
                          'Previous',
                          style: tt.labelLarge,
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                // Next
                Semantics(
                  label: isOptional
                      ? 'Skip to next step'
                      : 'Next step',
                  button: true,
                  child: SizedBox(
                    height: 44,
                    child: TextButton.icon(
                      onPressed:
                          canGoNext && !isSubmitting ? onNext : null,
                      iconAlignment: IconAlignment.end,
                      icon: Icon(
                        Icons.arrow_forward,
                        size: context.iconSize() * 0.9,
                      ),
                      label: Text(
                        'Next',
                        style: tt.labelLarge?.copyWith(
                          color: canGoNext
                              ? AppThemeColors.primaryAccent
                              : cs.onSurface.withValues(alpha: 0.38),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
