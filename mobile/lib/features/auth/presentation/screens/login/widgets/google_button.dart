import 'package:flutter/material.dart';
import '../../../../../../core/constants/images.dart';

class GoogleButton extends StatelessWidget {
  final VoidCallback onPressed;

  const GoogleButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(AppImages.googleLogo, height: 18),
            const SizedBox(width: 6),
            Text('Google', style: tt.titleMedium),
          ],
        ),
      ),
    );
  }
}
