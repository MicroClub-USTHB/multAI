import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/theme/theme.dart';
import '../../blocs/auth_bloc.dart';

import 'widgets/logo_section.dart';
import 'widgets/email_field.dart';
import 'widgets/password_field.dart';
import 'widgets/sign_in_button.dart';
import 'widgets/divider_with_text.dart';
import 'widgets/google_button.dart';
import 'widgets/create_workspace.dart';
import 'widgets/forgot_password.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true; // ✅ FIX

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
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          context.pushNamedAndRemoveUntil('/home');
        }
        if (state is AuthFailure) {
          context.showErrorSnackBar(state.message);
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: Container(
                          padding:
                              const EdgeInsets.all(AppTheme.spacingLg),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceColor,
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment:
                                  CrossAxisAlignment.stretch,
                              children: [
                                const LogoSection(),

                                const SizedBox(
                                    height: AppTheme.spacingXxl),


                                EmailField(
                                    controller: _emailController),

                                const SizedBox(
                                    height: AppTheme.spacingLg),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Password',
                                      style: context.textTheme.titleMedium,
                                    ),
                                    ForgotPassword(onTap: () {}),
                                  ],
                                ),

                                const SizedBox(
                                    height: AppTheme.spacingSm),

                                PasswordField(
                                  controller: _passwordController,
                                  obscure: _obscurePassword,
                                  onToggle: () {
                                    setState(() {
                                      _obscurePassword =
                                          !_obscurePassword;
                                    });
                                  },
                                  onSubmit: _onSignInPressed,
                                ),

                                const SizedBox(
                                    height: AppTheme.spacingXl),


                                SignInButton(
                                  isLoading: isLoading,
                                  onPressed: _onSignInPressed,
                                ),

                                const SizedBox(
                                    height: AppTheme.spacingLg),

                                const DividerWithText(),

                                const SizedBox(
                                    height: AppTheme.spacingLg),


                                GoogleButton(
                                  onPressed: () {},
                                ),

                                const SizedBox(
                                    height: AppTheme.spacingLg),


                                CreateWorkspace(
                                  onTap: () {},
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppTheme.spacingMd),

                  Column(
                    children: const [
                      Text(
                        'PROTECTED BY ADVANCED NEURAL ENCRYPTION',
                        style: TextStyle(fontSize: 10),
                      ),
                      SizedBox(height: AppTheme.spacingXs),
                      Text(
                        '© 2024 MULTIAI CORP',
                        style: TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}