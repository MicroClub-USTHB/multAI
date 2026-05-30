import 'package:flutter/material.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/responsive_extensions.dart';
import '../../../../../core/extensions/datetime_extensions.dart';
import 'package:multai_mobile/core/theme/app_theme_metrics.dart';
import 'package:multai_mobile/core/theme/app_theme_colors.dart';

class ActiveEventsCard extends StatelessWidget {
  const ActiveEventsCard({
    super.key,
    required this.eventTitle,
    required this.eventStatus,
    required this.eventDate,
    this.onTap,
  });

  final String eventTitle;
  final String eventStatus;
  final DateTime eventDate;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tt = context.textTheme;
    final cs = context.theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: context.heightCalculated(120),
        decoration: BoxDecoration(
          color: AppThemeColors.activeCardBackground.withValues(
            alpha: AppThemeColors.activeCardBackgroundOpacity,
          ),
          borderRadius: BorderRadius.circular(AppThemeMetrics.radiusMd),
          border: Border.all(color: AppThemeColors.activeCardBorder, width: 1),
        ),
        child: Row(
          children: [
            SizedBox(width: context.widthCalculated(AppThemeMetrics.spacingSm)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Title + status ─────────────────────────────────
                  Padding(
                    padding: EdgeInsets.only(
                      top: context.heightCalculated(AppThemeMetrics.spacingMd),
                      bottom: context.heightCalculated(
                        AppThemeMetrics.spacingSm,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            eventTitle,
                            style: tt.titleMedium?.copyWith(
                              color: AppThemeColors.primaryText,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            right: context.widthCalculated(
                              AppThemeMetrics.spacingSm,
                            ),
                          ),
                          child: Text(
                            eventStatus,
                            style: tt.labelSmall?.copyWith(
                              color: AppThemeColors.success,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Date ──────────────────────────────────────────
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: context.heightCalculated(
                        AppThemeMetrics.spacingMd,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_month,
                          size: context.iconSize() * 0.8,
                          color: AppThemeColors.cardDateText,
                        ),
                        SizedBox(
                          width: context.widthCalculated(
                            AppThemeMetrics.spacingXs,
                          ),
                        ),
                        Text(
                          eventDate.toDisplayDate(),
                          style: tt.labelSmall?.copyWith(
                            color: AppThemeColors.cardDateText,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── View link ──────────────────────────────────────
                  Padding(
                    padding: EdgeInsets.only(
                      right: context.widthCalculated(AppThemeMetrics.spacingSm),
                    ),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'View',
                        style: tt.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: cs.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
