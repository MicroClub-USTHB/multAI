import 'package:flutter/material.dart';
import '../../../../../../core/extensions/extensions.dart';
 
class CreateWorkspace extends StatelessWidget {
  final VoidCallback onTap;
 
  const CreateWorkspace({super.key, required this.onTap});
 
  @override
  Widget build(BuildContext context) {
    final tt = context.textTheme;
    final cs = context.theme.colorScheme;
 
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: context.widthCalculated(4),
      children: [
        Text(
          "Don't have an account?",
          style: tt.labelMedium,
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            'Create workspace',
            style: tt.labelMedium?.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}