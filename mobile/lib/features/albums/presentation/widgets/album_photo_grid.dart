import 'dart:io';
import 'package:flutter/material.dart';
import 'package:multai_mobile/core/extensions/responsive_extensions.dart';
import 'package:multai_mobile/core/theme/theme.dart';

class AlbumPhotoGrid extends StatelessWidget {
  final List<String> photoPaths;
  final VoidCallback? onAddPhotos;

  const AlbumPhotoGrid({
    super.key,
    required this.photoPaths,
    this.onAddPhotos,
  });

  @override
  Widget build(BuildContext context) {
    if (photoPaths.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: context.iconSize() * 3,
              color: AppTheme.secondaryTextColor.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'This album is empty',
              style: TextStyle(
                color: AppTheme.secondaryTextColor,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(context.hPadding()),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: context.widthCalculated(4),
        mainAxisSpacing: context.heightCalculated(4),
      ),
      itemCount: photoPaths.length,
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(AppThemeMetrics.radiusSm),
          child: Image.file(
            File(photoPaths[index]),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stack) => Container(
              color: AppTheme.surfaceColor,
              child: Icon(
                Icons.broken_image_outlined,
                color: AppTheme.secondaryTextColor,
              ),
            ),
          ),
        );
      },
    );
  }
}
