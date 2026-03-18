import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../../core/extensions/extensions.dart';
import '../../../../../../core/theme/theme.dart';
import '../../../../../../core/validators/validators.dart';
import 'forgot_password.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSubmitted;

  const PasswordField({
    super.key,
    required this.controller,
    required this.onSubmitted,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Password',
              style: GoogleFonts.raleway(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppTheme.primaryTextColor.withOpacity(0.85),
              ),
            ),
            const ForgotPasswordButton(),
          ],
        ),
        const SizedBox(height: AppTheme.spacingSm),
        TextFormField(
          controller: widget.controller,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.done,
          style: GoogleFonts.montserrat(
            color: AppTheme.primaryTextColor,
            fontSize: 16,
          ),
          onFieldSubmitted: (_) => widget.onSubmitted(),
          decoration: InputDecoration(
            hintText: '••••••••',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          validator: AppValidators.validatePassword,
        ),
      ],
    );
  }
}
