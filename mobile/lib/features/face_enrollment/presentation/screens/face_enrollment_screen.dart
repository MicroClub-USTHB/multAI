import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multai_mobile/core/extensions/context_extensions.dart';
import 'package:multai_mobile/core/extensions/responsive_extensions.dart';
import 'package:multai_mobile/core/extensions/snackbar_extensions.dart';
import 'package:multai_mobile/core/router/app_routes.dart';
import 'package:multai_mobile/core/theme/app_theme_colors.dart';
import 'package:multai_mobile/core/theme/app_theme_metrics.dart';
import 'package:multai_mobile/features/face_enrollment/presentation/bloc/face_enrollment_bloc.dart';
import 'package:multai_mobile/features/face_enrollment/domain/entities/face_photo_entity.dart';
import 'package:multai_mobile/features/face_enrollment/presentation/screens/widgets/photo_slot.dart';
import 'package:multai_mobile/features/face_enrollment/presentation/screens/widgets/enrollment_progress.dart';
import 'package:multai_mobile/features/face_enrollment/presentation/screens/widgets/step_instructions.dart';
import 'package:multai_mobile/features/face_enrollment/presentation/screens/widgets/step_navigation.dart';

class FaceEnrollmentScreen extends StatefulWidget {
  const FaceEnrollmentScreen({super.key});

  @override
  State<FaceEnrollmentScreen> createState() => _FaceEnrollmentScreenState();
}

class _FaceEnrollmentScreenState extends State<FaceEnrollmentScreen> {
  static const _pageTypes = FacePhotoType.values;

  late final PageController _pageController;
  int _currentPage = 0;
  FaceEnrollmentState? _prevState;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
  }

  void _goToPage(int page) {
    if (page < 0 || page >= _pageTypes.length) return;
    _pageController.animateToPage(
      page,
      duration: AppThemeMetrics.durationMedium,
      curve: AppThemeMetrics.curveStandard,
    );
  }

  void _goNext() => _goToPage(_currentPage + 1);
  void _goPrevious() => _goToPage(_currentPage - 1);

  void _onStateChange(BuildContext context, FaceEnrollmentState state) {
    final currentType = _pageTypes[_currentPage];
    final prevPhoto = _prevState?.photos[currentType];
    final currPhoto = state.photos[currentType];

    final wasNull = prevPhoto == null;
    final nowExists = currPhoto != null;

    if (wasNull && nowExists && _currentPage < _pageTypes.length - 1) {
      final scheduledPage = _currentPage;
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted && _currentPage == scheduledPage) _goNext();
      });
    }

    _prevState = state;

    if (state.isSuccess) {
      _navigateAfterSuccess(context);
    }
    if (state.submitError != null) {
      context.showErrorSnackBar(state.submitError!);
    }
  }

  void _navigateAfterSuccess(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      if (!context.mounted) return;
      final state = context.read<FaceEnrollmentBloc>().state;
      if (state.isSuccess) context.go(AppRoutes.events);
    });
  }

  void _showPrivacySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppThemeColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppThemeColors.primaryAccent.withValues(
                        alpha: 0.15,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.lock_outline,
                      size: 22,
                      color: AppThemeColors.primaryAccent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Your data is protected',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppThemeColors.primaryText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Biometric data is encrypted end-to-end. '
                'We never share your photos with third parties. '
                'Your face data is stored securely and used only '
                'for identity verification.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppThemeColors.secondaryText,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FaceEnrollmentBloc, FaceEnrollmentState>(
      listener: _onStateChange,
      builder: (context, state) {
        if (state.isSuccess) {
          return const _SuccessScreen();
        }

        final type = _pageTypes[_currentPage];
        final currentPhoto = state.photos[type];
        final isOptional = _currentPage >= FacePhotoType.required.length;
        final allRequiredDone = state.canSubmit;
        final isLastPage = _currentPage == _pageTypes.length - 1;
        final canGoNext = currentPhoto != null || isOptional;

        return Scaffold(
          backgroundColor: AppThemeColors.background,
          appBar: _AppBar(),
          body: Stack(
            children: [
              Column(
                children: [
                  // Progress header (thin)
                  _ProgressHeader(state: state, currentStep: _currentPage),

                  // Hero content area
                  Expanded(
                    child: AbsorbPointer(
                      absorbing: state.isSubmitting,
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: _onPageChanged,
                        itemCount: _pageTypes.length,
                        itemBuilder: (context, index) => RepaintBoundary(
                          key: ValueKey('step_$index'),
                          child: TweenAnimationBuilder<double>(
                            key: ValueKey('enter_$index'),
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: AppThemeMetrics.durationMedium,
                            curve: Curves.easeOut,
                            builder: (context, value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(0, 20 * (1 - value)),
                                  child: child,
                                ),
                              );
                            },
                            child: _StepPage(
                              type: _pageTypes[index],
                              state: state,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Privacy info bar
                  _PrivacyBar(onTap: () => _showPrivacySheet(context)),

                  // Fixed bottom navigation
                  StepNavigation(
                    canGoPrevious: _currentPage > 0,
                    canGoNext: canGoNext,
                    isLastPage: isLastPage,
                    isOptional: isOptional,
                    allRequiredDone: allRequiredDone,
                    isSubmitting: state.isSubmitting,
                    onPrevious: _currentPage > 0 ? _goPrevious : null,
                    onNext: canGoNext ? _goNext : null,
                    onSkipOptional: isOptional && allRequiredDone
                        ? () => context.read<FaceEnrollmentBloc>().add(
                            EnrollmentSubmitted(),
                          )
                        : null,
                    onSubmit: () => context.read<FaceEnrollmentBloc>().add(
                      EnrollmentSubmitted(),
                    ),
                  ),
                ],
              ),
              if (state.isSubmitting) const _LoadingOverlay(),
            ],
          ),
        );
      },
    );
  }
}

// ── Progress Header ───────────────────────────────────────────────────────────

class _ProgressHeader extends StatelessWidget {
  final FaceEnrollmentState state;
  final int currentStep;

  const _ProgressHeader({required this.state, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: context.hPadding(),
        right: context.hPadding(),
        top: 12,
        bottom: 8,
      ),
      child: EnrollmentProgress(
        currentStep: currentStep,
        totalSteps: FacePhotoType.values.length,
        completedRequired: state.completedRequiredCount,
        totalRequired: state.totalRequired,
      ),
    );
  }
}

