import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:multai_mobile/core/extensions/context_extensions.dart';
import 'package:multai_mobile/core/extensions/responsive_extensions.dart';
import 'package:multai_mobile/core/theme/app_theme_colors.dart';
import 'package:multai_mobile/core/theme/app_theme_metrics.dart';
import '../../../domain/entities/face_photo_entity.dart';

enum _SlotState { empty, loading, completed, error }

class PhotoSlot extends StatelessWidget {
  final FacePhotoType type;
  final String? filePath;
  final String? error;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final bool isLoading;

  const PhotoSlot({
    super.key,
    required this.type,
    required this.onTap,
    this.filePath,
    this.error,
    this.onDelete,
    this.isLoading = false,
  });

  _SlotState get _state {
    if (isLoading) return _SlotState.loading;
    if (error != null) return _SlotState.error;
    if (filePath != null) return _SlotState.completed;
    return _SlotState.empty;
  }

  void _handleTap(BuildContext context) {
    if (_state == _SlotState.completed) {
      _openPhoto(context);
    } else {
      onTap();
    }
  }

  void _openPhoto(BuildContext context) {
    if (filePath == null) return;

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
              child: Semantics(
                label: 'Close photo',
                button: true,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;

    return Semantics(
      label: _semanticsLabel,
      hint: _state == _SlotState.completed
          ? 'Double tap to view'
          : 'Double tap to capture',
      button: true,
      child: GestureDetector(
        onTap: () => _handleTap(context),
        child: AnimatedContainer(
          duration: AppThemeMetrics.durationMedium,
          curve: AppThemeMetrics.curveStandard,
          width: double.infinity,
          decoration: BoxDecoration(
            color: _backgroundColor,
            borderRadius: BorderRadius.circular(AppThemeMetrics.radiusLg),
            border: Border.all(
              color: _borderColor(cs),
              width: _borderWidth,
            ),
          ),
          clipBehavior: Clip.hardEdge,
          child: AnimatedSwitcher(
            duration: AppThemeMetrics.durationMedium,
            switchInCurve: AppThemeMetrics.curveEmphasized,
            switchOutCurve: AppThemeMetrics.curveStandard,
            child: _buildContent(context),
          ),
        ),
      ),
    );
  }

  String get _semanticsLabel {
    final name = type.label;
    if (_state == _SlotState.loading) return '$name, loading';
    if (_state == _SlotState.error) return '$name, error: $error';
    if (_state == _SlotState.completed) return '$name, photo added';
    return '$name, empty';
  }

  Color get _backgroundColor {
    switch (_state) {
      case _SlotState.completed:
        return Colors.transparent;
      case _SlotState.error:
        return AppThemeColors.error.withValues(alpha: 0.08);
      case _SlotState.loading:
      case _SlotState.empty:
        return AppThemeColors.photoSlot;
    }
  }

  Color _borderColor(ColorScheme cs) {
    switch (_state) {
      case _SlotState.completed:
        return AppThemeColors.success;
      case _SlotState.error:
        return AppThemeColors.error;
      case _SlotState.loading:
        return AppThemeColors.primaryAccent;
      case _SlotState.empty:
        return AppThemeColors.inputBorder;
    }
  }

  double get _borderWidth {
    switch (_state) {
      case _SlotState.completed:
      case _SlotState.error:
      case _SlotState.loading:
        return AppThemeMetrics.borderThick;
      case _SlotState.empty:
        return AppThemeMetrics.borderHairline;
    }
  }

  Widget _buildContent(BuildContext context) {
    switch (_state) {
      case _SlotState.loading:
        return _LoadingContent(type: type);
      case _SlotState.error:
        return _ErrorContent(type: type, error: error!);
      case _SlotState.completed:
        return _CompletedContent(
          filePath: filePath!,
          onDelete: onDelete,
        );
      case _SlotState.empty:
        return const _EmptyContent();
    }
  }
}

// ── Empty ───────────────────────────────────────────────────────────────────

class _EmptyContent extends StatelessWidget {
  const _EmptyContent();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Tap to capture photo',
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.95, end: 1.0),
              duration: AppThemeMetrics.durationMedium,
              curve: AppThemeMetrics.curveStandard,
              builder: (context, scale, child) {
                return Transform.scale(scale: scale, child: child);
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppThemeColors.neutral500.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.camera_alt_outlined,
                  size: context.iconSize() * 1.8,
                  color: AppThemeColors.secondaryText.withValues(alpha: 0.7),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Tap to capture your face',
              style: context.textTheme.labelLarge?.copyWith(
                color: AppThemeColors.secondaryText.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Loading ─────────────────────────────────────────────────────────────────

class _LoadingContent extends StatelessWidget {
  final FacePhotoType type;
  const _LoadingContent({required this.type});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Processing ${type.label}',
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: context.iconSize() * 1.4,
              width: context.iconSize() * 1.4,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppThemeColors.primaryAccent,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Processing...',
              style: context.textTheme.labelMedium?.copyWith(
                color: AppThemeColors.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Error ───────────────────────────────────────────────────────────────────

class _ErrorContent extends StatelessWidget {
  final FacePhotoType type;
  final String error;
  const _ErrorContent({required this.type, required this.error});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Error: $error. Tap to retry',
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppThemeColors.error.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  size: context.iconSize() * 1.3,
                  color: AppThemeColors.error,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Upload failed',
                style: context.textTheme.labelMedium?.copyWith(
                  color: AppThemeColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                error,
                style: context.textTheme.labelSmall?.copyWith(
                  color: AppThemeColors.error.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.refresh, size: 14, color: AppThemeColors.error),
                  const SizedBox(width: 4),
                  Text(
                    'Tap to retry',
                    style: context.textTheme.labelSmall?.copyWith(
                      color: AppThemeColors.error.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Completed ───────────────────────────────────────────────────────────────

class _CompletedContent extends StatelessWidget {
  final String filePath;
  final VoidCallback? onDelete;

  const _CompletedContent({
    required this.filePath,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppThemeMetrics.radiusLg),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: AppThemeMetrics.durationMedium,
            curve: Curves.easeOut,
            builder: (context, opacity, child) {
              return Opacity(opacity: opacity, child: child);
            },
            child: Image.file(
              File(filePath),
              fit: BoxFit.contain,
              alignment: Alignment.center,
            ),
          ),
        ),
        // Success checkmark (fade + scale in)
        Positioned(
          top: 10,
          right: 10,
          child: Semantics(
            label: 'Photo added successfully',
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: AppThemeMetrics.durationMedium,
              curve: AppThemeMetrics.curveEmphasized,
              builder: (context, scale, child) {
                return Transform.scale(scale: scale, child: child);
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppThemeColors.success,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  size: context.iconSize() * 0.7,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        if (onDelete != null)
          Positioned(
            bottom: 10,
            right: 10,
            child: Semantics(
              label: 'Remove photo',
              button: true,
              child: AnimatedOpacity(
                opacity: 1.0,
                duration: AppThemeMetrics.durationMedium,
                child: GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius:
                          BorderRadius.circular(AppThemeMetrics.radiusSm),
                    ),
                    child: Icon(
                      Icons.delete_outline,
                      size: context.iconSize(),
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
