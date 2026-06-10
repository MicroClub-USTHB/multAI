import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/responsive_extensions.dart';
import '../../../../core/extensions/snackbar_extensions.dart';
import '../../../../../core/router/app_routes.dart';
import 'package:multai_mobile/core/theme/app_theme_colors.dart';
import 'package:multai_mobile/core/theme/app_theme_metrics.dart';
import './../bloc/face_enrollment_bloc.dart';
import '../../domain/entities/face_photo_entity.dart';
import './widgets/photo_slot.dart';
import './widgets/tips_row.dart';
import './widgets/step_progress_bar.dart';

class FaceEnrollmentScreen extends StatelessWidget {
  const FaceEnrollmentScreen({super.key});

  Future<void> _pickPhoto(BuildContext context, FacePhotoType type) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppThemeColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Select Photo Source',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null || !context.mounted) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 90,
    );

    if (picked == null || !context.mounted) return;

    final file = File(picked.path);
    context.read<FaceEnrollmentBloc>().add(
      PhotoSelected(type: type, filePath: file.path),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FaceEnrollmentBloc, FaceEnrollmentState>(
      listener: (context, state) {
        if (state is FaceEnrollmentSuccess) {
          context.go(AppRoutes.events);
        }
        if (state is FaceEnrollmentFailure) {
          context.showErrorSnackBar(state.message);
        }
      },
      builder: (context, state) {
        final isLoading = state is FaceEnrollmentLoading;

        final Map<FacePhotoType, String> photos = switch (state) {
          FaceEnrollmentUpdated s => s.photos,
          FaceEnrollmentPhotoLoading s => s.photos,
          FaceEnrollmentFailure s => s.photos,
          _ => {},
        };

        final FacePhotoType? loadingType = state is FaceEnrollmentPhotoLoading
            ? state.type
            : null;

        final canSubmit = switch (state) {
          FaceEnrollmentUpdated s => s.canSubmit,
          FaceEnrollmentPhotoLoading s => s.canSubmit,
          _ => false,
        };

        final tt = context.textTheme;
        final cs = context.theme.colorScheme;

        return Scaffold(
          backgroundColor: AppThemeColors.background,
          appBar: AppBar(
            backgroundColor: AppThemeColors.background,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: cs.onSurface),
              onPressed: () => context.pop(),
            ),
            title: Text(
              'Face Enrollment',
              style: tt.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppThemeColors.primaryText,
              ),
            ),
            centerTitle: true,
          ),
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.hPadding(),
                    vertical: context.heightCalculated(8),
                  ),
                  child: StepProgressBar(photos: photos),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.hPadding(),
                      vertical: context.heightCalculated(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Enable Face Recognition',
                          style: tt.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppThemeColors.primaryText,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: context.heightCalculated(8)),
                        Text(
                          'Upload 3-5 clear photos of yourself to help '
                          'our AI find you accurately across the platform.',
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurface.withValues(alpha: 0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: context.heightCalculated(16)),
                        const TipsRow(),
                        SizedBox(height: context.heightCalculated(20)),

                        // Mandatory Photos
                        PhotoSlot(
                          type: FacePhotoType.frontal,
                          filePath: photos[FacePhotoType.frontal],
                          height: context.heightCalculated(340),
                          isLoading: loadingType == FacePhotoType.frontal,
                          onTap: () =>
                              _pickPhoto(context, FacePhotoType.frontal),
                          onDelete: photos[FacePhotoType.frontal] != null
                              ? () => context.read<FaceEnrollmentBloc>().add(
                                  PhotoRemoved(type: FacePhotoType.frontal),
                                )
                              : null,
                        ),
                        SizedBox(height: context.heightCalculated(12)),

                        Row(
                          children: [
                            Expanded(
                              child: PhotoSlot(
                                type: FacePhotoType.leftProfile,
                                filePath: photos[FacePhotoType.leftProfile],
                                height: context.heightCalculated(260),
                                isLoading:
                                    loadingType == FacePhotoType.leftProfile,
                                onTap: () => _pickPhoto(
                                  context,
                                  FacePhotoType.leftProfile,
                                ),
                                onDelete:
                                    photos[FacePhotoType.leftProfile] != null
                                    ? () => context
                                          .read<FaceEnrollmentBloc>()
                                          .add(
                                            PhotoRemoved(
                                              type: FacePhotoType.leftProfile,
                                            ),
                                          )
                                    : null,
                              ),
                            ),
                            SizedBox(width: context.widthCalculated(12)),
                            Expanded(
                              child: PhotoSlot(
                                type: FacePhotoType.rightProfile,
                                filePath: photos[FacePhotoType.rightProfile],
                                height: context.heightCalculated(260),
                                isLoading:
                                    loadingType == FacePhotoType.rightProfile,
                                onTap: () => _pickPhoto(
                                  context,
                                  FacePhotoType.rightProfile,
                                ),
                                onDelete:
                                    photos[FacePhotoType.rightProfile] != null
                                    ? () => context
                                          .read<FaceEnrollmentBloc>()
                                          .add(
                                            PhotoRemoved(
                                              type: FacePhotoType.rightProfile,
                                            ),
                                          )
                                    : null,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: context.heightCalculated(12)),

                        // Optional Photos
                        PhotoSlot(
                          type: FacePhotoType.extra1,
                          filePath: photos[FacePhotoType.extra1],
                          height: context.heightCalculated(260),
                          isOptional: true,
                          label: 'Extra View 1',
                          isLoading: loadingType == FacePhotoType.extra1,
                          onTap: () =>
                              _pickPhoto(context, FacePhotoType.extra1),
                          onDelete: photos[FacePhotoType.extra1] != null
                              ? () => context.read<FaceEnrollmentBloc>().add(
                                  PhotoRemoved(type: FacePhotoType.extra1),
                                )
                              : null,
                        ),
                        SizedBox(height: context.heightCalculated(12)),
                        PhotoSlot(
                          type: FacePhotoType.extra2,
                          filePath: photos[FacePhotoType.extra2],
                          height: context.heightCalculated(260),
                          isOptional: true,
                          label: 'Extra View 2',
                          isLoading: loadingType == FacePhotoType.extra2,
                          onTap: () =>
                              _pickPhoto(context, FacePhotoType.extra2),
                          onDelete: photos[FacePhotoType.extra2] != null
                              ? () => context.read<FaceEnrollmentBloc>().add(
                                  PhotoRemoved(type: FacePhotoType.extra2),
                                )
                              : null,
                        ),
                        SizedBox(height: context.heightCalculated(16)),

                        // Biometric info
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.lock_outline,
                              size: context.iconSize(),
                              color: cs.onSurface.withValues(alpha: 0.5),
                            ),
                            SizedBox(width: context.widthCalculated(8)),
                            Expanded(
                              child: Text(
                                'Your biometric data is encrypted and secured. '
                                'We never share your photos with third parties.',
                                style: tt.labelMedium?.copyWith(
                                  color: cs.onSurface.withValues(alpha: 0.6),
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: context.heightCalculated(24)),

                        // Start Enrollment Button
                        SizedBox(
                          height: context.heightCalculated(52),
                          child: ElevatedButton(
                            onPressed: canSubmit && !isLoading
                                ? () => context.read<FaceEnrollmentBloc>().add(
                                    EnrollmentSubmitted(),
                                  )
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: canSubmit
                                  ? AppThemeColors.primaryAccent
                                  : AppThemeColors.enrollDisabled,
                              foregroundColor: canSubmit
                                  ? Colors.black
                                  : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppThemeMetrics.radiusMd,
                                ),
                              ),
                            ),
                            child: isLoading
                                ? SizedBox(
                                    height: context.heightCalculated(20),
                                    width: context.heightCalculated(20),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: cs.onPrimary,
                                    ),
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Start Enrollment',
                                        style: tt.titleLarge?.copyWith(
                                          color: canSubmit
                                              ? Colors.black
                                              : Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(
                                        width: context.widthCalculated(6),
                                      ),
                                      Icon(
                                        Icons.arrow_forward,
                                        color: canSubmit
                                            ? Colors.black
                                            : Colors.white,
                                        size: context.iconSize(),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        SizedBox(height: context.heightCalculated(16)),

                        GestureDetector(
                          onTap: () => context.go(AppRoutes.events),
                          child: Text(
                            'Skip for now',
                            style: tt.titleMedium?.copyWith(
                              color: cs.onSurface.withValues(alpha: 0.5),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: context.heightCalculated(24)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
