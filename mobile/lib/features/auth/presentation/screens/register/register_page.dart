import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:multai_mobile/core/constants/images.dart';
import 'package:multai_mobile/core/router/app_routes.dart';
import 'package:multai_mobile/core/theme/app_theme_colors.dart';
import 'package:multai_mobile/core/theme/app_theme_metrics.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/responsive_extensions.dart';
import '../../../../../core/extensions/snackbar_extensions.dart';
import '../../../../../core/utils/validators.dart';
import '../../blocs/auth_bloc.dart';
import '../login/widgets/email_field.dart';
import '../login/widgets/password_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _otpController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _pendingToken;
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
    _confirmPasswordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _onSendOtpPressed() {
    if (!_formKey.currentState!.validate()) return;
    context.unfocus();
    context.read<AuthBloc>().add(
      SendOtpRequested(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  void _onVerifyOtpPressed() {
    final otp = _otpController.text.trim();
    if (otp.length != 6) return;
    context.unfocus();
    context.read<AuthBloc>().add(
      VerifyOtpRequested(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        otp: otp,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go(AppRoutes.events);
        } else if (state is AuthNeedsFaceEnrollment) {
          context.go(AppRoutes.faceEnrollment);
        } else if (state is AuthOtpSent) {
          setState(() => _pendingToken = state.pendingToken);
        } else if (state is ResendOtpSuccess) {
          setState(() => _pendingToken = state.pendingToken);
        }
        if (state is AuthFailure) {
          context.showErrorSnackBar(state.message);
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        final isOtpStep = state is AuthOtpSent;

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
                          _RegisterPhotoComposition(
                            isOtpStep: isOtpStep,
                            imagePath: _randomImage,
                          ),
                          isOtpStep
                              ? _OtpFormContent(
                                  email: _emailController.text.trim(),
                                  pendingToken: _pendingToken,
                                  otpController: _otpController,
                                  isLoading: isLoading,
                                  onVerify: _onVerifyOtpPressed,
                                  onResend: (pendingToken) =>
                                      context.read<AuthBloc>().add(
                                        ResendOtpRequested(
                                          pendingToken: pendingToken,
                                        ),
                                      ),
                                )
                              : _RegisterFormContent(
                                  emailController: _emailController,
                                  passwordController: _passwordController,
                                  confirmPasswordController:
                                      _confirmPasswordController,
                                  obscurePassword: _obscurePassword,
                                  obscureConfirm: _obscureConfirm,
                                  isLoading: isLoading,
                                  onTogglePassword: () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
                                  onToggleConfirm: () => setState(
                                    () => _obscureConfirm = !_obscureConfirm,
                                  ),
                                  onSubmit: _onSendOtpPressed,
                                ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Bottom link
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: context.heightCalculated(16),
                  ),
                  child: _BottomLink(
                    isOtpStep: isOtpStep,
                    onTap: () {
                      if (isOtpStep) {
                        setState(() {
                          _otpController.clear();
                          context.read<AuthBloc>().add(ResetAuth());
                        });
                      } else {
                        context.go(AppRoutes.login);
                      }
                    },
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

// ── Photo composition ──────────────────────────────────────────────────────────

class _RegisterPhotoComposition extends StatelessWidget {
  final bool isOtpStep;
  final String imagePath;
  const _RegisterPhotoComposition({
    required this.isOtpStep,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = context.height;
    // Slightly shorter on the form step (3 fields) to give more room
    final height = screenHeight * (isOtpStep ? 0.34 : 0.28);
    final circleSize = height * 0.80;
    final photoSize = height * 0.74;

    return SizedBox(
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Large accent circle — top-right, partially off-screen
          Positioned(
            top: -(height * 0.14),
            right: -(height * 0.08),
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
            top: height * 0.08,
            left: context.hPadding(),
            child: ClipOval(
              child: Image.asset(
                imagePath,
                width: photoSize,
                height: photoSize,
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Small accent dot
          Positioned(
            bottom: height * 0.08,
            right: context.widthCalculated(52),
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: AppThemeColors.primaryAccent.withValues(alpha: 0.28),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Registration form (step 1) ─────────────────────────────────────────────────

class _RegisterFormContent extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool obscurePassword;
  final bool obscureConfirm;
  final bool isLoading;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirm;
  final VoidCallback onSubmit;

  const _RegisterFormContent({
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.obscurePassword,
    required this.obscureConfirm,
    required this.isLoading,
    required this.onTogglePassword,
    required this.onToggleConfirm,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final tt = context.textTheme;
    final cs = context.theme.colorScheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.hPadding(),
        context.heightCalculated(24),
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
          const SizedBox(height: 16),
          Text(
            'Create account.',
            style: tt.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              height: 1.1,
              color: AppThemeColors.primaryText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Join Micro Club. Your moments await.',
            style: tt.bodyMedium?.copyWith(
              color: AppThemeColors.secondaryText,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 32),

          Text(
            'Email',
            style: tt.labelMedium?.copyWith(color: AppThemeColors.neutral200),
          ),
          const SizedBox(height: 8),
          EmailField(controller: emailController),
          const SizedBox(height: 18),

          Text(
            'Password',
            style: tt.labelMedium?.copyWith(color: AppThemeColors.neutral200),
          ),
          const SizedBox(height: 8),
          PasswordField(
            controller: passwordController,
            obscure: obscurePassword,
            onToggle: onTogglePassword,
            onSubmit: () {},
            validator: Validators.password,
          ),
          const SizedBox(height: 8),
          _PasswordStrengthIndicator(controller: passwordController),
          const SizedBox(height: 10),

          Text(
            'Confirm Password',
            style: tt.labelMedium?.copyWith(color: AppThemeColors.neutral200),
          ),
          const SizedBox(height: 8),
          PasswordField(
            controller: confirmPasswordController,
            obscure: obscureConfirm,
            onToggle: onToggleConfirm,
            onSubmit: onSubmit,
            validator: (v) =>
                Validators.confirmPassword(v, passwordController.text),
          ),
          const SizedBox(height: 32),

          SizedBox(
            height: 52,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : onSubmit,
              child: isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: cs.onPrimary,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Continue',
                          style: tt.titleMedium?.copyWith(
                            color: cs.onPrimary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: cs.onPrimary,
                          size: 18,
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── OTP step (step 2) ──────────────────────────────────────────────────────────

class _OtpFormContent extends StatefulWidget {
  final String email;
  final String? pendingToken;
  final TextEditingController otpController;
  final bool isLoading;
  final VoidCallback onVerify;
  final void Function(String pendingToken) onResend;

  const _OtpFormContent({
    required this.email,
    required this.pendingToken,
    required this.otpController,
    required this.isLoading,
    required this.onVerify,
    required this.onResend,
  });

  @override
  State<_OtpFormContent> createState() => _OtpFormContentState();
}

class _OtpFormContentState extends State<_OtpFormContent> {
  int _countdown = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _countdown = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown <= 1) {
        timer.cancel();
        setState(() => _countdown = 0);
      } else {
        setState(() => _countdown = _countdown - 1);
      }
    });
  }

  void _onResendPressed() {
    final token = widget.pendingToken;
    if (token == null || token.isEmpty || _countdown > 0) return;
    widget.onResend(token);
    _startCountdown();
  }

  @override
  Widget build(BuildContext context) {
    final tt = context.textTheme;
    final cs = context.theme.colorScheme;
    final canResend = _countdown == 0 && widget.pendingToken != null;

    return Padding(
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
          const SizedBox(height: 16),
          Text(
            'Check your email.',
            style: tt.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              height: 1.1,
              color: AppThemeColors.primaryText,
            ),
          ),
          const SizedBox(height: 6),
          RichText(
            text: TextSpan(
              style: tt.bodyMedium?.copyWith(
                color: AppThemeColors.secondaryText,
                fontSize: 15,
              ),
              children: [
                const TextSpan(text: 'We sent a 6-digit code to '),
                TextSpan(
                  text: widget.email,
                  style: TextStyle(
                    color: AppThemeColors.primaryAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // OTP input — centered, spaced digits
          TextFormField(
            controller: widget.otpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            textAlign: TextAlign.center,
            autofocus: true,
            style: tt.displayMedium?.copyWith(
              letterSpacing: 14,
              color: AppThemeColors.primaryText,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              counterText: '',
              hintText: '------',
              hintStyle: tt.displayMedium?.copyWith(
                letterSpacing: 14,
                color: AppThemeColors.neutral300.withValues(alpha: 0.3),
                fontWeight: FontWeight.bold,
              ),
              filled: true,
              fillColor: AppThemeColors.inputFill,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppThemeMetrics.radiusMd),
                borderSide: const BorderSide(color: AppThemeColors.inputBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppThemeMetrics.radiusMd),
                borderSide: const BorderSide(
                  color: AppThemeColors.primaryAccent,
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),

          SizedBox(
            height: 52,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.isLoading ? null : widget.onVerify,
              child: widget.isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: cs.onPrimary,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Verify',
                          style: tt.titleMedium?.copyWith(
                            color: cs.onPrimary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.check_rounded,
                          color: cs.onPrimary,
                          size: 18,
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 16),

          // Resend link with countdown
          Center(
            child: TextButton(
              onPressed: widget.isLoading || !canResend
                  ? null
                  : _onResendPressed,
              child: Text(
                _countdown > 0 ? 'Resend code (${_countdown}s)' : 'Resend code',
                style: tt.bodySmall?.copyWith(
                  color: AppThemeColors.primaryAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── Password strength indicator ─────────────────────────────────────────────────

class _PasswordStrengthIndicator extends StatefulWidget {
  final TextEditingController controller;
  const _PasswordStrengthIndicator({required this.controller});

  @override
  State<_PasswordStrengthIndicator> createState() =>
      _PasswordStrengthIndicatorState();
}

class _PasswordStrengthIndicatorState
    extends State<_PasswordStrengthIndicator> {
  int _strength = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onPasswordChanged);
    _onPasswordChanged();
  }

  @override
  void didUpdateWidget(_PasswordStrengthIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onPasswordChanged);
      widget.controller.addListener(_onPasswordChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onPasswordChanged);
    super.dispose();
  }

  void _onPasswordChanged() {
    final p = widget.controller.text;
    int count = 0;
    if (p.length >= 8) count++;
    if (p.contains(RegExp(r'[A-Z]'))) count++;
    if (p.contains(RegExp(r'[a-z]'))) count++;
    if (p.contains(RegExp(r'[0-9]'))) count++;
    if (p.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) count++;
    if (count != _strength) setState(() => _strength = count);
  }

  @override
  Widget build(BuildContext context) {
    final colors = [
      AppThemeColors.error,
      AppThemeColors.warning,
      AppThemeColors.primaryAccent,
      AppThemeColors.success,
    ];
    final segments = _strength == 0
        ? 1
        : _strength > 4
        ? 4
        : _strength;
    final activeColor = _strength == 0
        ? AppThemeColors.neutral300.withValues(alpha: 0.3)
        : colors[(_strength - 1).clamp(0, 3)];

    return Row(
      children: List.generate(4, (i) {
        final isActive = i < segments;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < 3 ? 4 : 0),
            child: Container(
              height: 3,
              decoration: BoxDecoration(
                color: isActive
                    ? activeColor
                    : AppThemeColors.neutral300.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ── Bottom sign-in / go-back link ──────────────────────────────────────────────

class _BottomLink extends StatelessWidget {
  final bool isOtpStep;
  final VoidCallback onTap;

  const _BottomLink({required this.isOtpStep, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tt = context.textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          isOtpStep ? 'Wrong email? ' : 'Already have an account? ',
          style: tt.bodySmall?.copyWith(color: AppThemeColors.secondaryText),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            isOtpStep ? 'Go back' : 'Sign In',
            style: tt.bodySmall?.copyWith(
              color: AppThemeColors.primaryAccent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
