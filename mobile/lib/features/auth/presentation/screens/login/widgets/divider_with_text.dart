import 'package:flutter/material.dart';
import '../../../../../../core/extensions/extensions.dart';
import '../../../../../../core/theme/theme.dart';

class DividerWithText extends StatelessWidget {
  const DividerWithText({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = context.textTheme;
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingSm),
          child: Text(
            'OR CONTINUE WITH',
            style: tt.labelSmall?.copyWith(letterSpacing: 1.2),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}
