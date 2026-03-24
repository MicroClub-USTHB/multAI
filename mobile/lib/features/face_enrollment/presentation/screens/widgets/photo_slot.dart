import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import '../../../../../../core/extensions/extensions.dart';
import '../../../../../../core/theme/theme.dart';
import '../../../domain/entities/face_photo_entity.dart';

class PhotoSlot extends StatefulWidget {
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

  @override
  State<PhotoSlot> createState() => _PhotoSlotState();
}

class _PhotoSlotState extends State<PhotoSlot> {
  late String? _currentFilePath;

  @override
  void initState() {
    super.initState();
    _currentFilePath = widget.filePath;
  }

  @override
  void didUpdateWidget(PhotoSlot oldWidget) {
    super.didUpdateWidget(oldWidget);
    _currentFilePath = widget.filePath; // update if bloc state changes
  }

  void _handleDelete() {
    setState(() {
      _currentFilePath = null;
    });
    if (widget.onDelete != null) widget.onDelete!();
  }

  void _handleTap() {
    if (_currentFilePath != null) {
      _openPhoto(context);
    } else {
      widget.onTap();
    }
  }

  bool get _hasPhoto => _currentFilePath != null;

  void _openPhoto(BuildContext context) {
    if (!_hasPhoto) return;
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: PhotoView(
          imageProvider: FileImage(File(_currentFilePath!)),
          backgroundDecoration: const BoxDecoration(color: Colors.black),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tt = context.textTheme;
    final cs = context.theme.colorScheme;
    final slotHeight = widget.height ?? context.heightCalculated(200);
    final slotLabel = widget.label ?? widget.type.label;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _handleTap,
          child: Container(
            height: slotHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              color: _hasPhoto ? Colors.transparent : AppTheme.photoSlotColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              border: Border.all(
                color: _hasPhoto ? cs.primary : AppTheme.inputBorderColor,
                width: _hasPhoto ? 1.5 : 0.5,
              ),
            ),
            clipBehavior: Clip.hardEdge,
            child: _hasPhoto
                ? _FilledSlot(
                    filePath: _currentFilePath!,
                    isPrimary: widget.type.isPrimary,
                    onDelete: _handleDelete,
                  )
                : _EmptySlot(isOptional: widget.isOptional),
          ),
        ),
        SizedBox(height: context.heightCalculated(6)),
        widget.isOptional
            ? Text(
                slotLabel,
                style: tt.labelMedium?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.5),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    slotLabel,
                    style: tt.labelLarge?.copyWith(
                      color: _hasPhoto ? cs.primary : AppTheme.primaryTextColor,
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
                  if (widget.type.isPrimary && _hasPhoto)
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.camera_alt_outlined,
            size: context.iconSize() * (isOptional ? 1.2 : 1.8),
            color: AppTheme.secondaryTextColor.withValues(alpha: 0.6),
          ),
          if (!isOptional) SizedBox(height: context.heightCalculated(8)),
          if (!isOptional)
            Text(
              'Tap to upload',
              style: context.textTheme.labelSmall?.copyWith(
                color: AppTheme.secondaryTextColor.withValues(alpha: 0.6),
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
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          child: Image.file(
            File(filePath),
            fit: BoxFit.contain, // keeps image fully visible inside the slot
            alignment: Alignment.center,
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

        // Delete button
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