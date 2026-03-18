import 'package:flutter/material.dart';

class CreateWorkspace extends StatelessWidget {
  final VoidCallback onTap;

  const CreateWorkspace({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        Text("Don't have an account? ", style: tt.labelMedium),
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