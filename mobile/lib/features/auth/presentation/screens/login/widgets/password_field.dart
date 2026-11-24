import 'package:flutter/material.dart';
import '../../../../../../core/extensions/context_extensions.dart';
import '../../../../../../core/validators/validators.dart';
import 'package:multai_mobile/core/theme/app_palette.dart';

class PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggle;
  final VoidCallback onSubmit;
  final String? Function(String?)? validator;
  final String hintText;

  const PasswordField({
    super.key,
    required this.controller,
    required this.obscure,
    required this.onToggle,
    required this.onSubmit,
    this.validator,
    this.hintText = '••••••••',
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      textInputAction: TextInputAction.done,
      autocorrect: false,
      enableSuggestions: false,
      style: context.textTheme.bodyMedium,
      onFieldSubmitted: (_) => onSubmit(),
      decoration: InputDecoration(
        hintText: hintText,
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: context.colors.neutral300,
            size: 20,
          ),
          onPressed: onToggle,
        ),
      ),
      validator: validator ?? AppValidators.validatePassword,
    );
  }
}
