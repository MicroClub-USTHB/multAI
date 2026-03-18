import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../../core/extensions/extensions.dart';
import '../../../../../../core/theme/theme.dart';
import '../../../../../../core/validators/validators.dart';

class EmailField extends StatelessWidget {
  final TextEditingController controller;
  const EmailField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Email address',
          style: GoogleFonts.raleway(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: AppTheme.primaryTextColor.withOpacity(0.85),
          ),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          style: GoogleFonts.montserrat(
            color: AppTheme.primaryTextColor,
            fontSize: 16,
          ),
          autofillHints: const [AutofillHints.email],
          decoration: const InputDecoration(
            hintText: 'name@example.com',
            prefixIcon: Icon(Icons.email_outlined),
          ),
          validator: AppValidators.validateEmail,
        ),
      ],
    );
  }
}
