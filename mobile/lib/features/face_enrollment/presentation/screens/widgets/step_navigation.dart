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
    final showSubmit = isLastPage;
    final canSubmit = allRequiredDone && !isSubmitting;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.hPadding(),
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: AppThemeColors.background,
        border: Border(
          top: BorderSide(
            color: AppThemeColors.divider.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Previous
            Semantics(
              label: 'Previous step',
              button: true,
              child: AnimatedOpacity(
                opacity: canGoPrevious ? 1.0 : 0.0,
                duration: AppThemeMetrics.durationFast,
                child: TextButton(
                  onPressed: canGoPrevious && !isSubmitting
                      ? onPrevious
                      : null,
                  style: TextButton.styleFrom(
                    foregroundColor: cs.onSurface.withValues(alpha: 0.7),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text('Previous'),
                ),
              ),
            ),

            const Spacer(),

            // Skip optional
            if (isOptional && allRequiredDone && !isLastPage && onSkipOptional != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Semantics(
                  label: 'Skip optional photos',
                  button: true,
                  child: TextButton(
                    onPressed: isSubmitting ? null : onSkipOptional,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 10,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Skip',
                      style: tt.labelMedium?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.5),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ),

            // Next / Submit
            Semantics(
              label: showSubmit
                  ? (canSubmit
                      ? 'Complete enrollment'
                      : 'Upload required photos first')
                  : 'Next step',
              button: true,
              child: AnimatedContainer(
                duration: AppThemeMetrics.durationFast,
                curve: AppThemeMetrics.curveStandard,
                child: showSubmit
                    ? ElevatedButton(
                        onPressed: canSubmit ? onSubmit : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: canSubmit
                              ? AppThemeColors.primaryAccent
                              : AppThemeColors.enrollDisabled,
                          foregroundColor:
                              canSubmit ? Colors.black : Colors.white,
                          disabledBackgroundColor:
                              AppThemeColors.enrollDisabled,
                          disabledForegroundColor:
                              Colors.white.withValues(alpha: 0.6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppThemeMetrics.radiusMd,
                            ),
                          ),
                          elevation: canSubmit ? 1 : 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: isSubmitting
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: cs.onPrimary,
                                ),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    canSubmit
                                        ? 'Complete'
                                        : 'Upload Required',
                                    style: tt.labelLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: canSubmit
                                          ? Colors.black
                                          : Colors.white,
                                    ),
                                  ),
                                  if (canSubmit) ...[
                                    const SizedBox(width: 6),
                                    Icon(
                                      Icons.arrow_forward,
                                      color: Colors.black,
                                      size: context.iconSize() * 0.8,
                                    ),
                                  ],
                                ],
                              ),
                      )
                    : ElevatedButton(
                        onPressed: canGoNext && !isSubmitting
                            ? onNext
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: canGoNext
                              ? AppThemeColors.primaryAccent
                              : AppThemeColors.enrollDisabled,
                          foregroundColor:
                              canGoNext ? Colors.black : Colors.white,
                          disabledBackgroundColor:
                              AppThemeColors.enrollDisabled,
                          disabledForegroundColor:
                              Colors.white.withValues(alpha: 0.6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppThemeMetrics.radiusMd,
                            ),
                          ),
                          elevation: canGoNext ? 1 : 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Next',
                              style: tt.labelLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color:
                                    canGoNext ? Colors.black : Colors.white,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              Icons.arrow_forward,
                              color:
                                  canGoNext ? Colors.black : Colors.white,
                              size: context.iconSize() * 0.8,
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
