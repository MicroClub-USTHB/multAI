import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../../core/theme/theme.dart';
import '../blocs/auth_bloc.dart';


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
        final cs = context.theme.colorScheme;

        return Scaffold(
          backgroundColor: context.theme.scaffoldBackgroundColor,
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.hPadding(context),
                  vertical: AppTheme.spacingXxl,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: AppTheme.cardWidth(context),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [

                        _LogoSection(),
                        SizedBox(height: AppTheme.sectionSpacing(context) * 2),

                        Text('Email address', style: tt.titleMedium),
                        const SizedBox(height: AppTheme.spacingSm),

                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          style: tt.bodyMedium,
                          decoration: const InputDecoration(
                            hintText: 'name@example.com',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,}$')
                                .hasMatch(v.trim())) {
                              return 'Enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: AppTheme.sectionSpacing(context)),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Password', style: tt.titleMedium),
                            GestureDetector(
                              onTap: () {
                                // TODO: navigate to forgot password screen
                              },
                              child: Text(
                                'Forgot?',
                                style: tt.labelMedium?.copyWith(
                                  color: cs.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.spacingSm),

                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          style: tt.bodyMedium,
                          onFieldSubmitted: (_) => _onSignInPressed(),
                          decoration: InputDecoration(
                            hintText: '••••••••',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (v.length < 6) {
                              return 'Minimum 6 characters';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: AppTheme.sectionSpacing(context)),

                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _onSignInPressed,
                            child: isLoading
                                ? SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: cs.onPrimary,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Sign In',
                                        style: tt.titleLarge?.copyWith(
                                          color: cs.onPrimary,
                                        ),
                                      ),
                                      const SizedBox(width: AppTheme.spacingSm),
                                      Icon(
                                        Icons.arrow_forward,
                                        color: cs.onPrimary,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        SizedBox(height: AppTheme.sectionSpacing(context)),

                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppTheme.spacingSm,
                              ),
                              child: Text(
                                'OR CONTINUE WITH',
                                style: tt.labelSmall?.copyWith(
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),
                        SizedBox(height: AppTheme.sectionSpacing(context)),

                        SizedBox(
                          height: 52,
                          child: OutlinedButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    // TODO: dispatch Google login event
                                  },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.g_mobiledata_rounded,
                                  color: AppTheme.googleColor,
                                  size: 26,
                                ),
                                const SizedBox(width: AppTheme.spacingSm),
                                Text('Google', style: tt.titleMedium),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: AppTheme.sectionSpacing(context) * 2,
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: tt.bodySmall,
                            ),
                            GestureDetector(
                              onTap: () {
                                // TODO: navigate to register screen
                              },
                              child: Text(
                                'Create workspace',
                                style: tt.bodySmall?.copyWith(
                                  color: cs.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppTheme.sectionSpacing(context)),

                        Text(
                          'PROTECTED BY ADVANCED NEURAL ENCRYPTION\n2024 MULTIAI CORP',
                          style: tt.labelSmall?.copyWith(
                            letterSpacing: 0.8,
                            height: 1.8,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LogoSection extends StatelessWidget {
  const _LogoSection();

  @override
  Widget build(BuildContext context) {
    final tt = context.textTheme;
    final cs = context.theme.colorScheme;

    return Column(
      children: [
        Container(
          width: AppTheme.logoSize(context),
          height: AppTheme.logoSize(context),
          decoration: BoxDecoration(
            color: cs.primary,
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          ),
          // TODO: replace with Image.asset('assets/images/MC_white.png')
          child: Icon(
            Icons.auto_awesome,
            color: cs.onPrimary,
            size: AppTheme.logoSize(context) * 0.5,
          ),
        ),
        const SizedBox(height: AppTheme.spacingMd),
        Text(
          'MultiAi',
          style: tt.displaySmall?.copyWith(
            fontSize: AppTheme.titleFontSize(context),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppTheme.spacingXs),
        Text(
          'Elevate your intelligence workspace',
          style: tt.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}