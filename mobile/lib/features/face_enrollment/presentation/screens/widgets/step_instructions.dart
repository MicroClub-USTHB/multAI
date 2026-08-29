import 'package:flutter/material.dart';
import 'package:multai_mobile/core/theme/app_theme_colors.dart';
import 'package:multai_mobile/features/face_enrollment/domain/entities/face_photo_entity.dart';

class StepInstructions extends StatelessWidget {
  final FacePhotoType type;

  const StepInstructions({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final tips = _tipsFor(type);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: tips.map(
        (tip) => Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.check_circle_outline,
                  size: 14,
                  color: AppThemeColors.success,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  tip,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppThemeColors.secondaryText,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ).toList(),
    );
  }

  List<String> _tipsFor(FacePhotoType type) {
    switch (type) {
      case FacePhotoType.frontal:
        return [
          'Look straight at the camera',
          'Keep a neutral expression',
        ];
      case FacePhotoType.leftProfile:
        return [
          'Turn head ~30° to the left',
          'Keep both eyes visible',
        ];
      case FacePhotoType.rightProfile:
        return [
          'Turn head ~30° to the right',
          'Keep both eyes visible',
        ];
      case FacePhotoType.extra1:
        return [
          'Tilt chin slightly upward',
          'Keep face relaxed',
        ];
      case FacePhotoType.extra2:
        return [
          'Tilt chin slightly downward',
          'Keep face relaxed',
        ];
    }
  }
}
