import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:multai_mobile/core/router/app_routes.dart';

import '../../../../../core/extensions/extensions.dart' as di ;
import '../../../../../core/theme/theme.dart';
import '../../blocs/auth_bloc.dart';
import 'package:multai_mobile/features/face_enrollment/domain/usecases/check_enrollment_done_usecase.dart';
import 'widgets/logo_section.dart';
import 'widgets/email_field.dart';
import 'widgets/password_field.dart';
import 'widgets/sign_in_button.dart';
import 'widgets/divider_with_text.dart';
import 'widgets/google_button.dart';
import 'widgets/create_workspace.dart';
import 'widgets/forgot_password.dart';
import 'package:multai_mobile/di/injection_container.dart';

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
    final cs = context.theme.colorScheme;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) async {
        final useCase = sl<CheckEnrollmentDoneUseCase>();
        final bool isDone = await useCase.call();
        if (state is AuthSuccess) {
        if (context.mounted) {
            isDone
                ? context.go(AppRoutes.events)
                : context.go(AppRoutes.faceEnrollment);
          }
        }
        // ignore: use_build_context_synchronously
        if (state is AuthFailure) context.showErrorSnackBar(state.message);
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
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
                      padding: EdgeInsets.all(AppTheme.spacingLg),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
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

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Password',
                                  style: tt.titleMedium?.copyWith(
                                    color: cs.onSurface,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                ForgotPassword(onTap: () {}),
                              ],
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
                              onSubmit: _onSignInPressed,
                            ),
                            SizedBox(height: context.heightCalculated(24)),

                            SignInButton(
                              isLoading: isLoading,
                              // height: context.heightCalculated(52),
                              onPressed: _onSignInPressed,
                            ),
                            SizedBox(height: context.heightCalculated(16)),

                            const DividerWithText(),
                            SizedBox(height: context.heightCalculated(16)),

                            GoogleButton(
                              // height: context.heightCalculated(52),
                              onPressed: () {},
                            ),
                            SizedBox(height: context.heightCalculated(16)),

                            CreateWorkspace(onTap: () {}),
                            SizedBox(height: context.heightCalculated(24)),
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
