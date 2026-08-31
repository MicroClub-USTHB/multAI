import 'package:flutter/material.dart';
import 'package:multai_mobile/core/extensions/context_extensions.dart';
import 'package:multai_mobile/core/extensions/responsive_extensions.dart';
import 'package:multai_mobile/core/theme/app_theme_colors.dart';
import 'package:multai_mobile/core/theme/app_theme_metrics.dart';
import '../../domain/entities/album_entity.dart';

class AlbumCard extends StatelessWidget {
  final AlbumEntity album;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const AlbumCard({
    super.key,
    required this.album,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final tt = context.textTheme;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onDelete,
      child: Container(
        decoration: BoxDecoration(
          color: AppThemeColors.surface,
          borderRadius: BorderRadius.circular(AppThemeMetrics.radiusLg),
          border: Border.all(
            color: AppThemeColors.border.withValues(alpha: 0.3),
            width: AppThemeMetrics.borderHairline,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Cover Area ────────────────────────────────────────────
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppThemeColors.surfaceHigh,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppThemeMetrics.radiusLg),
                  ),
                ),
                child: album.coverPhotoPath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(AppThemeMetrics.radiusLg),
                        ),
                        child: Image.asset(
                          album.coverPhotoPath!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stack) =>
                              _buildPlaceholder(context),
                        ),
                      )
                    : _buildPlaceholder(context),
              ),
            ),

            // ── Album Info ────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.all(context.widthCalculated(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    album.name,
                    style: tt.titleMedium?.copyWith(
                      color: AppThemeColors.primaryText,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: context.heightCalculated(2)),
                  Text(
                    '${album.photoCount} ${album.photoCount == 1 ? 'photo' : 'photos'}',
                    style: tt.bodySmall?.copyWith(
                      color: AppThemeColors.secondaryText,
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

  Widget _buildPlaceholder(BuildContext context) {
    return Center(
      child: Icon(
        Icons.photo_library_outlined,
        size: context.iconSize() * 2,
        color: AppThemeColors.secondaryText.withValues(alpha: 0.3),
      ),
    );
  }
}
