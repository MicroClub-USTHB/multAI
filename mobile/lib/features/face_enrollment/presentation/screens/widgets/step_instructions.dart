import 'package:flutter/material.dart';
import 'package:multai_mobile/core/extensions/context_extensions.dart';
import 'package:multai_mobile/core/extensions/responsive_extensions.dart';
import 'package:multai_mobile/core/theme/app_theme_colors.dart';
import 'package:multai_mobile/core/theme/app_theme_metrics.dart';
import 'package:multai_mobile/features/face_enrollment/domain/entities/face_photo_entity.dart';

class StepInstructions extends StatelessWidget {
  final FacePhotoType type;
  final bool isLastOfRequired;

  const StepInstructions({
    super.key,
    required this.type,
    this.isLastOfRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    final instructions = _instructionsFor(type);

    return Semantics(
      label: 'Photo instructions for ${type.label}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isLastOfRequired) ...[
            SizedBox(height: context.heightCalculated(4)),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.widthCalculated(12),
                vertical: context.heightCalculated(8),
              ),
              decoration: BoxDecoration(
                color: AppThemeColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppThemeMetrics.radiusSm),
                border: Border.all(
                  color: AppThemeColors.success.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: context.iconSize() * 0.9,
                    color: AppThemeColors.success,
                  ),
                  SizedBox(width: context.widthCalculated(8)),
                  Expanded(
                    child: Text(
                      'All required photos are complete',
                      style: context.textTheme.labelMedium?.copyWith(
                        color: AppThemeColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          ...instructions.map(
            (inst) => Padding(
              padding: EdgeInsets.only(
                top: context.heightCalculated(6),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      top: context.heightCalculated(3),
                    ),
                    child: Icon(
                      Icons.check_circle_outline,
                      size: context.iconSize() * 0.7,
                      color: AppThemeColors.success,
                    ),
                  ),
                  SizedBox(width: context.widthCalculated(8)),
                  Expanded(
                    child: Text(
                      inst,
                      style: context.textTheme.labelMedium?.copyWith(
                        color: AppThemeColors.secondaryText,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _instructionsFor(FacePhotoType type) {
    switch (type) {
      case FacePhotoType.frontal:
        return [
          'Look directly at the camera',
          'Keep a neutral expression',
          'Ensure good, even lighting',
          'Remove sunglasses and hats',
        ];
      case FacePhotoType.leftProfile:
        return [
          'Turn your head to the left',
          'Keep your face fully visible',
          'Do not tilt your head',
          'Keep your shoulders relaxed',
        ];
      case FacePhotoType.rightProfile:
        return [
          'Turn your head to the right',
          'Keep both eyes visible if possible',
          'Avoid extreme angles',
          'Maintain the same distance',
        ];
      case FacePhotoType.extra1:
      case FacePhotoType.extra2:
        return [
          'Use a slightly different angle',
          'Vary your expression if desired',
          'Good lighting still matters',
          'Helps improve recognition accuracy',
        ];
    }
  }
}
