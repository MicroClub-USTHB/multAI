import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:multai_mobile/core/constants/images.dart';
import 'package:multai_mobile/core/router/app_routes.dart';
import 'package:multai_mobile/core/theme/app_theme_colors.dart';
import 'package:multai_mobile/features/account/presentation/bloc/account_bloc.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/responsive_extensions.dart';
import '../../../../../core/extensions/snackbar_extensions.dart';
import '../../blocs/auth_bloc.dart';
import 'widgets/email_field.dart';
import 'widgets/password_field.dart';
import 'widgets/sign_in_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  late final String _randomImage;

  @override
  void initState() {
    super.initState();
    _randomImage = AppImages
        .onboardingImages[Random().nextInt(AppImages.onboardingImages.length)];
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSignInPressed() {
    if (!_formKey.currentState!.validate()) return;
    context.unfocus();
    context.read<AuthBloc>().add(
      LoginRequested(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tt = context.textTheme;
    final screenHeight = context.height;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.read<AccountBloc>().add(ResetAccountData());
          context.go(AppRoutes.events);
        } else if (state is AuthNeedsFaceEnrollment) {
          context.read<AccountBloc>().add(ResetAccountData());
          context.go(AppRoutes.faceEnrollment);
        }
        if (state is AuthFailure) {
          context.showErrorSnackBar(state.message);
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return Scaffold(
          backgroundColor: AppThemeColors.background,
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Photo circle composition
                          _LoginPhotoComposition(
                            height: screenHeight * 0.35,
                            imagePath: _randomImage,
                          ),

                          Padding(
                            padding: EdgeInsets.fromLTRB(
                              context.hPadding(),
                              context.heightCalculated(28),
                              context.hPadding(),
                              0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Accent bar
                                Container(
                                  width: 28,
                                  height: 2,
                                  decoration: BoxDecoration(
                                    color: AppThemeColors.primaryAccent,
                                    borderRadius: BorderRadius.circular(1),
                                  ),
                                ),
                                SizedBox(height: context.sectionSpacing()),
                                Text(
                                  'Welcome back.',
                                  style: tt.displaySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    height: 1.1,
                                    color: AppThemeColors.primaryText,
                                  ),
                                ),
                                SizedBox(height: context.heightCalculated(6)),
                                Text(
                                  'Sign in to your account.',
                                  style: tt.bodyMedium?.copyWith(
                                    color: AppThemeColors.secondaryText,
                                    fontSize: 15,
                                  ),
                                ),
                                SizedBox(height: context.heightCalculated(36)),

                                // Email
                                Text(
                                  'Email',
                                  style: tt.labelMedium?.copyWith(
                                    color: AppThemeColors.neutral200,
                                  ),
                                ),
                                SizedBox(height: context.heightCalculated(8)),
                                EmailField(controller: _emailController),
                                SizedBox(height: context.sectionSpacing()),

                                // Password
                                Text(
                                  'Password',
                                  style: tt.labelMedium?.copyWith(
                                    color: AppThemeColors.neutral200,
                                  ),
                                ),
                                SizedBox(height: context.heightCalculated(8)),
                                PasswordField(
                                  controller: _passwordController,
                                  obscure: _obscurePassword,
                                  onToggle: () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
                                  onSubmit: _onSignInPressed,
                                ),
                                SizedBox(height: context.heightCalculated(32)),

                                SignInButton(
                                  isLoading: isLoading,
                                  onPressed: _onSignInPressed,
                                ),
                                SizedBox(height: context.sectionSpacing()),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Register link
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: context.heightCalculated(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: tt.bodySmall?.copyWith(
                          color: AppThemeColors.secondaryText,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.go(AppRoutes.register),
                        child: Text(
                          'Sign Up',
                          style: tt.bodySmall?.copyWith(
                            color: AppThemeColors.primaryAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
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

class _LoginPhotoComposition extends StatelessWidget {
  final double height;
  final String imagePath;
  const _LoginPhotoComposition({required this.height, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    final circleSize = height * 0.76;
    final photoSize = height * 0.70;

    // Moving the viewport for the keyboard repaints the scroll content every
    // frame; cache the static circle composition as its own layer.
    return RepaintBoundary(
      child: SizedBox(
        height: height,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Large accent circle — top-right, partially off-screen
            Positioned(
              top: -(height * 0.13),
              right: -(height * 0.07),
              child: Container(
                width: circleSize,
                height: circleSize,
                decoration: const BoxDecoration(
                  color: AppThemeColors.primaryAccent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Main photo circle — left, overlapping the accent circle
            Positioned(
              top: height * 0.07,
              left: 28,
              child: ClipOval(
                child: Image.asset(
                  imagePath,
                  width: photoSize,
                  height: photoSize,
                  fit: BoxFit.cover,
                  frameBuilder: _fadeInFrame,
                ),
              ),
            ),
            // Small accent dot — bottom-right
            Positioned(
              bottom: height * 0.08,
              right: context.widthCalculated(56),
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: AppThemeColors.primaryAccent.withValues(alpha: 0.28),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _fadeInFrame(
    BuildContext context,
    Widget child,
    int? frame,
    bool wasSynchronouslyLoaded,
  ) {
    if (wasSynchronouslyLoaded) return child;
    return AnimatedOpacity(
      opacity: frame == null ? 0 : 1,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: child,
    );
  }
}
