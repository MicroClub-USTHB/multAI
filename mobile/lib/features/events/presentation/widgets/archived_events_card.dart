import 'package:flutter/material.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/responsive_extensions.dart';
import '../../../../../core/extensions/datetime_extensions.dart';
import '../../../../../core/theme/theme.dart';
 
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
 
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(
          right: context.widthCalculated(AppTheme.spacingSm),
        ),
        child: SizedBox(
          // ✅ responsive width + height — no hardcoded values
          width:  context.widthCalculated(191),
          height: context.heightCalculated(197),
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
                SizedBox(height: context.heightCalculated(AppTheme.spacingMd)),
 
                // ── Title ────────────────────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.widthCalculated(AppTheme.spacingSm),
                  ),
                  child: Text(
                    eventTitle,
                    style: tt.labelMedium?.copyWith(
                      color: AppTheme.archivedTitleColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(height: context.heightCalculated(AppTheme.spacingSm)),
 
                // ── Date ─────────────────────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical:   context.heightCalculated(AppTheme.spacingXs),
                    horizontal: context.widthCalculated(AppTheme.spacingSm),
                  ),
                  child: Text(
                    eventDate.toDisplayDate(),
                    style: tt.bodySmall?.copyWith(
                      color: AppTheme.archivedDateColor,
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