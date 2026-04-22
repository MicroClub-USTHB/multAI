import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../../core/extensions/responsive_extensions.dart';
import '../../../../../core/extensions/context_extensions.dart';
import 'package:multai_mobile/core/theme/app_theme_colors.dart';
import 'package:multai_mobile/core/theme/app_theme_metrics.dart';

class PhotoGridItem extends StatelessWidget {
  final String photoId;
  final String? localPath;
  final VoidCallback? onTap;

  const PhotoGridItem({
    super.key,
    required this.photoId,
    this.localPath,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppThemeMetrics.radiusMd),
        child: localPath != null
            ? Image.file(
                File(localPath!),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _placeholder(context),
              )
            : _loading(context),
      ),
    );
  }

  Widget _loading(BuildContext context) {
    return Container(
      color: AppThemeColors.surface,
      child: Center(
        child: SizedBox(
          width: context.widthCalculated(20),
          height: context.widthCalculated(20),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: context.theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      color: AppThemeColors.surface,
      child: Icon(
        Icons.image_outlined,
        color: AppThemeColors.secondaryText.withValues(alpha: 0.4),
        size: context.iconSize() * 1.5,
      ),
    );
  }
}
