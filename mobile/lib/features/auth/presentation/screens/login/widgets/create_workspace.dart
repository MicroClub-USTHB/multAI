import 'package:flutter/material.dart';
import '../../../../../../core/extensions/extensions.dart';

class CreateWorkspaceLink extends StatelessWidget {
  const CreateWorkspaceLink({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = context.textTheme;
    final cs = context.theme.colorScheme;
    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        Text("Don't have an account? ", style: tt.labelMedium),
        GestureDetector(
          onTap: () {},
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
