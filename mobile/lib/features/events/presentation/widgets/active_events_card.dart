import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/extensions/datetime_extensions.dart';

class ActiveEventsCard extends StatelessWidget {
  const ActiveEventsCard({
    super.key,
    required this.eventTitle,
    required this.eventStatus,
    required this.eventDate,
  });

  final String eventTitle;
  final String eventStatus;
  final DateTime eventDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppTheme.activeCardHeight,
      decoration: BoxDecoration(
        color: AppTheme.activeCardBackground
            .withValues(alpha: AppTheme.activeCardBackgroundOpacity),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: AppTheme.activeCardBorder,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: AppTheme.spacingSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: AppTheme.spacingMd,
                    bottom: AppTheme.spacingSm,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          eventTitle,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontSize: AppTheme.fontSizeMd,
                                color: AppTheme.primaryTextColor,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(right: AppTheme.spacingSm),
                        child: Text(
                          eventStatus,
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                fontSize: AppTheme.fontSizeSm,
                                color: AppTheme.successColor,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_month,
                        size: AppTheme.iconSm,
                        color: AppTheme.cardDateTextColor,
                      ),
                      const SizedBox(width: AppTheme.spacingXs),
                      Text(
                        eventDate.toDisplayDate(),
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium
                            ?.copyWith(
                              fontSize: AppTheme.fontSizeXs,
                              color: AppTheme.cardDateTextColor,
                            ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(right: AppTheme.spacingSm),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "View",
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: AppTheme.fontSizeLg,
                            color: AppTheme.primaryColor,
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}