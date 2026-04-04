import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/extensions/datetime_extensions.dart';

class ArchivedEventsCard extends StatelessWidget {
  const ArchivedEventsCard({
    super.key,
    required this.eventTitle,
    required this.eventDate,
  });

  final String eventTitle;
  final DateTime eventDate;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(right: AppTheme.spacingSm),
      child: SizedBox(
        width: AppTheme.archivedCardWidth,
        height: AppTheme.archivedCardHeight,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppTheme.archivedCardBackground
                .withValues(alpha: AppTheme.archivedCardBackgroundOpacity),
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(
              color: AppTheme.archivedCardBorder
                  .withValues(alpha: AppTheme.archivedCardBorderOpacity),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppTheme.spacingMd),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingSm),
                child: Text(
                  eventTitle,
                  style: textTheme.labelMedium?.copyWith(
                    color: AppTheme.archivedTitleColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: AppTheme.spacingSm),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppTheme.spacingXs,
                  horizontal: AppTheme.spacingSm,
                ),
                child: Text(
                  eventDate.toDisplayDate(),
                  style: textTheme.bodySmall?.copyWith(
                    color: AppTheme.archivedDateColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}