// ── Step Page ────────────────────────────────────────────────────────────────

class _StepPage extends StatelessWidget {
  final FacePhotoType type;
  final FaceEnrollmentState state;

  const _StepPage({required this.type, required this.state});

  @override
  Widget build(BuildContext context) {
    final tt = context.textTheme;
    final currentPhoto = state.photos[type];
    final currentError = state.photoErrors[type];
    final isLoading = state.loadingPhotoTypes.contains(type);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.hPadding()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 4),
          // Step title
          Semantics(
            header: true,
            child: Text(
              type.label,
              style: tt.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppThemeColors.primaryText,
              ),
            ),
          ),
          const SizedBox(height: 4),
          // Description
          Text(
            _description,
            style: tt.bodySmall?.copyWith(
              color: context.theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          // Photo hero — takes all remaining space
          Expanded(
            child: PhotoSlot(
              type: type,
              filePath: currentPhoto,
              isLoading: isLoading,
              error: currentError,
              onTap: () => _pickPhoto(context, type),
              onDelete: currentPhoto != null
                  ? () => context.read<FaceEnrollmentBloc>().add(
                      PhotoRemoved(type: type),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          // Instructions (compact)
          StepInstructions(type: type),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  String get _description {
    switch (type) {
      case FacePhotoType.frontal:
        return 'Look directly at the camera for your primary identification photo.';
      case FacePhotoType.leftProfile:
        return 'Turn your head to the left so we can capture your left profile.';
      case FacePhotoType.rightProfile:
        return 'Turn your head to the right to complete your profile set.';
      case FacePhotoType.extra1:
        return 'Add an extra photo from a different angle (optional).';
      case FacePhotoType.extra2:
        return 'One more photo from another angle (optional).';
    }
  }
}

// ── Privacy Bar ───────────────────────────────────────────────────────────────

class _PrivacyBar extends StatelessWidget {
  final VoidCallback onTap;

  const _PrivacyBar({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tt = context.textTheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_outline,
              size: 12,
              color: AppThemeColors.secondaryText.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 4),
            Text(
              'Encrypted & protected',
              style: tt.labelSmall?.copyWith(
                color: AppThemeColors.secondaryText.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── AppBar ──────────────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AppBar();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppThemeColors.background,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Semantics(
        header: true,
        child: Text(
          'Face Enrollment',
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppThemeColors.primaryText,
          ),
        ),
      ),
      centerTitle: true,
    );
  }
}

// ── Loading Overlay ─────────────────────────────────────────────────────────

class _LoadingOverlay extends StatefulWidget {
  const _LoadingOverlay();

  @override
  State<_LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<_LoadingOverlay> {
  static const _messages = [
    'Uploading your biometric data...',
    'Verifying photo quality...',
    'Encrypting your data...',
    'Almost finished...',
  ];

  Timer? _messageTimer;
  int _messageIndex = 0;

  @override
  void initState() {
    super.initState();
    _scheduleNextMessage();
  }

  void _scheduleNextMessage() {
    _messageTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _messageIndex = (_messageIndex + 1) % _messages.length);
      _scheduleNextMessage();
    });
  }

  @override
  void dispose() {
    _messageTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = context.textTheme;

    return Semantics(
      label: 'Uploading photos. Please wait.',
      child: AbsorbPointer(
        child: Container(
          color: Colors.black54,
          child: Center(
            child: Semantics(
              liveRegion: true,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: context.heightCalculated(48),
                    width: context.heightCalculated(48),
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: AppThemeColors.primaryAccent,
                    ),
                  ),
                  SizedBox(height: context.heightCalculated(16)),
                  AnimatedSwitcher(
                    duration: AppThemeMetrics.durationMedium,
                    transitionBuilder: (child, animation) =>
                        FadeTransition(opacity: animation, child: child),
                    child: Text(
                      _messages[_messageIndex],
                      key: ValueKey(_messageIndex),
                      style: tt.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: context.heightCalculated(4)),
                  Text(
                    'Please wait while we process your enrollment.',
                    style: tt.bodySmall?.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Success Screen ──────────────────────────────────────────────────────────

class _SuccessScreen extends StatefulWidget {
  const _SuccessScreen();

  @override
  State<_SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<_SuccessScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
      ),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = context.textTheme;

    return FadeTransition(
      opacity: _fadeAnim,
      child: Scaffold(
        backgroundColor: AppThemeColors.background,
        body: Semantics(
          label: 'Enrollment complete',
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: _scaleAnim,
                  child: Container(
                    width: context.widthCalculated(80),
                    height: context.widthCalculated(80),
                    decoration: BoxDecoration(
                      color: AppThemeColors.success.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle,
                      size: context.widthCalculated(48),
                      color: AppThemeColors.success,
                    ),
                  ),
                ),
                SizedBox(height: context.heightCalculated(24)),
                ScaleTransition(
                  scale: _scaleAnim,
                  child: Column(
                    children: [
                      Text(
                        'Enrollment Complete!',
                        style: tt.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppThemeColors.primaryText,
                        ),
                      ),
                      SizedBox(height: context.heightCalculated(8)),
                      Text(
                        'Your face profile has been saved.',
                        style: tt.bodyMedium?.copyWith(
                          color: context.theme.colorScheme.onSurface.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Photo Picker ────────────────────────────────────────────────────────────

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
            Semantics(
              header: true,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Select Photo Source',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Semantics(
              label: 'Take a photo with camera',
              button: true,
              child: ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
            ),
            Semantics(
              label: 'Choose from gallery',
              button: true,
              child: ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  if (source == null || !context.mounted) return;

  final picker = ImagePicker();
  XFile? picked;
  try {
    picked = await picker.pickImage(source: source, imageQuality: 90);
  } on PlatformException catch (_) {
    if (!context.mounted) return;
    context.showErrorSnackBar(
      source == ImageSource.camera
          ? 'No camera available on this device. Please choose a photo from your gallery instead.'
          : 'Could not open the photo library. Please try again.',
    );
    return;
  } catch (_) {
    if (!context.mounted) return;
    context.showErrorSnackBar('Could not select a photo. Please try again.');
    return;
  }

  if (picked == null || !context.mounted) return;

  final file = File(picked.path);
  context.read<FaceEnrollmentBloc>().add(
    PhotoSelected(type: type, filePath: file.path),
  );
}
