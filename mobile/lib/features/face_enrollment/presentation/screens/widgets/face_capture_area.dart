import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:multai_mobile/core/theme/app_theme_colors.dart';
import 'package:multai_mobile/core/theme/app_theme_metrics.dart';
import '../../../domain/entities/face_photo_entity.dart';

class FaceCaptureArea extends StatelessWidget {
  final CameraController? cameraController;
  final FacePhotoType type;
  final VoidCallback onCapture;
  final String? capturedFilePath;
  final bool isProcessing;

  const FaceCaptureArea({
    super.key,
    this.cameraController,
    required this.type,
    required this.onCapture,
    this.capturedFilePath,
    this.isProcessing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppThemeMetrics.radiusLg),
        border: Border.all(
          color: AppThemeColors.primaryAccent.withValues(alpha: 0.3),
          width: AppThemeMetrics.borderThin,
        ),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildCameraLayer(),

          // Capture button
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: _CaptureButton(
                onPressed: isProcessing ? null : onCapture,
                isProcessing: isProcessing,
              ),
            ),
          ),

          if (capturedFilePath != null)
            _CapturedFlash(filePath: capturedFilePath!),
        ],
      ),
    );
  }

  Widget _buildCameraLayer() {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return Container(
        color: AppThemeColors.photoSlot,
        child: const Center(
          child: Icon(
            Icons.camera_alt_outlined,
            size: 48,
            color: AppThemeColors.secondaryText,
          ),
        ),
      );
    }

    return FittedBox(
      fit: BoxFit.cover,
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: cameraController!.value.previewSize!.height,
        height: cameraController!.value.previewSize!.width,
        child: CameraPreview(cameraController!),
      ),
    );
  }
}

class _CaptureButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isProcessing;

  const _CaptureButton({this.onPressed, this.isProcessing = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.8),
            width: 3,
          ),
        ),
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isProcessing
                ? AppThemeColors.primaryAccent.withValues(alpha: 0.5)
                : Colors.white,
          ),
          child: isProcessing
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(
                  Icons.camera,
                  color: AppThemeColors.background,
                  size: 28,
                ),
        ),
      ),
    );
  }
}

class _CapturedFlash extends StatefulWidget {
  final String filePath;

  const _CapturedFlash({required this.filePath});

  @override
  State<_CapturedFlash> createState() => _CapturedFlashState();
}

class _CapturedFlashState extends State<_CapturedFlash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _opacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward().then((_) {
      if (mounted) _controller.dispose();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacity,
      builder: (context, child) {
        if (_opacity.value <= 0) return const SizedBox.shrink();
        return Opacity(
          opacity: _opacity.value,
          child: Image.file(
            File(widget.filePath),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        );
      },
    );
  }
}
