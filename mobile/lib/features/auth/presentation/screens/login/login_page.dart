import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:multai_mobile/core/constants/images.dart';
import 'package:multai_mobile/core/router/app_routes.dart';
import 'package:multai_mobile/core/theme/app_theme_colors.dart';
import '../../../../../core/extensions/context_extensions.dart';
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
    final screenHeight = MediaQuery.of(context).size.height;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthAuthenticated) {
          context.go(AppRoutes.events);
        } else if (state is AuthNeedsFaceEnrollment) {
          context.go(AppRoutes.faceEnrollment);
        }
        // ignore: use_build_context_synchronously
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
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Photo circle composition
                          _LoginPhotoComposition(
                            height: screenHeight * 0.35,
                          ),

                          Padding(
                            padding: const EdgeInsets.fromLTRB(28, 28, 28, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Gold accent bar
                                Container(
                                  width: 28,
                                  height: 2,
                                  decoration: BoxDecoration(
                                    color: AppThemeColors.gold,
                                    borderRadius: BorderRadius.circular(1),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Welcome back.',
                                  style: tt.displaySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    height: 1.1,
                                    color: AppThemeColors.primaryText,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Sign in to your account.',
                                  style: tt.bodyMedium?.copyWith(
                                    color: AppThemeColors.secondaryText,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 36),

                                // Email
                                Text(
                                  'Email',
                                  style: tt.labelMedium?.copyWith(
                                    color: AppThemeColors.neutral200,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                EmailField(controller: _emailController),
                                const SizedBox(height: 20),

                                // Password
                                Text(
                                  'Password',
                                  style: tt.labelMedium?.copyWith(
                                    color: AppThemeColors.neutral200,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                PasswordField(
                                  controller: _passwordController,
                                  obscure: _obscurePassword,
                                  onToggle: () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
                                  onSubmit: _onSignInPressed,
                                ),
                                const SizedBox(height: 32),

                                SignInButton(
                                  isLoading: isLoading,
                                  onPressed: _onSignInPressed,
                                ),
                                const SizedBox(height: 24),
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
                  padding: const EdgeInsets.symmetric(vertical: 16),
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
                            color: AppThemeColors.gold,
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
  const _LoginPhotoComposition({required this.height});

  @override
  Widget build(BuildContext context) {
    final circleSize = height * 0.76;
    final photoSize = height * 0.70;

    return SizedBox(
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Large gold circle — top-right, partially off-screen
          Positioned(
            top: -(height * 0.13),
            right: -(height * 0.07),
            child: Container(
              width: circleSize,
              height: circleSize,
              decoration: const BoxDecoration(
                color: AppThemeColors.gold,
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Main photo circle — left, overlapping the gold circle
          Positioned(
            top: height * 0.07,
            left: 28,
            child: ClipOval(
              child: Image.asset(
                AppImages.onboarding2,
                width: photoSize,
                height: photoSize,
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Small accent dot — bottom-right
          Positioned(
            bottom: height * 0.08,
            right: 56,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: AppThemeColors.gold.withValues(alpha: 0.28),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
