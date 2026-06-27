import 'package:flutter/material.dart';
import 'package:multai_mobile/core/theme/app_theme_colors.dart';
import 'package:multai_mobile/features/face_enrollment/domain/entities/face_photo_entity.dart';

class StepInstructions extends StatefulWidget {
  final FacePhotoType type;

  const StepInstructions({super.key, required this.type});

  @override
  State<StepInstructions> createState() => _StepInstructionsState();
}

class _StepInstructionsState extends State<StepInstructions> {
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final instructions = _instructionsFor(widget.type);
    final displayTips = _showAll ? instructions : instructions.take(2).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ...displayTips.map(
          (tip) => Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Icon(
                    Icons.check_circle_outline,
                    size: 16,
                    color: AppThemeColors.success,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    tip,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppThemeColors.secondaryText,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (instructions.length > 2)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: GestureDetector(
              onTap: () => setState(() => _showAll = !_showAll),
              child: Text(
                _showAll
                    ? 'Show less tips'
                    : 'Show ${instructions.length - 2} more tips',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppThemeColors.primaryAccent,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
      ],
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
