import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:multai_mobile/core/validators/validators.dart';
 
import '../../../../core/extensions/extensions.dart';
import '../../../../core/theme/theme.dart';
import '../blocs/auth_bloc.dart';
import '../../../../core/constants/images.dart';
 
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
                  horizontal: context.hPadding(),
                  vertical: AppTheme.spacingXxl,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: context.cardWidth(),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceColor,
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusLg),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingLg,
                            vertical: AppTheme.spacingXl,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
 
                              const _LogoSection(),
                              SizedBox(
                                height: context.sectionSpacing() * 2,
                              ),
 
                              Text(
                                'Email address',
                                style: tt.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryTextColor
                                      .withValues(alpha: 0.85),
                                ),
                              ),
                              const SizedBox(height: AppTheme.spacingSm),
 
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                style: tt.bodyMedium,
                                autofillHints: [AutofillHints.email],
                                decoration: const InputDecoration(
                                  hintText: 'name@example.com',
                                  prefixIcon: Icon(Icons.email_outlined),
                                ),
                                validator: AppValidators.validateEmail,
                              ),
                              const SizedBox(height: AppTheme.spacingXl),
 
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Password',
                                    style: tt.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryTextColor
                                          .withValues(alpha: 0.85),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {},
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
                                      () =>
                                          _obscurePassword = !_obscurePassword,
                                    ),
                                  ),
                                ),
                                validator: AppValidators.validatePassword,
                              ),
                              SizedBox(
                                height: context.sectionSpacing() * 1.5,
                              ),
 
                              SizedBox(
                                height: 52,
                                child: ElevatedButton(
                                  onPressed:
                                      isLoading ? null : _onSignInPressed,
                                  child: isLoading
                                      ? SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: cs.onPrimary,
                                          ),
                                        )
                                      : Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'Sign In',
                                              style: tt.titleLarge?.copyWith(
                                                color: cs.onPrimary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(
                                                width: AppTheme.spacingXs),
                                            Icon(
                                              Icons.arrow_forward,
                                              color: cs.onPrimary,
                                              size: 18,
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                              SizedBox(
                                height: context.sectionSpacing() * 1.5,
                              ),
 
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
                              SizedBox(
                                height: context.sectionSpacing() * 1.5,
                              ),
 
                              SizedBox(
                                height: 52,
                                child: OutlinedButton(
                                  onPressed: isLoading ? null : () {},
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryTextColor,
                                    foregroundColor: Colors.black87,
                                    side: BorderSide.none,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          AppTheme.radiusMd),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Image.asset(
                                        '${AppImages.imagesPath}/google.png',
                                        height: 18,
                                        width: 18,
                                      ),
                                      const SizedBox(width: AppTheme.spacingXs),
                                      Text(
                                        'Google',
                                        style: tt.titleMedium?.copyWith(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: context.sectionSpacing() * 1.5,
                              ),
 
                              Wrap(
                                alignment: WrapAlignment.center,
                                children: [
                                  Text(
                                    "Don't have an account? ",
                                    style: tt.labelMedium,
                                  ),
                                  GestureDetector(
                                    onTap: () {},
                                    child: Text(
                                      'Create workspace',
                                      style: tt.labelMedium?.copyWith(
                                        color: cs.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
 
                        const SizedBox(height: AppTheme.spacingXl),
                        Text(
                          'PROTECTED BY ADVANCED NEURAL ENCRYPTION © 2024 MULTIAI CORP',
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
    final logoSize = context.logoSize();
 
    return Column(
      children: [
        Container(
          width: logoSize,
          height: logoSize,
          decoration: BoxDecoration(
            color: cs.primary,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
          padding: const EdgeInsets.all(AppTheme.spacingXs),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            child: Image.asset(
              '${AppImages.imagesPath}/MC_white.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.auto_awesome,
                color: cs.onPrimary,
                size: logoSize * 0.55,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppTheme.spacingMd),
        Text(
          'MultiAi',
          style: tt.displaySmall?.copyWith(
            fontSize: context.titleFontSize(),
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryTextColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppTheme.spacingXs),
        Text(
          'Elevate your intelligence workspace',
          style: tt.bodySmall?.copyWith(
            color: AppTheme.secondaryTextColor.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
 