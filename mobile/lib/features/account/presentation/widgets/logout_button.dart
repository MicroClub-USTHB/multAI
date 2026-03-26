import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/responsive_extensions.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = context.textTheme;

    return Container(
      width: double.infinity,
      height: context.heightCalculated(50),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.radius()),
        border: Border.all(color: Colors.red),
      ),
      child: TextButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.logout, color: Colors.red),
        label: Text(
          "Logout",
          style: tt.titleMedium?.copyWith(color: Colors.red),
        ),
      ),
    );
  }
}