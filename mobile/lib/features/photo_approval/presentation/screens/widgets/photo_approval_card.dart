import 'dart:io';
import 'package:flutter/material.dart';
import 'package:multai_mobile/features/photo_approval/domain/entities/photo_approval_entity.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/responsive_extensions.dart';
import '../../../../../di/injection_container.dart';
import '../../../../gallery/domain/usecases/get_photo_image_usecase.dart';

import 'package:multai_mobile/core/theme/app_theme_metrics.dart';
import 'decision_action_buttons.dart';
import 'info_banner.dart';
import 'package:multai_mobile/core/theme/app_palette.dart';

class PhotoApprovalCard extends StatelessWidget {
  final PhotoApprovalEntity approval;
  final bool isDeciding;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const PhotoApprovalCard({
    super.key,
    required this.approval,
    required this.isDeciding,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final tt = context.textTheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.widthCalculated(16)),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppThemeMetrics.radiusLg),
        border: Border.all(color: context.colors.inputBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── PHOTO APPROVAL label ────────────────────────────────────
          Row(
            children: [
              Icon(
                Icons.verified_outlined,
                size: context.iconSize() * 0.85,
                color: context.colors.warning,
              ),
              SizedBox(width: context.widthCalculated(6)),
              Text(
                'PHOTO APPROVAL',
                style: tt.labelSmall?.copyWith(
                  color: context.colors.warning,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          SizedBox(height: context.heightCalculated(12)),

          // ── Photo ──────────────────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(AppThemeMetrics.radiusMd),
            child: SizedBox(
              width: double.infinity,
              height: context.heightCalculated(220),
              child: _ApprovalPhoto(photoId: approval.photoId),
            ),
          ),
          SizedBox(height: context.heightCalculated(16)),

          // ── Title ──────────────────────────────────────────────────
          Text(
            'You appeared in this photo',
            style: tt.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.colors.primaryText,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.heightCalculated(8)),

          // ── Subtitle ───────────────────────────────────────────────
          Text(
            'Do you want this to be visible to\nothers in the photo?',
            style: tt.bodySmall?.copyWith(
              color: context.theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.heightCalculated(20)),

          // ── Buttons ────────────────────────────────────────────────
          isDeciding
              ? Center(
                  child: CircularProgressIndicator(
                    color: context.theme.colorScheme.primary,
                  ),
                )
              : DecisionActionButtons(onAccept: onAccept, onReject: onReject),
          SizedBox(height: context.heightCalculated(16)),

          // ── Info ───────────────────────────────────────────────────
          const InfoBanner(
            message: 'All users must accept for this photo to go public.',
          ),
        ],
      ),
    );
  }
}

class _ApprovalPhoto extends StatefulWidget {
  final String photoId;

  const _ApprovalPhoto({required this.photoId});

  @override
  State<_ApprovalPhoto> createState() => _ApprovalPhotoState();
}

class _ApprovalPhotoState extends State<_ApprovalPhoto> {
  late Future<String?> _pathFuture;

  @override
  void initState() {
    super.initState();
    _pathFuture = _load();
  }

  Future<String?> _load() async {
    final result = await sl<GetPhotoImageUseCase>()(
      GetPhotoImageParams(photoId: widget.photoId),
    );
    return result.fold((_) => null, (path) => path);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _pathFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Container(
            color: context.colors.card,
            child: Center(
              child: CircularProgressIndicator(
                color: context.theme.colorScheme.primary,
              ),
            ),
          );
        }

        final path = snapshot.data;
        if (path == null) {
          return Container(
            color: context.colors.card,
            child: Icon(
              Icons.image_outlined,
              size: context.iconSize() * 3,
              color: context.colors.secondaryText.withValues(alpha: 0.3),
            ),
          );
        }

        return Image.file(
          File(path),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: context.colors.card,
            child: Icon(
              Icons.image_outlined,
              size: context.iconSize() * 3,
              color: context.colors.secondaryText.withValues(alpha: 0.3),
            ),
          ),
        );
      },
    );
  }
}
