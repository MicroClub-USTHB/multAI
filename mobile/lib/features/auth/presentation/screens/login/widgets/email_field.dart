import 'package:flutter/material.dart';
import '../../../../../../core/extensions/extensions.dart';
import '../../../../../../core/validators/validators.dart';
class EmailField extends StatelessWidget {
  final TextEditingController controller;

  const EmailField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.textTheme;

    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      style: tt.bodyMedium,
      autofillHints: const [AutofillHints.email],
      decoration: InputDecoration(
        hintText: 'Email',
        hintStyle: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
        prefixIcon: Icon(
          Icons.email_outlined,
          color: cs.onSurfaceVariant,
          size: context.iconSize(), 
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
          borderSide: BorderSide(color: cs.primary, width: context.widthCalculated(1.5)),
        ),
      ),
      validator: AppValidators.validateEmail,
    );
  }
}





