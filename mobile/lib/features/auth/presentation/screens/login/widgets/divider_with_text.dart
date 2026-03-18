import 'package:flutter/material.dart';
import '../../../../../../core/extensions/extensions.dart';

class DividerWithText extends StatelessWidget {
  const DividerWithText({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = context.textTheme;

    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.widthCalculated(8),
          ),
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
