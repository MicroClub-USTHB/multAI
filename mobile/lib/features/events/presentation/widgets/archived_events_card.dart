import 'package:flutter/material.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/responsive_extensions.dart';
import '../../../../../core/extensions/datetime_extensions.dart';
import 'package:multai_mobile/core/theme/app_theme_colors.dart';
import 'package:multai_mobile/core/theme/app_theme_metrics.dart';
import 'package:multai_mobile/core/theme/app_theme_colors_light.dart';

class ArchivedEventsCard extends StatelessWidget {
  const ArchivedEventsCard({
    super.key,
    required this.eventTitle,
    required this.eventDate,
    this.onTap,
  });

  final String eventTitle;
  final DateTime eventDate;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tt = context.textTheme;
    final isDark = context.theme.brightness == Brightness.dark;

    final borderColor = isDark
        ? AppThemeColors.border
        : AppThemeColorsLight.border;

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(
          right: context.widthCalculated(AppThemeMetrics.spacingSm),
        ),
        child: SizedBox(
          // ✅ responsive width + height — no hardcoded values
          width: context.widthCalculated(191),
          height: context.heightCalculated(197),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppThemeMetrics.radiusMd),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: context.heightCalculated(AppThemeMetrics.spacingMd),
                ),

                // ── Title ────────────────────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.widthCalculated(
                      AppThemeMetrics.spacingSm,
                    ),
                  ),
                  child: Text(
                    eventTitle,
                    style: tt.labelMedium?.copyWith(
                      color: AppThemeColors.archivedTitle,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(
                  height: context.heightCalculated(AppThemeMetrics.spacingSm),
                ),

                // ── Date ─────────────────────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: context.heightCalculated(
                      AppThemeMetrics.spacingXs,
                    ),
                    horizontal: context.widthCalculated(
                      AppThemeMetrics.spacingSm,
                    ),
                  ),
                  child: Text(
                    eventDate.toDisplayDate(),
                    style: tt.bodySmall?.copyWith(
                      color: AppThemeColors.archivedDate,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
