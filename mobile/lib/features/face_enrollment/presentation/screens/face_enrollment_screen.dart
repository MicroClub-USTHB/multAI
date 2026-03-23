import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
 
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/router/app_routes.dart';
import '../../../../../core/theme/theme.dart';
import '../bloc/face_enrollment_bloc.dart';
import '../../domain/entities/face_photo_entity.dart';
import 'widgets/photo_slot.dart';
import 'widgets/step_progress_bar.dart';
import 'widgets/tips_row.dart';
 
class FaceEnrollmentScreen extends StatelessWidget {
  const FaceEnrollmentScreen({super.key});
 
  Future<void> _pickPhoto(
    BuildContext context,
    FacePhotoType type,
  ) async {
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
        final canSubmit =
            state is FaceEnrollmentUpdated && state.canSubmit;
 
        final tt = context.textTheme;
        final cs = context.theme.colorScheme;
 
        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          appBar: AppBar(
            title: Text(
              'Face Enrollment',
              style: tt.titleLarge,
            ),
            backgroundColor: AppTheme.backgroundColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: cs.onSurface),
              onPressed: () => context.pop(),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: context.hPadding(),
                vertical: context.heightCalculated(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
 
                  // ── Progress bar ─────────────────────────────────────────
                  const StepProgressBar(
                    currentStep: 1,
                    totalSteps: 5,
                  ),
                  SizedBox(height: context.heightCalculated(24)),
 
                  // ── Title ────────────────────────────────────────────────
                  Text(
                    'Enable Face Recognition',
                    style: tt.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: context.heightCalculated(8)),
 
                  // ── Subtitle ─────────────────────────────────────────────
                  Text(
                    'Upload 3-5 clear photos of yourself to help\n'
                    'our AI find you accurately across the platform.',
                    style: tt.bodySmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: context.heightCalculated(16)),
 
                  // ── Tips ─────────────────────────────────────────────────
                  const TipsRow(),
                  SizedBox(height: context.heightCalculated(24)),
 
                  // ── Photo slots ──────────────────────────────────────────
                  ...FacePhotoType.values.map(
                    (type) => Padding(
                      padding: EdgeInsets.only(
                        bottom: context.heightCalculated(16),
                      ),
                      child: PhotoSlot(
                        type: type,
                        filePath: photos[type],
                        onTap: () => _pickPhoto(context, type),
                        onDelete: photos[type] != null
                            ? () => context.read<FaceEnrollmentBloc>().add(
                                  PhotoRemoved(type: type),
                                )
                            : null,
                      ),
                    ),
                  ),
                  SizedBox(height: context.heightCalculated(8)),
 
                  // ── Submit button ────────────────────────────────────────
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
                          : Text(
                              'Submit',
                              style: tt.titleLarge?.copyWith(
                                color: cs.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: context.heightCalculated(24)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}