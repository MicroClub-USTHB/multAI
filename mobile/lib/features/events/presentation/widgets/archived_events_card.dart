import 'package:flutter/material.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/responsive_extensions.dart';
import '../../../../../core/extensions/datetime_extensions.dart';
import 'package:multai_mobile/core/theme/app_theme_metrics.dart';
import 'package:multai_mobile/core/theme/app_palette.dart';
import 'event_cover_image.dart';

class ArchivedEventsCard extends StatelessWidget {
  const ArchivedEventsCard({
    super.key,
    required this.eventId,
    required this.eventTitle,
    required this.eventDate,
    this.onTap,
  });

  final String eventId;
  final String eventTitle;
  final DateTime eventDate;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tt = context.textTheme;
    final borderColor = context.colors.border;

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
                Padding(
                  padding: EdgeInsets.all(
                    context.widthCalculated(AppThemeMetrics.spacingSm),
                  ),
                  child: EventCoverImage(
                    eventId: eventId,
                    width:
                        context.widthCalculated(191) -
                        context.widthCalculated(AppThemeMetrics.spacingSm) * 2,
                    height: context.heightCalculated(80),
                  ),
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
                      color: context.colors.archivedTitle,
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
                      color: context.colors.archivedDate,
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
