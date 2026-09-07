import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/responsive_extensions.dart';
import 'package:multai_mobile/core/theme/app_theme_colors.dart';
import 'package:multai_mobile/core/theme/app_theme_metrics.dart';

class BackupStatsCard extends StatelessWidget {
  final int photoCount;

  const BackupStatsCard({super.key, required this.photoCount});

  @override
  Widget build(BuildContext context) {
    final tt = context.textTheme;
    final cs = context.theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(context.widthCalculated(20)),
      decoration: BoxDecoration(
        color: AppThemeColors.surface,
        borderRadius: BorderRadius.circular(AppThemeMetrics.radiusLg),
        border: Border.all(
          color: AppThemeColors.border.withValues(alpha: 0.3),
          width: AppThemeMetrics.borderHairline,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(context.widthCalculated(12)),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppThemeMetrics.radiusMd),
            ),
            child: Icon(
              Icons.photo_library_outlined,
              size: context.iconSize() * 1.2,
              color: cs.primary,
            ),
          ),
          SizedBox(width: context.widthCalculated(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$photoCount',
                  style: tt.headlineMedium?.copyWith(
                    color: AppThemeColors.primaryText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: context.heightCalculated(2)),
                Text(
                  photoCount == 1 ? 'photo cached' : 'photos cached',
                  style: tt.bodyMedium?.copyWith(
                    color: AppThemeColors.secondaryText,
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
