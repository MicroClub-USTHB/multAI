import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import '../../../../../../core/extensions/context_extensions.dart';
import '../../../../../../core/extensions/responsive_extensions.dart';
import 'package:multai_mobile/core/theme/app_theme_colors.dart';
import 'package:multai_mobile/core/theme/app_theme_metrics.dart';
import '../../../domain/entities/face_photo_entity.dart';

class PhotoSlot extends StatelessWidget {
  final FacePhotoType type;
  final String? filePath;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final double? height;
  final bool isOptional;
  final String? label;
  final bool isLoading;

  const PhotoSlot({
    super.key,
    required this.type,
    required this.onTap,
    this.filePath,
    this.onDelete,
    this.height,
    this.isOptional = false,
    this.label,
    this.isLoading = false,
  });

  bool get _hasPhoto => filePath != null;

  void _handleTap(BuildContext context) {
    if (_hasPhoto) {
      _openPhoto(context);
    } else {
      onTap();
    }
  }

  void _openPhoto(BuildContext context) {
    if (!_hasPhoto) return;

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            PhotoView(
              imageProvider: FileImage(File(filePath!)),
              backgroundDecoration: const BoxDecoration(color: Colors.black),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2,
            ),
            Positioned(
              top: context.heightCalculated(40),
              right: context.widthCalculated(20),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tt = context.textTheme;
    final cs = context.theme.colorScheme;
    final slotHeight = height ?? context.heightCalculated(200);
    final slotLabel = label ?? type.label;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _handleTap(context),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            height: slotHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              color: _hasPhoto ? Colors.transparent : AppThemeColors.photoSlot,
              borderRadius: BorderRadius.circular(AppThemeMetrics.radiusLg),
              border: Border.all(
                color: _hasPhoto ? cs.primary : AppThemeColors.inputBorder,
                width: _hasPhoto ? 1.5 : 0.5,
              ),
            ),
            clipBehavior: Clip.hardEdge,
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : _hasPhoto
                    ? _FilledSlot(
                        filePath: filePath!,
                        isPrimary: type.isPrimary,
                        onDelete: onDelete,
                      )
                    : _EmptySlot(isOptional: isOptional),
          ),
        ),
        SizedBox(height: context.heightCalculated(6)),
        _buildLabelRow(tt, cs, slotLabel),
      ],
    );
  }

  Widget _buildLabelRow(TextTheme tt, ColorScheme cs, String slotLabel) {
    if (isOptional) {
      return Text(
        slotLabel,
        style: tt.labelMedium?.copyWith(
          color: cs.onSurface.withValues(alpha: 0.5),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          slotLabel,
          style: tt.labelLarge?.copyWith(
            color: _hasPhoto ? cs.primary : AppThemeColors.primaryText,
            fontWeight: FontWeight.bold,
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
    );
  }
}

class _EmptySlot extends StatelessWidget {
  final bool isOptional;

  const _EmptySlot({this.isOptional = false});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.camera_alt_outlined,
            size: context.iconSize() * (isOptional ? 1.2 : 1.8),
            color: AppThemeColors.secondaryText.withValues(alpha: 0.6),
          ),
          if (!isOptional) SizedBox(height: context.heightCalculated(8)),
          if (!isOptional)
            Text(
              'Tap to upload',
              style: context.textTheme.labelSmall?.copyWith(
                color: AppThemeColors.secondaryText.withValues(alpha: 0.6),
              ),
            ),
        ],
      ),
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
          borderRadius: BorderRadius.circular(AppThemeMetrics.radiusLg),
          child: Image.file(
            File(filePath),
            fit: BoxFit.contain,
            alignment: Alignment.center,
          ),
        ),
        if (isPrimary)
          Positioned(
            top: context.heightCalculated(8),
            left: context.widthCalculated(8),
            child: _badge(
              context,
              'PRIMARY',
              AppThemeColors.primaryAccent,
              Colors.black,
            ),
          ),
        if (onDelete != null)
          Positioned(
            top: context.heightCalculated(8),
            right: context.widthCalculated(8),
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                padding: EdgeInsets.all(context.widthCalculated(6)),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(AppThemeMetrics.radiusSm),
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

  Widget _badge(BuildContext context, String text, Color bg, Color fg) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.widthCalculated(8),
        vertical: context.heightCalculated(4),
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppThemeMetrics.radiusSm),
      ),
      child: Text(
        text,
        style: context.textTheme.labelSmall?.copyWith(
          color: fg,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
