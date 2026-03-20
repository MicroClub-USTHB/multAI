import 'package:flutter/material.dart';
import '../../../../../../core/extensions/extensions.dart';
import '../../../../../../core/validators/validators.dart';
 
class EmailField extends StatelessWidget {
  final TextEditingController controller;
 
  const EmailField({super.key, required this.controller});
 
  @override
  Widget build(BuildContext context) {
    final tt = context.textTheme;
 
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      style: tt.bodyMedium,
      autofillHints: const [AutofillHints.email],
      // InputDecorationTheme from AppTheme handles border/fill/colors
      decoration: InputDecoration(
        hintText: 'name@example.com',
        prefixIcon: Icon(
          Icons.email_outlined,
          size: context.iconSize(),
        ),
      ),
      validator: AppValidators.validateEmail,
    );
  }
}
 



