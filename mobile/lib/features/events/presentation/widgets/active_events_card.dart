import 'package:flutter/material.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/responsive_extensions.dart';
import '../../../../../core/extensions/datetime_extensions.dart';
import 'package:multai_mobile/core/theme/app_theme_metrics.dart';

class ActiveEventsCard extends StatelessWidget {
  const ActiveEventsCard({
    super.key,
    required this.eventTitle,
    required this.eventStatus,
    required this.eventDate,
    this.endDate,
    this.onTap,
  });

  final String eventTitle;
  final String eventStatus;
  final DateTime eventDate;
  final DateTime? endDate;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tt = context.textTheme;

    final dateLabel = endDate != null
        ? '${eventDate.toDisplayDate()} - ${endDate!.toDisplayDate()}'
        : eventDate.toDisplayDate();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: context.heightCalculated(120),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppThemeMetrics.radiusMd),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 1,
          ),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: context.widthCalculated(AppThemeMetrics.spacingMd),
          vertical: context.heightCalculated(AppThemeMetrics.spacingMd),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // ── Title + status ─────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    eventTitle,
                    style: tt.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(
                  width: context.widthCalculated(AppThemeMetrics.spacingSm),
                ),
                Text(
                  eventStatus,
                  style: tt.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),

            // ── Date ────────────────────────────────────────────────────
            Row(
              children: [
                Icon(
                  Icons.calendar_month,
                  size: context.iconSize() * 0.8,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                SizedBox(
                  width: context.widthCalculated(AppThemeMetrics.spacingXs),
                ),
                Expanded(
                  child: Text(
                    dateLabel,
                    style: tt.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
