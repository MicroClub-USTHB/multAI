import 'package:flutter/material.dart';
import '../../../../../../core/validators/validators.dart';
import '../../../../../../core/extensions/context_extensions.dart';

class EmailField extends StatelessWidget {
  final TextEditingController controller;

  const EmailField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      style: context.textTheme.bodyMedium,
      autofillHints: const [AutofillHints.email],
      decoration: const InputDecoration(hintText: 'name@example.com'),
      validator: AppValidators.validateEmail,
    );
  }
}
