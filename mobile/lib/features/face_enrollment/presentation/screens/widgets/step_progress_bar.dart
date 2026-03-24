import 'package:flutter/material.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/theme/theme.dart';
import '../../../domain/entities/face_photo_entity.dart';

class StepProgressBar extends StatelessWidget {
  final Map<FacePhotoType, String> photos;
  final int requiredPhotos;
  final int optionalPhotos;

  const StepProgressBar({
    super.key,
    required this.photos,
    this.requiredPhotos = 3,
    this.optionalPhotos = 2,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate uploaded photos
    final uploadedRequired = photos.entries
        .where((e) =>
            e.key == FacePhotoType.frontal ||
            e.key == FacePhotoType.leftProfile ||
            e.key == FacePhotoType.rightProfile)
        .length;

    final uploadedOptional = photos.entries
        .where((e) => e.key == FacePhotoType.extra1 || e.key == FacePhotoType.extra2)
        .length;

    final totalSteps = requiredPhotos + optionalPhotos;
    final progress = (uploadedRequired + uploadedOptional) / totalSteps;

    final tt = context.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Step ${uploadedRequired + uploadedOptional} of $totalSteps',
              style: tt.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryTextColor,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: tt.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
        SizedBox(height: context.heightCalculated(8)),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppTheme.inputBorderColor,
            color: AppTheme.primaryColor,
            minHeight: context.heightCalculated(6),
          ),
        ),
      ],
    );
  }
}