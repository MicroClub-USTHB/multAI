import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
 
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/router/app_routes.dart';
import '../../../../../core/theme/theme.dart';
import '../bloc/face_enrollment_bloc.dart';
import '../../domain/entities/face_photo_entity.dart';
import './widgets/photo_slot.dart';
import './widgets/step_progress_bar.dart';
import './widgets/tips_row.dart';
class FaceEnrollmentScreen extends StatelessWidget {
  const FaceEnrollmentScreen({super.key});
 
  Future<void> _pickPhoto(BuildContext context, FacePhotoType type) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (picked != null && context.mounted) {
      context.read<FaceEnrollmentBloc>().add(
            PhotoSelected(type: type, filePath: picked.path),
          );
    }
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
        final photos = state is FaceEnrollmentUpdated ? state.photos : {};
        final canSubmit = state is FaceEnrollmentUpdated && state.canSubmit;
        final tt = context.textTheme;
        final cs = context.theme.colorScheme;
 
        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          appBar: AppBar(
            backgroundColor: AppTheme.backgroundColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: cs.onSurface),
              onPressed: () => context.pop(),
            ),
            title: Text('Face Enrollment', style: tt.titleLarge),
            centerTitle: true,
          ),
          body: SafeArea(
            child: Column(
              children: [
                // ── Progress bar ─────────────────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.hPadding(),
                    vertical: context.heightCalculated(8),
                  ),
                  child: const StepProgressBar(
                    currentStep: 1,
                    totalSteps: 5,
                  ),
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
 
                        // ── Title ──────────────────────────────────────
                        Text(
                          'Enable Face Recognition',
                          style: tt.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: context.heightCalculated(8)),
 
                        // ── Subtitle ───────────────────────────────────
                        Text(
                          'Upload 3-5 clear photos of yourself to help\n'
                          'our AI find you accurately across the\nplatform.',
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurface.withValues(alpha: 0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: context.heightCalculated(16)),
 
                        // ── Tips ───────────────────────────────────────
                        const TipsRow(),
                        SizedBox(height: context.heightCalculated(20)),
 
                        // ── Frontal — large slot ────────────────────────
                        PhotoSlot(
                          type: FacePhotoType.frontal,
                          filePath: photos[FacePhotoType.frontal],
                          height: context.heightCalculated(240),
                          onTap: () =>
                              _pickPhoto(context, FacePhotoType.frontal),
                          onDelete: photos[FacePhotoType.frontal] != null
                              ? () => context.read<FaceEnrollmentBloc>().add(
                                    PhotoRemoved(type: FacePhotoType.frontal),
                                  )
                              : null,
                        ),
                        SizedBox(height: context.heightCalculated(12)),
 
                        // ── Left + Right — 2 columns ───────────────────
                        Row(
                          children: [
                            Expanded(
                              child: PhotoSlot(
                                type: FacePhotoType.leftProfile,
                                filePath: photos[FacePhotoType.leftProfile],
                                height: context.heightCalculated(160),
                                onTap: () => _pickPhoto(
                                    context, FacePhotoType.leftProfile),
                                onDelete:
                                    photos[FacePhotoType.leftProfile] != null
                                        ? () => context
                                            .read<FaceEnrollmentBloc>()
                                            .add(PhotoRemoved(
                                                type:
                                                    FacePhotoType.leftProfile))
                                        : null,
                              ),
                            ),
                            SizedBox(width: context.widthCalculated(12)),
                            Expanded(
                              child: PhotoSlot(
                                type: FacePhotoType.rightProfile,
                                filePath: photos[FacePhotoType.rightProfile],
                                height: context.heightCalculated(160),
                                onTap: () => _pickPhoto(
                                    context, FacePhotoType.rightProfile),
                                onDelete:
                                    photos[FacePhotoType.rightProfile] != null
                                        ? () => context
                                            .read<FaceEnrollmentBloc>()
                                            .add(PhotoRemoved(
                                                type:
                                                    FacePhotoType.rightProfile))
                                        : null,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: context.heightCalculated(12)),
 
                        // ── Extra View slot — small ────────────────────
                        PhotoSlot(
                          type: FacePhotoType.frontal,
                          filePath: null,
                          height: context.heightCalculated(80),
                          onTap: () {},
                          onDelete: null,
                          isOptional: true,
                        ),
                        SizedBox(height: context.heightCalculated(16)),
 
                        // ── Info box ───────────────────────────────────
                        Container(
                          padding: EdgeInsets.all(context.widthCalculated(12)),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceColor,
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusMd),
                            border: Border.all(
                              color: AppTheme.inputBorderColor,
                              width: 0.5,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: context.iconSize(),
                                color: cs.primary,
                              ),
                              SizedBox(width: context.widthCalculated(8)),
                              Expanded(
                                child: Text(
                                  'Your biometric data is encrypted and secured. '
                                  'We never share your photos with third parties.',
                                  style: tt.labelSmall?.copyWith(
                                    color:
                                        cs.onSurface.withValues(alpha: 0.7),
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: context.heightCalculated(24)),
 
                        // ── Start Enrollment button ────────────────────
                        SizedBox(
                          height: context.heightCalculated(52),
                          child: ElevatedButton(
                            onPressed: (canSubmit && !isLoading)
                                ? () => context
                                    .read<FaceEnrollmentBloc>()
                                    .add(EnrollmentSubmitted())
                                : null,
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
                                          color: cs.onPrimary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(
                                          width: context.widthCalculated(6)),
                                      Icon(
                                        Icons.arrow_forward,
                                        color: cs.onPrimary,
                                        size: context.iconSize(),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        SizedBox(height: context.heightCalculated(12)),
 
                        // ── Skip for now ───────────────────────────────
                        GestureDetector(
                          onTap: () => context.go(AppRoutes.events),
                          child: Text(
                            'Skip for now',
                            style: tt.labelMedium?.copyWith(
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