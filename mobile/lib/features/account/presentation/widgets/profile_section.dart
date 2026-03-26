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

    return Center(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ── Avatar with amber border ─────────────────────────────────────
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.primaryColor, width: 3),
          ),
          child: CircleAvatar(
            radius: context.widthCalculated(52),
            backgroundColor: AppTheme.surfaceColor,
            child: Icon(
              Icons.person,
              size: context.widthCalculated(48),
              color: AppTheme.secondaryTextColor,
            ),
          ),
        ),
        SizedBox(height: context.heightCalculated(16)),

        // ── Name ─────────────────────────────────────────────────────────
        Text(
          'Alex Rivers',
          style: tt.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryTextColor,
          ),
        ),
        SizedBox(height: context.heightCalculated(8)),

        // ── MC MEMBER badge ───────────────────────────────────────────────
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.widthCalculated(12),
            vertical: context.heightCalculated(4),
          ),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          ),
          child: Text(
            'MC MEMBER',
            style: tt.labelSmall?.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        SizedBox(height: context.heightCalculated(8)),

        // ── Email ─────────────────────────────────────────────────────────
        Text(
          'alex.rivers@multiai.com',
          style: tt.bodySmall?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    ),
    );


  }
}
