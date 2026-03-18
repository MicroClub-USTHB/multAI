import 'package:flutter/material.dart';
import '../../../../../../core/extensions/extensions.dart';
import '../../../../../../core/constants/images.dart';

class GoogleButton extends StatelessWidget {
  final VoidCallback onPressed;

  const GoogleButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final tt = context.textTheme;

    return SizedBox(
      height: context.heightCalculated(52),
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.widthCalculated(8)),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              '${AppImages.imagesPath}/google.png',
              height: context.heightCalculated(20),
              width: context.widthCalculated(20),
            ),
            SizedBox(width: context.widthCalculated(8)),
            Text(
              'Google',
              style: tt.titleMedium?.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: context.widthCalculated(14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}