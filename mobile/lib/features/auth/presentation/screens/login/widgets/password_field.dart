import 'package:flutter/material.dart';
import '../../../../../../core/validators/validators.dart';

class PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggle;
  final VoidCallback onSubmit;

  const PasswordField({
    super.key,
    required this.controller,
    required this.obscure,
    required this.onToggle,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => onSubmit(),
      decoration: InputDecoration(
        hintText: '••••••••',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            obscure
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
          onPressed: onToggle,
        ),
      ),
      validator: AppValidators.validatePassword,
    );
  }
}