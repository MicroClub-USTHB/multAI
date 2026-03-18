import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'widgets/create_workspace.dart';
import 'widgets/divider_with_text.dart';
import 'widgets/email_field.dart';
import 'widgets/forgot_password.dart';
import 'widgets/google_button.dart';
import 'widgets/logo_section.dart';
import 'widgets/password_field.dart';
import 'widgets/sign_in_button.dart';
import '../../blocs/auth_bloc.dart';

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

  void _onSignInPressed() {
    if (!_formKey.currentState!.validate()) return;

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
      listener: (context, state) {},
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const LogoSection(),

                    const SizedBox(height: 16),
                    EmailField(controller: _emailController),

                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Password",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        ForgotPassword(onTap: () {}),
                      ],
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

                    const SizedBox(height: 16),
                    SignInButton(
                      isLoading: isLoading,
                      onPressed: _onSignInPressed,
                    ),

                    const SizedBox(height: 16),
                    const DividerWithText(),

                    const SizedBox(height: 16),
                    GoogleButton(onPressed: () {}),

                    const SizedBox(height: 16),
                    CreateWorkspace(onTap: () {}),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}