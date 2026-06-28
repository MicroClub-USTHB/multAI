import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../../core/extensions/responsive_extensions.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/theme/theme.dart';

class PhotoGridItem extends StatelessWidget {
  final String photoId;
  final String? localPath;
  final VoidCallback? onTap;
  final double? gridItemSize;

  const PhotoGridItem({
    super.key,
    required this.photoId,
    this.localPath,
    this.onTap,
    this.gridItemSize,
  });

  int _decodeSize(BuildContext context) {
    final size = gridItemSize ?? 160.0;
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    return (size * pixelRatio * 1.25).ceil();
  }

  @override
  Widget build(BuildContext context) {
    final decodeSize = _decodeSize(context);

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: localPath != null
            ? Image.file(
                File(localPath!),
                fit: BoxFit.cover,
                cacheWidth: decodeSize,
                cacheHeight: decodeSize,
                errorBuilder: (context, error, stackTrace) =>
                    _placeholder(context),
              )
            : _loading(context),
      ),
    );
  }

  Widget _loading(BuildContext context) {
    return Container(
      color: AppTheme.surfaceColor,
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
      color: AppTheme.surfaceColor,
      child: Icon(
        Icons.image_outlined,
        color: AppTheme.secondaryTextColor.withValues(alpha: 0.4),
        size: context.iconSize() * 1.5,
      ),
    );
  }
}
