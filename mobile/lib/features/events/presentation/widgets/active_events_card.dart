import 'package:flutter/material.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/responsive_extensions.dart';
import '../../../../../core/extensions/datetime_extensions.dart';
import '../../../../../core/theme/theme.dart';

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
          color: AppTheme.activeCardBackground.withValues(
            alpha: AppTheme.activeCardBackgroundOpacity,
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: AppTheme.activeCardBorder, width: 1),
        ),
        child: Row(
          children: [
            SizedBox(width: context.widthCalculated(AppTheme.spacingSm)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Title + status ─────────────────────────────────
                  Padding(
                    padding: EdgeInsets.only(
                      top: context.heightCalculated(AppTheme.spacingMd),
                      bottom: context.heightCalculated(AppTheme.spacingSm),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            eventTitle,
                            style: tt.titleMedium?.copyWith(
                              color: AppTheme.primaryTextColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            right: context.widthCalculated(AppTheme.spacingSm),
                          ),
                          child: Text(
                            eventStatus,
                            style: tt.labelSmall?.copyWith(
                              color: AppTheme.successColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Date ──────────────────────────────────────────
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: context.heightCalculated(AppTheme.spacingMd),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_month,
                          size: context.iconSize() * 0.8,
                          color: AppTheme.cardDateTextColor,
                        ),
                        SizedBox(
                          width: context.widthCalculated(AppTheme.spacingXs),
                        ),
                        Text(
                          eventDate.toDisplayDate(),
                          style: tt.labelSmall?.copyWith(
                            color: AppTheme.cardDateTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── View link ──────────────────────────────────────
                  Padding(
                    padding: EdgeInsets.only(
                      right: context.widthCalculated(AppTheme.spacingSm),
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
