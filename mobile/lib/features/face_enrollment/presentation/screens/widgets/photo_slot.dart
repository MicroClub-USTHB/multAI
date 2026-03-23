import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../../../core/extensions/extensions.dart';
import '../../../../../../core/theme/theme.dart';
import '../../../domain/entities/face_photo_entity.dart';
 
class PhotoSlot extends StatelessWidget {
  final FacePhotoType type;
  final String? filePath;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final double? height;
  final bool isOptional;
 
  const PhotoSlot({
    super.key,
    required this.type,
    required this.onTap,
    this.filePath,
    this.onDelete,
    this.height,
    this.isOptional = false,
  });
 
  bool get _hasPhoto => filePath != null;
 
  @override
  Widget build(BuildContext context) {
    final tt = context.textTheme;
    final cs = context.theme.colorScheme;
    final slotHeight = height ?? context.heightCalculated(200);
 
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
 
        // ── Photo container ──────────────────────────────────────────────
        GestureDetector(
          onTap: _hasPhoto ? null : onTap,
          child: Container(
            height: slotHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              border: Border.all(
                color: _hasPhoto ? cs.primary : AppTheme.inputBorderColor,
                width: _hasPhoto ? 1.5 : 0.5,
              ),
            ),
            child: _hasPhoto
                ? _FilledSlot(
                    filePath: filePath!,
                    isPrimary: type.isPrimary,
                    onDelete: onDelete,
                  )
                : _EmptySlot(isOptional: isOptional),
          ),
        ),
        SizedBox(height: context.heightCalculated(6)),
 
        // ── Label row ────────────────────────────────────────────────────
        if (!isOptional)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                type.label,
                style: tt.labelMedium?.copyWith(
                  color: _hasPhoto ? cs.primary : cs.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (!_hasPhoto)
                Text(
                  'Required',
                  style: tt.labelSmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              if (type.isPrimary && _hasPhoto)
                Text(
                  'PRIMARY',
                  style: tt.labelSmall?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
 
class _EmptySlot extends StatelessWidget {
  final bool isOptional;
 
  const _EmptySlot({this.isOptional = false});
 
  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
 
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.camera_alt_outlined,
          size: context.iconSize() * (isOptional ? 1.2 : 1.8),
          color: cs.onSurface.withValues(alpha: 0.3),
        ),
        if (!isOptional) ...[
          SizedBox(height: context.heightCalculated(8)),
          Text(
            'Tap to upload',
            style: context.textTheme.labelSmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.3),
            ),
          ),
        ],
      ],
    );
  }
}
 
class _FilledSlot extends StatelessWidget {
  final String filePath;
  final bool isPrimary;
  final VoidCallback? onDelete;
 
  const _FilledSlot({
    required this.filePath,
    required this.isPrimary,
    this.onDelete,
  });
 
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          child: Image.file(
            File(filePath),
            fit: BoxFit.cover,
          ),
        ),
 
        // PRIMARY badge
        if (isPrimary)
          Positioned(
            top: context.heightCalculated(8),
            left: context.widthCalculated(8),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.widthCalculated(8),
                vertical: context.heightCalculated(4),
              ),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: Text(
                'PRIMARY',
                style: context.textTheme.labelSmall?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
 
        // delete button
        Positioned(
          top: context.heightCalculated(8),
          right: context.widthCalculated(8),
          child: GestureDetector(
            onTap: onDelete,
            child: Container(
              padding: EdgeInsets.all(context.widthCalculated(6)),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: Icon(
                Icons.delete_outline,
                size: context.iconSize(),
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}