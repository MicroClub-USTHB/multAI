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
    final cs = context.theme.colorScheme;
    final tt = context.textTheme;

    return TextFormField(
      controller: controller,
      obscureText: obscure,
      textInputAction: TextInputAction.done,
      style: tt.bodyMedium,
      onFieldSubmitted: (_) => onSubmit(),
      decoration: InputDecoration(
        hintText: 'Password',
        hintStyle: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
        prefixIcon: Icon(
          Icons.lock_outline,
          color: cs.onSurfaceVariant,
          size: context.iconSize(),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            size: context.iconSize(),
            color: cs.onSurfaceVariant,
          ),
          onPressed: onToggle,
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: context.heightCalculated(14),
          horizontal: context.widthCalculated(12),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.radius()),
          borderSide: BorderSide(color: cs.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.radius()),
          borderSide: BorderSide(color: cs.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.radius()),
          borderSide: BorderSide(color: cs.primary, width: 1.5),
        ),
      ),
      validator: AppValidators.validatePassword,
    );
  }
}