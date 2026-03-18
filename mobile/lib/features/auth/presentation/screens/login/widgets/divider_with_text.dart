import 'package:flutter/material.dart';
import '../../../../../../core/theme/theme.dart';

class DividerWithText extends StatelessWidget {
  const DividerWithText({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
          child: Text(
            'OR CONTINUE WITH',
            style: TextStyle(
              color: AppTheme.hintTextColor,
              fontSize: 12,
              letterSpacing: 1.1,
            ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}
