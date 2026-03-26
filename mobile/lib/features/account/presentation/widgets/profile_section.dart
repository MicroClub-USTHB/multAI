
import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/responsive_extensions.dart';
import '../../../../core/theme/theme.dart';


class ProfileSection extends StatelessWidget {
  const ProfileSection({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = context.textTheme;
    final cs = context.theme.colorScheme;

    return Column(
      children: [
        /// Avatar
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: context.width * 0.15,
              backgroundColor: cs.surface,
              child: Icon(Icons.person, size: context.width * 0.15),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: cs.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.edit, size: 16),
            )
          ],
        ),

        SizedBox(height: context.heightCalculated(12)),

        /// Username
        Text(
          "Username",
          style: tt.headlineSmall,
        ),

        SizedBox(height: context.heightCalculated(6)),

        /// Membership badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            "Gold Member",
            style: tt.labelMedium?.copyWith(color: Colors.black),
          ),
        ),

        SizedBox(height: context.heightCalculated(6)),

        /// Email
        Text(
          "email@example.com",
          style: tt.bodySmall?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}