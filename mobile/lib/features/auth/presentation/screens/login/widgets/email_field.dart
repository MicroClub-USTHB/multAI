import 'package:flutter/material.dart';
import '../../../../../../core/extensions/extensions.dart';
import '../../../../../../core/validators/validators.dart';

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
      decoration: const InputDecoration(
        hintText: 'name@example.com',
        prefixIcon: Icon(Icons.email_outlined),
      ),
      validator: AppValidators.validateEmail,
    );
  }
}
