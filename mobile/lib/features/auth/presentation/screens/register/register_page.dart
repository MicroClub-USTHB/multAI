import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:multai_mobile/core/router/app_routes.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/responsive_extensions.dart';
import '../../../../../core/extensions/snackbar_extensions.dart';
import '../../../../../core/validators/validators.dart';
import 'package:multai_mobile/core/theme/app_theme_metrics.dart';
import 'package:multai_mobile/core/theme/app_theme_colors.dart';
import '../../blocs/auth_bloc.dart';
import '../login/widgets/logo_section.dart';
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

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onRegisterPressed() {
    if (!_formKey.currentState!.validate()) return;
    context.unfocus();

    context.read<AuthBloc>().add(
      RegisterRequested(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tt = context.textTheme;
    final cs = context.theme.colorScheme;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go(AppRoutes.events);
        } else if (state is AuthNeedsFaceEnrollment) {
          context.go(AppRoutes.faceEnrollment);
        }
        if (state is AuthFailure) context.showErrorSnackBar(state.message);
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
                    padding: EdgeInsets.symmetric(
                      horizontal: context.hPadding(),
                      vertical: context.heightCalculated(24),
                    ),
                    child: Container(
                      padding: EdgeInsets.all(AppThemeMetrics.spacingLg),
                      decoration: BoxDecoration(
                        color: AppThemeColors.surface,
                        borderRadius: BorderRadius.circular(
                          AppThemeMetrics.radiusLg,
                        ),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const LogoSection(),
                            SizedBox(height: context.heightCalculated(24)),

                            Text(
                              'Email',
                              style: tt.titleMedium?.copyWith(
                                color: cs.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: context.heightCalculated(8)),
                            EmailField(controller: _emailController),
                            SizedBox(height: context.heightCalculated(16)),

                            Text(
                              'Password',
                              style: tt.titleMedium?.copyWith(
                                color: cs.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: context.heightCalculated(8)),
                            PasswordField(
                              controller: _passwordController,
                              obscure: _obscurePassword,
                              onToggle: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              onSubmit: () {},
                            ),
                            SizedBox(height: context.heightCalculated(16)),

                            Text(
                              'Confirm Password',
                              style: tt.titleMedium?.copyWith(
                                color: cs.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: context.heightCalculated(8)),
                            PasswordField(
                              controller: _confirmPasswordController,
                              obscure: _obscureConfirm,
                              onToggle: () {
                                setState(() {
                                  _obscureConfirm = !_obscureConfirm;
                                });
                              },
                              onSubmit: _onRegisterPressed,
                              hintText: '••••••••',
                              validator: (v) => AppValidators.validateConfirmPassword(
                                v,
                                password: _passwordController.text,
                              ),
                            ),
                            SizedBox(height: context.heightCalculated(24)),

                            SizedBox(
                              height: context.heightCalculated(52),
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : _onRegisterPressed,
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
                                            'Sign Up',
                                            style: tt.titleLarge?.copyWith(
                                              color: cs.onPrimary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(width: context.widthCalculated(6)),
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
                            Text(
                              'Use your workspace email to create an account.',
                              style: tt.bodySmall?.copyWith(
                                color: cs.onSurface.withValues(alpha: 0.7),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: context.heightCalculated(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.go(AppRoutes.login),
                        child: Text(
                          'Sign In',
                          style: tt.bodySmall?.copyWith(
                            color: AppThemeColors.primaryAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: context.heightCalculated(8),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'PROTECTED BY ADVANCED NEURAL ENCRYPTION',
                        style: tt.labelSmall?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: context.heightCalculated(2)),
                      Text(
                        '© 2024 MULTIAI CORP',
                        style: tt.labelSmall?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.7),
                        ),
                        textAlign: TextAlign.center,
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
