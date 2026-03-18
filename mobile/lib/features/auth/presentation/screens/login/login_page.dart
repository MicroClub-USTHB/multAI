import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/theme/theme.dart';
import '../blocs/auth_bloc.dart';
import 'widgets/logo_section.dart';
import 'widgets/email_field.dart';
import 'widgets/password_field.dart';
import 'widgets/sign_in_button.dart';
import 'widgets/divider_with_text.dart';
import 'widgets/google_button.dart';
import 'widgets/create_workspace.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

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
        final tt = context.textTheme;

        return Scaffold(
          backgroundColor: const Color(0xFF0F0D07),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1C1910),
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const LogoSection(),
                                const SizedBox(height: 40),
                                EmailField(controller: _emailController),
                                const SizedBox(height: 24),
                                PasswordField(
                                  controller: _passwordController,
                                  onSubmitted: _onSignInPressed,
                                ),
                                const SizedBox(height: 32),
                                SignInButton(
                                  isLoading: isLoading, 
                                  onPressed: _onSignInPressed
                                ),
                                const SizedBox(height: 24),
                                const DividerWithText(),
                                const SizedBox(height: 24),
                                GoogleButton(isLoading: isLoading),
                                const SizedBox(height: 24),
                                const CreateWorkspaceLink(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: [
                      Text(
                        'PROTECTED BY ADVANCED NEURAL ENCRYPTION',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.3),
                          fontSize: 10,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '© 2024 MULTIAI CORP',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.3), 
                          fontSize: 10
                        ),
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
