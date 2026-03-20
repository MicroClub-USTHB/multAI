import 'package:flutter/material.dart';
import '../../../../../../core/extensions/extensions.dart';
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
    final tt = context.textTheme;
 
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      textInputAction: TextInputAction.done,
      style: tt.bodyMedium,
      onFieldSubmitted: (_) => onSubmit(),
      // InputDecorationTheme from AppTheme handles border/fill/colors
      decoration: InputDecoration(
        hintText: '••••••••',
        prefixIcon: Icon(
          Icons.lock_outline,
          size: context.iconSize(),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscure
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            size: context.iconSize(),
          ),
          onPressed: onToggle,
        ),
      ),
      validator: AppValidators.validatePassword,
    );
  }
}
 