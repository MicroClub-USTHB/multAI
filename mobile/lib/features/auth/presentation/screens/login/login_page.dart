import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/theme.dart';
import 'widgets/create_workspace.dart';
import 'widgets/divider_with_text.dart';
import 'widgets/email_field.dart';
import 'widgets/google_button.dart';
import 'widgets/logo_section.dart';
import 'widgets/password_field.dart';
import 'widgets/sign_in_button.dart';
import '../../blocs/auth_bloc.dart';
import '../../../../../core/extensions/extensions.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

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

                    SizedBox(height: context.sectionSpacing() * 2),
                    EmailField(controller: _emailController),

                    const SizedBox(height: AppTheme.spacingXl),
                    PasswordField(
                      controller: _passwordController,
                      onSubmitted: _onSignInPressed,
                    ),

                    SizedBox(height: context.sectionSpacing() * 1.5),

                    SignInButton(
                      isLoading: isLoading,
                      onPressed: _onSignInPressed,
                    ),

                    SizedBox(height: context.sectionSpacing() * 1.5),
                    const DividerWithText(),

                    SizedBox(height: context.sectionSpacing() * 1.5),
                    GoogleButton(isLoading: isLoading),

                    SizedBox(height: context.sectionSpacing() * 1.5),
                    const CreateWorkspaceLink(),
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




